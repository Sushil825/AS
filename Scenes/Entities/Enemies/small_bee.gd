extends CharacterBody2D

enum states
{
	fly,
	attack,
	take_damage,
	death
}

@onready var Animations : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitBoxComponent = $HitBoxComponent
@onready var Hurtbox_component : HurtBoxComponent = $HurtBoxComponent

var health : float = 125
var direction : Vector2 = Vector2.LEFT
var speed : int = 100

var GameLoop : bool = true
var changeMovement : bool = true
var canAttack : bool = false
var playerInRange: bool = false
var takeDamage: bool = false

var current_state : states = states.fly
var player : CharacterBody2D = null

func _ready() -> void:
	$"Movement Timer".start()
	$"Attack Delay".start()

func _physics_process(_delta: float) -> void:
	if GameLoop:
		GameLoop = false
		Enemy_States()

func Enemy_States() -> void:
	if health <= 0:
		current_state = states.death
	elif takeDamage:
		current_state = states.take_damage
	elif canAttack and playerInRange:
		current_state = states.attack
	else:
		current_state = states.fly
	
	match current_state:
		states.fly:
			Animations.play("fly")
			if player:
				direction.x = (player.global_position - self.global_position).normalized().x
			else:
				if changeMovement:
					changeMovement = false
					direction = [Vector2.RIGHT, Vector2.LEFT].pick_random()
					$"Movement Timer".start()
				
			if direction.x > 0:
				Animations.flip_h = true
			elif direction.x < 0:
				Animations.flip_h = false
				
			velocity = direction * speed
			move_and_slide()
			
		states.attack:
			Animations.play("attack")
			canAttack = false
			$"Attack Delay".start()
			if player:
				hitbox.knockback_direction.x = (player.global_position - self.global_position).normalized().x
				player.Hurtbox_component.take_hit(hitbox)
			await Animations.animation_finished
			
		states.take_damage:
			takeDamage = false
			Animations.play("hit")
			await Animations.animation_finished
			
		states.death:
			Animations.play("hit")
			await Animations.animation_finished
			call_deferred("queue_free")
	
	GameLoop = true
			

func Take_Damage(Power : float) -> void:
	health -= Power
	takeDamage = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body

func _on_detection_area_body_exited(_body: Node2D) -> void:
	player = null

func _on_movement_timer_timeout() -> void:
	changeMovement = true

func _on_attack_delay_timeout() -> void:
	canAttack = true

func _on_hurt_box_component_area_entered(_area: Area2D) -> void:
	playerInRange = true
	
func _on_hurt_box_component_area_exited(_area: Area2D) -> void:
	playerInRange = false
