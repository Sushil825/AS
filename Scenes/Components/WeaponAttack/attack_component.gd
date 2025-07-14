extends Node
class_name AttackComponent

signal attack_performed(attack_data)
signal attack_hit(target,damage)

@export var light_attack_dmg:float=10.0
@export var heavy_attack_dmg:float=25.0
@export var light_attack_cooldown:float=0.2
@export var heavy_attack_cooldown:float=0.3
@export var attack_range:float=50.0
var can_light_attack:bool=true
var can_heavy_attack:bool=true
var current_weapon:WeaponResource


func perform_light_attack():
	if not can_light_attack:
		return
		
	can_light_attack=false
	var attack_data=AttackData.new()
	attack_data.damage=light_attack_dmg
	attack_data.type=AttackData.Type.LIGHT
	attack_data.range=attack_range
	
	attack_performed.emit(attack_data)
	
	
	await get_tree().create_timer(light_attack_cooldown).timeout
	can_light_attack=true
	
	
func perform_heavy_attack():
	
	if not can_heavy_attack:
		return
		
	can_heavy_attack=false
	var attack_data=AttackData.new()
	attack_data.damage=heavy_attack_dmg
	attack_data.type=AttackData.Type.HEAVY
	attack_data.range=attack_range
	
	attack_performed.emit(attack_data)
	
	
	await get_tree().create_timer(heavy_attack_dmg).timeout
	can_light_attack=true
