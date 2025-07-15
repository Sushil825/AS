extends Node
class_name AttackComponent

signal attack_performed(attack_data)
signal attack_hit(target,damage)
signal attack_finished()

@export var light_attack_dmg:float=10.0
@export var heavy_attack_dmg:float=25.0
@export var light_attack_duration:float=0.3
@export var heavy_attack_duration:float=0.5
@export var light_attack_cooldown:float=0.2
@export var heavy_attack_cooldown:float=0.3
@export var attack_range:float=50.0
var can_light_attack:bool=true
var can_heavy_attack:bool=true
var is_attacking:bool=false
#Can be changed thry resource if in need to change enemies or player weapon
var current_weapon:WeaponResource


#Attack Timers
var light_cooldown_timer:Timer
var heavy_cooldown_timer:Timer



func _ready() -> void:
	
	light_cooldown_timer=Timer.new()
	light_cooldown_timer.wait_time=light_attack_duration
	light_cooldown_timer.one_shot=true
	light_cooldown_timer.timeout.connect(_on_light_cooldown_finished)
	add_child(light_cooldown_timer)
	
	heavy_cooldown_timer=Timer.new()
	heavy_cooldown_timer.wait_time=heavy_attack_duration
	heavy_cooldown_timer.one_shot=true
	heavy_cooldown_timer.timeout.connect(_on_heavy_cooldown_finished)
	add_child(heavy_cooldown_timer)
	
	

func perform_light_attack():
	if not can_light_attack or is_attacking:
		return false
	
	is_attacking=true
	can_light_attack=false
	var attack_data=AttackData.new()
	attack_data.damage=light_attack_dmg
	attack_data.type=AttackData.Type.LIGHT
	attack_data.range=attack_range
	
	
	#Apply and mod 
	
	if current_weapon:
		attack_data.damage*=current_weapon.damage_multiplier

	
	attack_performed.emit(attack_data)
	
	
	await get_tree().create_timer(light_attack_duration).timeout
	_finish_attack()
	light_cooldown_timer.start()
	return true
	
	
func perform_heavy_attack():
	
	if not can_heavy_attack or is_attacking:
		return false
	
	is_attacking=true
	can_heavy_attack=false
	var attack_data=AttackData.new()
	attack_data.damage=heavy_attack_dmg
	attack_data.type=AttackData.Type.HEAVY
	attack_data.range=attack_range
	
	#Apply and mod 
	
	if current_weapon:
		attack_data.damage*=current_weapon.damage_multiplier
	
	attack_performed.emit(attack_data)
	
	
	await get_tree().create_timer(heavy_attack_duration).timeout
	_finish_attack()
	heavy_cooldown_timer.start()
	return true


func _finish_attack():
	is_attacking=false
	attack_finished.emit()
	
	
func _on_light_cooldown_finished():
	can_light_attack=true
	
func _on_heavy_cooldown_finished():
	can_heavy_attack=true


func cancel_attack():
	if is_attacking:
		is_attacking=false
		attack_finished.emit()
		
func can_attack()->bool:
	if not is_attacking:
		if can_light_attack or can_heavy_attack:
			return true
		else:
			return false
	else:
		return false
		
		
func get_is_attacking()->bool:
	return is_attacking
	
func set_weapon(weapon:WeaponResource):
	current_weapon=weapon
	
	if weapon:
		light_attack_dmg=weapon.light_attack_damage
		heavy_attack_dmg=weapon.heavy_attack_damage
		attack_range=weapon.attack_range
