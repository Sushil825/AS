extends Area2D
class_name HurtBoxComponent

@export var health_component:HealthComponent
@export var knockback_force:float=100
@export var invincibility_duration:float=0.2

var is_invincible:bool=false
var invincibility_timer:Timer


func _ready() -> void:
	
	area_entered.connect(_on_area_entered)
	
	invincibility_timer=Timer.new()
	invincibility_timer.wait_time=invincibility_duration
	invincibility_timer.one_shot=true
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	add_child(invincibility_timer)
	
	
func _on_area_entered(area:Area2D):
	if is_invincible:
		return
	if area is HitBoxComponent:
		var hitbox=area as HitBoxComponent
		if hitbox.can_hit(self):
			take_hit(hitbox)
			
			
func take_hit(hitbox:HitBoxComponent):
	if not health_component:
		return
	var damage=hitbox.damage
	var knockback=hitbox.knockback_force
	var direction=hitbox.knockback_direction
	health_component.take_damage(damage)
	
	var parent=get_parent()
	if parent is CharacterBody2D and knockback>0:
		parent.velocity+=direction*knockback
		
		
	start_invincibility()
	create_hit_effect()
	
	
	
func start_invincibility():
	is_invincible=true
	invincibility_timer.start()
	var tween=create_tween()
	tween.tween_method(_flash_sprite,0.0,1.0,invincibility_duration)

func _flash_sprite(progress:float):
	var parent=get_parent()
	if parent.has_method("get_sprite"):
		var sprite=parent.get_sprite()
		sprite.modulate.a=0.5+sin(progress*20)*0.3
		
		
func _on_invincibility_timeout():
	is_invincible=false
	var parent=get_parent()
	if parent.has_method("get_sprite"):
		var sprite=parent.get_sprite()
		sprite.modulate.a=1.0
		
		
func create_hit_effect():
	if get_viewport().get_camera_2d():
		var camera=get_viewport().get_camera_2d()
		if camera.has_method("shake"):
			camera.shake(0.1,5.0)
