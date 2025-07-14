class_name HealthComponent
extends Node2D

signal health_changed(current_health:int,max_health:int)
signal died
signal took_damage(damage:int)


@export var max_health:int=300
var current_health:int

func _ready():
	current_health=max_health
	
func take_damage(damage:int)->bool:
	if current_health<=0:
		return false
		
	current_health=max(0,current_health-damage)
	took_damage.emit(damage)
	health_changed.emit(current_health,max_health)
	
	if current_health<=0:
		died.emit()
		return true
	return false


func heal(amount:int):
	current_health=min(max_health,current_health+amount)
	health_changed.emit(current_health,max_health)
	
	
func is_dead()->bool:
	return current_health<0
