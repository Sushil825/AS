extends Node


signal buff_applied(buff_name:String,duration:float)
signal  buff_expired(buff_name:String)


var active_buffs={}
var buffTimer : Timer = null
var Player : CharacterBody2D = null

func _process(delta: float) -> void:
	if buffTimer and !buffTimer.is_stopped():
		Player.buff_display.setText(buffTimer.time_left)

func apply_buff(buff_type:DropItem.DropType, player :CharacterBody2D , image:CompressedTexture2D):
	
	var data=DropItem.new().drop_data[buff_type]
	var buff_name=data.name
	
	if active_buffs.has(buff_name):
		remove_buff(buff_name,player)
		
		
	match buff_type:
		DropItem.DropType.SPEED_BOOST:
			player.speed_multiplier=1.8
		DropItem.DropType.FIREBALL:
			player.has_fireball=true
			
		DropItem.DropType.JUMP_BOOST:
			player.jump_mult=1.5
			
		DropItem.DropType.SHIELD:
			player.has_shield=true
			
		DropItem.DropType.HEALTH:
			player.heal(40)
			return
			
		DropItem.DropType.DOUBLE_JUMP:
			player.has_double_jump=true
			
			
	if data.duration>0:
		var timer=Timer.new()
		add_child(timer)
		buffTimer = timer
		Player = player
		Player.buff_display.ToggleVisibility(true)
		Player.buff_display.setTexture(image)
		timer.wait_time=data.duration
		timer.one_shot=true
		timer.timeout.connect(_on_buff_expired.bind(buff_name,player,timer))
		timer.start()
		active_buffs[buff_name]=timer
		buff_applied.emit(buff_name,data.duration)



func remove_buff(buff_name:String, player:CharacterBody2D):
	Player.buff_display.ToggleVisibility(false)
	buffTimer = null
	Player = null
	
	if not active_buffs.has(buff_name):
		return
		
	var timer=active_buffs[buff_name]
	timer.queue_free()
	active_buffs.erase(buff_name)
	
	
	if not is_instance_valid(player):
		buff_expired.emit(buff_name)
		return
	
	match buff_name:
		"Speed Boost":
			player.speed_multiplier=1.0
		"Fireball":
			player.has_fireball=false
		"Jump Boost":
			player.jump_mult=1.0
		"Shield":
			player.has_shield=false
			
		"Double Jump":
			player.has_double_jump=false
			
	buff_expired.emit(buff_name)
	
	
	
func _on_buff_expired(buff_name:String,player,timer:Timer):
	
	remove_buff(buff_name,player)
