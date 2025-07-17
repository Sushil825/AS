extends Node2D
class_name EnemyMovementComponent


#Signals to help make better in the main enemy script
signal movement_started
signal movement_stopped
signal direction_changed(new_direction:Vector2)


@export var speed:float=100.0
@export var acceleration:float=500.0
@export var friction:float=800
@export var max_speed:float=200


var target_velocity:Vector2=Vector2.ZERO
var current_velocity:Vector2=Vector2.ZERO
var is_moving:bool=false
var movement_disabled:bool=false
var facing_direction:Vector2=Vector2.RIGHT

var character_body:CharacterBody2D
var prev_facing:Vector2=Vector2.RIGHT



func _ready() -> void:
	character_body=get_parent() as CharacterBody2D
	if not character_body:
		print("No characterbody")
		
		
func _physics_process(delta: float) -> void:
	
	if movement_disabled:
		return
		
	apply_movement(delta)
	update_facing_direction()
	check_movement_state()
	
	
	
func move_towards(target_position:Vector2):
	if movement_disabled:
		return
		
	var direction=(target_position-character_body.global_position).normalized()
	set_movement_direction(direction)
	
	
	
func set_movement_direction(direction:Vector2):
	
	if movement_disabled:
		return
	
	if direction !=Vector2.ZERO:
		var new_facing=direction.normalized()
		
		if new_facing !=facing_direction:
			facing_direction=new_facing
			direction_changed.emit(new_facing)
			
			
			
func stop_movement():
	target_velocity=Vector2.ZERO
	
	
func apply_movement(delta:float):
	
	if target_velocity.length()>0:
		current_velocity=current_velocity.move_toward(target_velocity,acceleration*delta)
	else:
		current_velocity=current_velocity.move_toward(Vector2.ZERO,friction*delta)
		
		
	#Clamping max speed
	
	if current_velocity.length()>max_speed:
		current_velocity=current_velocity.normalized()*max_speed
		
	character_body.velocity=current_velocity
	character_body.move_and_slide()



func update_facing_direction():
	
	if current_velocity.length()>10.0:
		var new_facing=current_velocity.normalized()
		if new_facing!=prev_facing:
			prev_facing=new_facing
			facing_direction=new_facing
			direction_changed.emit(new_facing)


func check_movement_state():
	var was_moving=is_moving
	
	is_moving=current_velocity.length()>5.0
	
	if was_moving!=is_moving:
		if is_moving:
			movement_started.emit()
		else:
			movement_started.emit()



func set_speed(new_speed:float):
	speed=new_speed
	
	
	
func disable_movement():
	movement_disabled=true
	stop_movement()
	
	
func enable_movement():
	movement_disabled=false
	
	
	
func is_moving_towards(target:Vector2):
	if current_velocity.length()==0:
		return false
		
	var direction_to_target=(target-character_body.global_position).normalized()
	return current_velocity.normalized().dot(direction_to_target)>0.7
