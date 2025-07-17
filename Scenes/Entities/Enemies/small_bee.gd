extends CharacterBody2D

enum EnemyState
{
	FLY,
	TAKEDAMAGE,
	ATTACK,
	DEATH,
}

var current_state: EnemyState = EnemyState.FLY
var Game_State : bool = true
var player : CharacterBody2D = null
var direction : Vector2 = [Vector2.RIGHT, Vector2.LEFT].pick_random()
var gotAttacked : bool = false
var canAttack : bool = false

@export var Health : float = 100
@export var speed : int = 50

@onready var Animations : AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_timer: Timer = $"Movement Timer"
@onready var attack_delay : Timer = $"Attack Delay"
@onready var detection_area: CollisionShape2D = $"Detection Area/CollisionShape2D"
@onready var hurt_box_component: HurtBoxComponent = $HurtBoxComponent

func OnAttack() -> void:
	pass

func Take_Damage(Power : float) -> void:
	Health -= Power
	gotAttacked = true
		
func Game_Loop() -> void:
	randomize()
	
	if Health <= 0:
		current_state = EnemyState.DEATH
	
	match current_state:
		EnemyState.FLY:
			Animations.play("fly")
			if player:
				direction.x = round((player.global_position - self.global_position).normalized().x)
				direction.y = 0
			else:
				if movement_timer.is_stopped():
					direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
					movement_timer.wait_time = randf_range(2.5,10)
					movement_timer.start()
			current_state = EnemyState.ATTACK if canAttack else current_state
			current_state = EnemyState.TAKEDAMAGE if gotAttacked else current_state
		
		EnemyState.TAKEDAMAGE:
			direction = Vector2.ZERO
			gotAttacked = false
			await get_tree().create_timer(1).timeout
			Animations.play("hit")
			await Animations.animation_finished
			current_state = EnemyState.FLY
		
		EnemyState.ATTACK:
			if attack_delay.is_stopped():
				direction = Vector2.ZERO
				Animations.play("attack")
				await Animations.animation_finished
				attack_delay.wait_time = randf_range(2,5)
				attack_delay.start()
			else:
				current_state = EnemyState.FLY
			
		EnemyState.DEATH:
			direction = Vector2.ZERO
			Animations.play("hit")
			await Animations.animation_finished
			call_deferred("queue_free")
			
	Game_State = true

func _ready() -> void:
	movement_timer.start()
	
	$"Detection Area".body_entered.connect(
		func(body: CharacterBody2D):
			player = body
	)
	
	$"Detection Area".body_exited.connect(
		func(_body: CharacterBody2D):
			player = null
	)
	
	hurt_box_component.area_entered.connect(
		func(_area: Area2D):
			canAttack = true
	)
	
	hurt_box_component.area_exited.connect(
		func(_area: Area2D):
			canAttack = false
	)

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	
	if velocity.normalized().x > 0:
		Animations.flip_h = true
	elif velocity.normalized().x < 0:
		Animations.flip_h = false

func _process(_delta: float) -> void:
	if Game_State:
		Game_State = false
	Game_Loop()
