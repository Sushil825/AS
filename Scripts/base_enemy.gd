extends CharacterBody2D
class_name Enemy


@export var enemy_type:String="boar" #boar snail swordsman bee
@export var drop_scene:PackedScene=preload("res://Scenes/Components/drop_item.tscn")


var drop_chances={
	"boar":[
		{"type":DropItem.DropType.SPEED_BOOST,"chance":0.5},
		{"type":DropItem.DropType.HEALTH,"chance":0.4},
		{"type":DropItem.DropType.SHIELD,"chance":0.2}
	],
	"snail":[
		{"type":DropItem.DropType.JUMP_BOOST,"chance":0.5},
		{"type":DropItem.DropType.DOUBLE_JUMP,"chance":0.3},
		{"type":DropItem.DropType.HEALTH,"chance":0.2}
	],
	"swordsman":[
		{"type":DropItem.DropType.DOUBLE_JUMP,"chance":0.4},
		{"type":DropItem.DropType.SHIELD,"chance":0.2},
		{"type":DropItem.DropType.SPEED_BOOST,"chance":0.4}
	],
	"bee":[
		{"type":DropItem.DropType.DOUBLE_JUMP,"chance":0.5},
		{"type":DropItem.DropType.JUMP_BOOST,"chance":0.3},
		{"type":DropItem.DropType.FIREBALL,"chance":0.2}
	]
}



func die():
	spawn_drop()
	call_deferred("queue_free")
	
	
	
	
func spawn_drop():
	randomize()
	
	var possible_drops=drop_chances.get(enemy_type,[])
	
	for drop_data in possible_drops:
		
		if randf()<=drop_data.chance:
			var drop=drop_scene.instantiate()
			drop.drop_type=drop_data.type
			drop.global_position=global_position+Vector2(0,-20)
			get_parent().add_child(drop)
			break
			
