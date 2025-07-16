# Component for players Movement
extends Node2D
class_name MovementComponent

@export var Player : CharacterBody2D
@export var Jump_Buffer : Timer
@export var Animations_node : AnimatedSprite2D

@export var speed : int = 200
@export var acceleration : int = 700
@export var friction : int = 900
@export var jump_strenght : int = 300
@export var gravity : int = 800
@export var terminal_velocity : int = 500

@onready var Animations : AnimatedSprite2D = Animations_node

var direction : Vector2 = Vector2.ZERO
var jump: bool = false
var faster_fall : bool = false


#Vars to handle to track jump states
var was_on_floor_last_frame:bool=false
var was_in_air_last_frame:bool=false
var jump_started_this_frame:bool=false
var landed_this_frame:bool=false

func get_direction() -> Vector2:
	return direction

func is_Jumping() -> bool:
	return Player.velocity.y < 0 and not Player.is_on_floor()

func is_in_air() -> bool:
	return Player.velocity.y > 0 and not Player.is_on_floor()

func is_on_ground() -> bool:
	return Player.is_on_floor()

func just_jumped()->bool:
	return jump_started_this_frame
	
func just_landed()->bool:
	return landed_this_frame
	

func _process(delta: float) -> void:
	
	var was_on_floor=was_on_floor_last_frame
	var was_in_air=was_in_air_last_frame
	
	jump_started_this_frame=false
	landed_this_frame=false
	
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
	
	#Detecing landing
	if not was_on_floor and Player.is_on_floor():
		landed_this_frame=true
	
	#Update vars for next frame
	
	was_on_floor_last_frame=Player.is_on_floor()
	was_in_air_last_frame=not Player.is_on_floor() and Player.velocity.y>0
