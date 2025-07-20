extends RigidBody2D
class_name DropItem

enum DropType{
	SPEED_BOOST,
	FIREBALL,
	JUMP_BOOST,
	SHIELD,
	HEALTH,
	DOUBLE_JUMP
}

@export var drop_type:DropType
@export var bounce_heigh:float=100
@onready var sprite: Sprite2D = $Sprite2D
@onready var detect: Area2D = $Detect

var velocity:Vector2
var grav:float=980.0
var bounce_decay:float=07
var is_on_ground:bool=false

var drop_data={
	DropType.SPEED_BOOST:{
		"name":"Speed Boost",
		"color":Color.GREEN,
		"duration":12.0,
		"texture":preload("res://Assets/buffs/speed.png")
	},
	DropType.FIREBALL:{
		"name":"Fireball",
		"color":Color.ORANGE_RED,
		"duration":12.0,
		"texture":preload("res://Assets/buffs/HQ fireball.png")
	},
	DropType.JUMP_BOOST:{
		"name":"Jump Boost",
		"color":Color.SKY_BLUE,
		"duration":12.0,
		"texture":preload("res://Assets/buffs/jump.png")
	},
	DropType.SHIELD:{
		"name":"Shield",
		"color":Color.SILVER,
		"duration":8.0,
		"texture":preload("res://Assets/buffs/shield.png")
	},
	DropType.HEALTH:{
		"name":"Health",
		"color":Color.HOT_PINK,
		"duration":0.0,
		"texture":preload("res://Assets/buffs/life.png")
	},
	DropType.DOUBLE_JUMP:{
		"name":"Double Jump",
		"color":Color.PURPLE,
		"duration":15.0,
		"texture":preload("res://Assets/buffs/double_jump.png")
	},
}


func _ready() -> void:
	
	setup_drop()
	detect.body_entered.connect(_on_body_entered)
	
	velocity.y=-bounce_heigh
	velocity.x=randf_range(-50,50)


func setup_drop():
	
	var data=drop_data[drop_type]
	sprite.texture=data.texture
	sprite.modulate=data.color
	


func _physics_process(delta: float) -> void:
	pass
	

func _on_body_entered(body):
	print("Body")
	
	if body.has_method("collect_drop"):
		body.collect_drop(drop_type, drop_data[drop_type]["texture"])
		
	queue_free()
		
		
