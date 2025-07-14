extends Node
class_name DashComponent


signal dash_started
signal dash_ended

@export var dash_distance:float=100.0
@export var dash_duration:float=0.2
@export var dash_cooldown:float=1.0
@export var invulnerable_during_dash:bool=true

var can_dash:bool=true
var is_dashing:bool=false

func peerform_dash(direction:Vector2):
	
	if not can_dash or is_dashing:
		return
		
	can_dash=false
	is_dashing=true
	dash_started.emit()
	
	#Dash logic here
	
	await get_tree().create_timer(dash_duration).timeout
	is_dashing=false
	dash_ended.emit()
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash=true
	
	
	
