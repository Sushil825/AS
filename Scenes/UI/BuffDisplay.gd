extends Control
@onready var buff_container: HBoxContainer = $HBoxContainer
@export var speed_boost_icon:Texture2D
@export var fireball_icon:Texture2D
@export var jump_boost_icon:Texture2D
@export var shield_icon:Texture2D
@export var health_icon:Texture2D
@export var double_jump_icon:Texture2D

func _ready() -> void:
	BuffManager.buff_applied.connect(_on_buff_applied)
	BuffManager.buff_expired.connect(_on_buff_expired)
	
	
func _on_buff_applied(buff_name:String,duration:float):
	
	var buff_item=create_buff_display(buff_name,duration)
	buff_container.add_child(buff_item)
	
	var tween=create_tween()
	tween.tween_method(func(time_left):_update_buff_timer(buff_item,time_left),duration,0.0,duration)
	
	
func create_buff_display(buff_name:String,duration:float)->Control:
	
	var container=VBoxContainer.new()
	container.name=buff_name
	
	var icon=TextureRect.new()
	icon.custom_minimum_size=Vector2(24,24)
	icon.expand_mode=TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	
	var icon_texture=get_icon_for_buff(buff_name)
	if icon_texture:
		icon.texture=icon_texture
	else:
		#Fallback to rect if no icon is retunred
		var image=Image.create(24,24,false,Image.FORMAT_RGB8)
		var color=get_color_for_buff(buff_name)
		image.fill(color)
		var texture=ImageTexture.create_from_image(image)
		icon.texture=texture
		
	var timer_label=Label.new()
	timer_label.text=str(int(duration))
	timer_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	timer_label.name="TimerLabel"
	container.add_child(icon)
	container.add_child(timer_label)
	
	return container
	
	
	
func get_icon_for_buff(buff_name:String)->Texture2D:
	match buff_name:
		"Speed Boost": return speed_boost_icon
		"Fireball": return fireball_icon
		"Jump Boost": return jump_boost_icon
		"Shield": return shield_icon
		"Health": return health_icon
		"Double Jump": return double_jump_icon
		_: return null



func get_color_for_buff(buff_name:String)->Color:
	match buff_name:
		"Speed Boost": return Color.GREEN
		"Fireball": return Color.ORANGE_RED
		"Jump Boost": return Color.SKY_BLUE
		"Shield": return Color.GOLD
		"Health": return Color.HOT_PINK
		"Double Jump": return Color.PURPLE
		_: return Color.WHITE
		
		

func _on_buff_expired(buff_name:String):
	var buff_item=buff_container.get_node_or_null(buff_name)
	if buff_item:
		buff_item.queue_free()
		
		
func _update_buff_timer(container:Control,time_left:float):
	
	if container and is_instance_valid(container):
		var timer_label=container.get_node("TimerLabel")
		if timer_label:
			timer_label.text=str(int(time_left))

	
