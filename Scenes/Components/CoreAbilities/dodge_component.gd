extends Node
class_name DodgeComponent


signal dodge_started
signal dodge_ended

@export var dodge_duration:float=0.3
@export var dodge_cooldown:float=0.5
@export var invulnerable_during_dodge:bool=true
@export var player:CharacterBody2D
@export var sprite:AnimatedSprite2D
@export var flicker_speed:float=0.1
@export var dodge_color:Color=Color.WHITE
@export var transparency_amount:float=0.3



var can_dodge:bool=true
var is_dodging:bool=false
var original_mod:Color
var flicker_timer:Timer

func _ready() -> void:
	
	if sprite:
		original_mod=sprite.modulate
		
	flicker_timer=Timer.new()
	flicker_timer.wait_time=flicker_speed
	flicker_timer.timeout.connect(_on_flicker)
	add_child(flicker_timer)

func perform_dodge():
	
	if not can_dodge or is_dodging:
		return
		
	can_dodge=false
	is_dodging=true
	dodge_started.emit()
	start_dodge_effect()
	await get_tree().create_timer(dodge_duration).timeout
	is_dodging=false
	end_dodge_effect()
	dodge_ended.emit()
	
	
	#dodge logic to be written
	
	await get_tree().create_timer(dodge_cooldown).timeout
	can_dodge=true
	
	
	
func start_dodge_effect():
	
	if not sprite:
		return
		
	flicker_timer.start()
	var scale_tween=create_tween()
	scale_tween.set_parallel(true)
	scale_tween.tween_property(sprite,"scale",Vector2(1.1,1.1),dodge_duration*0.1)
	scale_tween.tween_property(sprite,"scale",Vector2.ONE,dodge_duration*0.9)
	

func end_dodge_effect():
	
	if not sprite:
		
		return
		
	flicker_timer.stop()
	
	sprite.modulate=original_mod
	sprite.scale=Vector2.ONE
	
	
	
func _on_flicker():
	
	if not is_dodging or not sprite:
		return
	#Alternate between white glow and transparent
	if sprite.modulate.a>0.0:
		sprite.modulate=Color(dodge_color.r,dodge_color.g,dodge_color.b,transparency_amount)
	else:
		sprite.modulate=Color(dodge_color.r*1.5,dodge_color.g*1.5,dodge_color.b*1.5,1.0)
