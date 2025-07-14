extends Node
class_name ParryComponent

signal parry_attempted
signal parry_successful(attacker)
signal parry_failed


@export var parry_window:float=0.2
@export var parry_cooldown:float=0.5

var can_parry:bool=true
var parry_active:bool=false

func attempt_parry():
	if not can_parry:
		return
	
	can_parry=false
	parry_active=true
	parry_attempted.emit()
	
	await get_tree().create_timer(parry_window).timeout
	if parry_active:
		parry_active=false
		parry_failed.emit()
		
	await get_tree().create_timer(parry_cooldown).timeout
	can_parry=true
	
	
func try_parry_attack(attacker)->bool:
	if parry_active:
		parry_active=false
		parry_successful.emit(attacker)
		return true
	return false
