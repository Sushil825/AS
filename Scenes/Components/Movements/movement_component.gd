# Component for players Movement
extends Node2D

@export var Player : CharacterBody2D

@export var speed : int = 200
@export var acceleration : int = 700
@export var friction : int = 900
@export var jump_strenght : int = 300
@export var gravity : int = 600

var direction : Vector2 = Vector2.ZERO
var jump: bool = false
var is_jumping:bool=false

func _process(delta: float) -> void:
	#gravity
	Player.velocity.y += gravity * delta
	
	#taking input 
	direction.x = Input.get_axis("left","right")
	if Input.is_action_just_pressed("jump"):
		jump = true
	
	#motion in x axis
	if direction.x:
		Player.velocity.x = move_toward(Player.velocity.x , direction.x * speed , acceleration * delta)
	else:
		Player.velocity.x = move_toward(Player.velocity.x, 0, friction * delta)
	
	#Check if the player is in air
	
	check_jumping()
	
	# motion in y axis
	if jump and not is_jumping:
		Player.velocity.y = -jump_strenght
		jump = false
		
	
	Player.move_and_slide()



func check_jumping():
	if Player.is_on_floor():
		is_jumping=false
	else:
		is_jumping=true
		
		
func get_direction()->Vector2:
	return direction
