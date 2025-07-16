# Component for players Movement
extends Node2D
class_name MovementComponent

@export var Player : CharacterBody2D
@export var Jump_Buffer : Timer

@export var speed : int = 200
@export var acceleration : int = 700
@export var friction : int = 900
@export var jump_strenght : int = 300
@export var gravity : int = 800
@export var terminal_velocity : int = 500

var direction : Vector2 = Vector2.ZERO
var jump: bool = false
var faster_fall : bool = false

func get_direction() -> Vector2:
	return direction

func _process(delta: float) -> void:
	#gravity
	Player.velocity.y += gravity * delta
	Player.velocity.y = Player.velocity.y / 2 if faster_fall and Player.velocity.y < 0 else Player.velocity.y
	Player.velocity.y = min(Player.velocity.y, terminal_velocity)
	
	#taking input 
	direction.x = Input.get_axis("left","right")
	
	if Input.is_action_just_pressed("jump"):
		if Player.is_on_floor():
			jump = true
		if Player.velocity.y > 0 and not Player.is_on_floor():
			Jump_Buffer.start()
	
	if Input.is_action_just_released("jump") and not Player.is_on_floor() and Player.velocity.y < 0:
		faster_fall = true
	
	#motion in x axis
	if direction.x:
		Player.velocity.x = move_toward(Player.velocity.x , direction.x * speed , acceleration * delta)
	else:
		Player.velocity.x = move_toward(Player.velocity.x, 0, friction * delta)
	
	# motion in y axis
	if jump or Jump_Buffer.time_left and Player.is_on_floor():
		Player.velocity.y = -jump_strenght
		jump = false
		faster_fall = false
	
	Player.move_and_slide()
