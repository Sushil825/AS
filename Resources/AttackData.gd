extends Resource
class_name AttackData

enum Type{
	LIGHT,
	HEAVY,
	SPECIAL
}

@export var damage:float
@export var type:Type
@export var range:float
@export var knockback_force:float
@export var animation_name:String
@export var sound_effect:AudioStream
@export var can_be_parried:bool=true
@export var can_be_dodged:bool=true
