extends Node


signal buff_applied(buff_name:String,duration:float)
signal  buff_expired(buff_name:String)


var active_buffs={}


func apply_buff(buff_type:DropItem.DropType,player):
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
		timer.wait_time=data.duration
		timer.one_shot=true
		timer.timeout.connect(_on_buff_expired.bind(buff_name,player,timer))
		timer.start()
		active_buffs[buff_name]=timer
		buff_applied.emit(buff_name,data.duration)



func remove_buff(buff_name:String,player):
	
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
