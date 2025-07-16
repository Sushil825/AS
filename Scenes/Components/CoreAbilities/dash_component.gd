extends Node
class_name DashComponent


signal dash_started
signal dash_ended

@export var dash_distance:float=100.0
@export var dash_duration:float=0.2
@export var dash_cooldown:float=1.0
@export var invulnerable_during_dash:bool=true
@export var player:CharacterBody2D
@export var sprite:AnimatedSprite2D

var can_dash:bool=true
var is_dashing:bool=false
var dash_tween:Tween


func _ready() -> void:
	
	pass

func perform_dash(direction:Vector2):
	
	if not can_dash or is_dashing or not  player:
		return
		
		
	#Normalize
	direction=direction.normalized()
	if direction==Vector2.ZERO:
		return
	can_dash=false
	is_dashing=true
	dash_started.emit()
	
	#Dash logic here
	
	start_dash_effect()
	#Perform dash
	await  dash_movement(direction)
	
	#End dash
	
	is_dashing=false
	end_dash_effect()
	dash_ended.emit()
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash=true



func dash_movement(direction:Vector2):
	
	var start_pos=player.global_position
	var target_pos=start_pos+direction*dash_distance
	
	#Create the tween for the transition
	
	dash_tween=create_tween()
	dash_tween.set_ease(Tween.EASE_OUT)
	dash_tween.set_trans(Tween.TRANS_QUART)
	
	#Tween the pos
	
	dash_tween.tween_property(player,"global_position",target_pos,dash_duration)
	await dash_tween.finished
	
	
	
func start_dash_effect():
	
	if not sprite or not sprite.material:
		return
		
	var shader_material=sprite.material as ShaderMaterial
	
	if not shader_material:
		return
	
	#Animating shader Parameters
	var effect_tween=create_tween()
	effect_tween.set_parallel(true)
	
	#Fade in
	
	effect_tween.tween_method(
		func(value):shader_material.set_shader_parameter("dash_intensity",value),
		0.0,1.0,dash_duration*0.1
	)
	
	create_afterimage()
	
	
	
func end_dash_effect():
	
	if not sprite or not sprite.material:
		return
		
	var shader_material=sprite.material as ShaderMaterial
	
	if not shader_material:
		return
		
	var effect_tween=create_tween()
	effect_tween.tween_method(
		func(value):shader_material.set_shader_parameter("dash_intensity",value),
		1.0,0.0,dash_duration*0.3
	)
	
func create_afterimage():
	
	var afterimage_count=8
	var afterimage_duration=dash_duration*1.5
	
	for i in range(afterimage_count):
		await get_tree().create_timer(dash_duration/afterimage_count).timeout
		spawn_afterimage(afterimage_duration)
		
		
		
func spawn_afterimage(duration:float):
	
	if not sprite:
		return
		
	var afterimage=AnimatedSprite2D.new()
	afterimage.sprite_frames=sprite.sprite_frames
	afterimage.animation=sprite.animation
	afterimage.frame=sprite.frame
	afterimage.global_position=sprite.global_position
	afterimage.flip_h=sprite.flip_h
	afterimage.modulate=Color(0.0,0.5,1.0,0.7)
	afterimage.z_index=sprite.z_index-1
	
	get_tree().current_scene.add_child(afterimage)
	
	var tween=create_tween()
	tween.tween_property(afterimage,"modulate:a",0.0,duration)
	tween.tween_callback(afterimage.queue_free)


#Helper Functions


func get_dash_state()->Dictionary:
	
	return{
		"can_dash":can_dash,
		"is_dashing":is_dashing,
		"is_invulnerable":is_dashing and invulnerable_during_dash
	}
