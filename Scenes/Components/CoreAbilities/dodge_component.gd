extends Node
class_name DodgeComponent


signal dodge_started
signal dodge_ended

@export var dodge_duration:float=0.3
@export var dodge_cooldown:float=0.5
@export var invulnerable_during_dodge:bool=true

var can_dodge:bool=true
var is_dodging:bool=false

func peerform_dodge():
	
	if not can_dodge or is_dodging:
		return
		
	can_dodge=false
	is_dodging=true
	dodge_started.emit()
	await get_tree().create_timer(dodge_duration).timeout
	is_dodging=false
	dodge_ended.emit()
	
	
	#dodge logic to be written
	
	await get_tree().create_timer(dodge_cooldown).timeout
	can_dodge=true
	
	
	
