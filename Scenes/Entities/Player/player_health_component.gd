extends HealthComponent
@export var player:CharacterBody2D


func take_damage(damage:int)->bool:
	if current_health<=0 or player.has_shield:
		return false
	print("Health: ", current_health)
	current_health=max(0,current_health-damage)
	took_damage.emit(damage)
	health_changed.emit(current_health,max_health)
	
	if current_health<=0:
		died.emit()
		return true
	return false
