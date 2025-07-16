extends CharacterBody2D

enum EnemyState
{
	SHELLIN,
	SHELLOUT,
	WALK,
	DEATH
}

var current_state: EnemyState = EnemyState.WALK
var Game_State : bool = true
var player : CharacterBody2D = null
var direction : Vector2 = Vector2.RIGHT


@export var gravity : int = 800
@export var Health : float
@export var speed : int = 25

@onready var Animations : AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_timer: Timer = $Timer

func OnAttack() -> void:
	pass

func Stats_Setter() -> void:
	pass

func Take_Damage_from_Goblin(Power : float) -> void:
	Health -= Power

func state_manager() -> void:
	pass

func Game_Loop() -> void :
	state_manager()
	
	match current_state:
		EnemyState.SHELLIN:
			Animations.play("shell_in")

		EnemyState.SHELLOUT:
			Animations.play("shell_out")
		
		EnemyState.DEATH:
			Animations.play("death")
			await Animations.animation_finished
			call_deferred("queue_free")
		
		EnemyState.WALK:
			if player:
				direction = (player.global_position - global_position).normalized()
				direction.x = round(direction.x)
				direction.y = 0
			else:
				if movement_timer.is_stopped():
					movement_timer.wait_time = randf_range(2.5,10)
					movement_timer.start()
					direction = Vector2.LEFT if direction == Vector2.RIGHT else Vector2.RIGHT
			velocity = direction * speed
			Animations.flip_h = true if velocity.normalized().x > 0 else false
			Animations.play("walk")
			move_and_slide()
				
			

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

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()
	if Game_State:
		Game_State = false
	Game_Loop()
