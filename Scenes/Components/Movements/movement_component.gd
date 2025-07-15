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
	
	# motion in y axis
	if jump:
		Player.velocity.y = -jump_strenght
		jump = false
	
	Player.move_and_slide()
