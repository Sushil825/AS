extends Area2D
class_name HitBoxComponent

@export var damage:int=10
@export var knockback_force:float=200
@export var knockback_direction:Vector2=Vector2.RIGHT
@export var hit_tags:Array[String]=["enemy"]
@export var active_time:float=0.2


var is_active:bool=false
var hit_targets:Array[HurtBoxComponent]=[]


func _ready():
	monitoring=false
	area_entered.connect(_on_area_entered)
	
func activate():
	
	if is_active:
		return
		
	is_active=true
	monitoring=true
	hit_targets.clear()
	
	var timer=Timer.new()
	timer.wait_time=active_time
	timer.one_shot=true
	timer.timeout.connect(_deactivate)
	add_child(timer)
	timer.start()
	
	
func _deactivate():
	is_active=false
	monitoring=false
	
	
func _on_area_entered(area:Area2D):
	
	if area is HurtBoxComponent:
		var hurtbox=area as HurtBoxComponent
		if can_hit(hurtbox):
			hit_targets.append(hurtbox)


func can_hit(hurtbox:HurtBoxComponent)->bool:
	if not is_active:
		return false
		
	if hurtbox in hit_targets:
		return false
		
	var parent=hurtbox.get_parent()
	if parent.has_method("get_tags"):
		var target_tags=parent.get_tags()
		for tag in hit_tags:
			if tag in target_tags:
				return true
				
	return false
