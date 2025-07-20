extends Enemy

enum EnemyState
{
	RUN,
	WALK,
	DEATH,
	IDLE,
	TAKEDAMAGE,
}

var current_state: EnemyState = EnemyState.WALK
var Game_State : bool = true
var player : CharacterBody2D = null
var direction : Vector2 = [Vector2.RIGHT, Vector2.LEFT].pick_random()
var gotAttacked : bool = false

@export var gravity : int = 800
@export var Health : float = 100
@export var speed : int = 50

@onready var Animations : AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_timer: Timer = $"Movement Timer"
@onready var detection_area: CollisionShape2D = $"Detection Area/CollisionShape2D"
@onready var hitbox: HitBoxComponent = $HitBoxComponent
@onready var Hurtbox_component : HurtBoxComponent = $HurtBoxComponent

func OnAttack() -> void:
	pass

func Take_Damage(Power : float) -> void:
	Health -= Power
	gotAttacked = true
		
func Game_Loop() -> void:
	
	if Health <= 0:
		current_state = EnemyState.DEATH
	
	match current_state:
		EnemyState.DEATH:
			direction = Vector2.ZERO
			Animations.play("hit")
			await Animations.animation_finished
			die()
		
		EnemyState.RUN:
			speed = 100
			if player:
				direction.x = (player.global_position - self.global_position).normalized().x
			direction.x = round(direction.x)
			direction.y = 0
			Animations.play("run")
			current_state = EnemyState.WALK if !player else current_state
			current_state = EnemyState.TAKEDAMAGE if gotAttacked else current_state
		
		EnemyState.IDLE:
			direction = Vector2.ZERO
			Animations.play("idle")
			await Animations.animation_finished
			current_state = EnemyState.RUN if player else EnemyState.WALK
			current_state = EnemyState.TAKEDAMAGE if gotAttacked else current_state
		
		EnemyState.TAKEDAMAGE:
			direction = Vector2.ZERO
			gotAttacked = false
			await get_tree().create_timer(1).timeout
			Animations.play("hit")
			await Animations.animation_finished
			current_state = EnemyState.IDLE
		
		EnemyState.WALK:
			randomize()
			speed = 50
			if movement_timer.is_stopped():
				direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
				movement_timer.start()
			Animations.play("walk")
			current_state = EnemyState.RUN if player else current_state
			current_state = EnemyState.TAKEDAMAGE if gotAttacked else current_state
			
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

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	velocity.y += gravity
	move_and_slide()
	
	if velocity.normalized().x > 0:
		Animations.flip_h = true
	elif velocity.normalized().x < 0:
		Animations.flip_h = false

func _process(_delta: float) -> void:
	if Game_State:
		Game_State = false
	Game_Loop()

func _on_hurt_box_component_area_entered(area: Area2D) -> void:
	hitbox.knockback_direction.x = (area.get_parent().global_position - self.global_position).normalized().x
	area.get_parent().Hurtbox_component.take_hit(hitbox)
