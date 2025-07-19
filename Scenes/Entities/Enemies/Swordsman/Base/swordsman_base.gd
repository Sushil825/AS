extends CharacterBody2D


enum ENEMYSTATE{
	IDLE,
	RUN,
	ATTACK,
	PARRY,
	DODGE,
	DASH,
	STUNNED,
	HURT
}

#Signals
signal state_changed(old_state:ENEMYSTATE,new_state:ENEMYSTATE)
signal enemy_died
signal player_detected(player:Node2D)



#Components
@onready var hurt_box_component: HurtBoxComponent = $HurtBoxComponent
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_component: AttackComponent = $AttackComponent
@onready var parry_component: ParryComponent = $CoreAbilities/ParryComponent
@onready var dash_component: DashComponent = $CoreAbilities/DashComponent
@onready var dodge_component: DodgeComponent = $CoreAbilities/DodgeComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_movement_component: EnemyMovementComponent = $EnemyMovementComponent
@onready var detection_area: Area2D = $DetectionArea
@onready var texture_progress_bar: TextureProgressBar = $Control/TextureProgressBar

#Toggleable abilities
@export var can_dash:bool=false
@export var can_dodge:bool=false
@export var can_parry:bool=false
@export var debug_mode:bool=false

#Combat
@export var current_weapon:WeaponResource
@export var enemy_attack:AttackData
@export var attack_range:float=50.0
@export var move_speed:float=80.0


#AI behavior for the swordsman
@export var idle_move_chance:float=0.3
@export var idle_move_interval:float=2.0
@export var attack_cooldown:float=2.0
@export var pursuit_range:float=200.0
@export var dodge_chance:float=0.3
@export var parry_chance:float=0.2
@export var attack_duration:float=1.0


#States management vars
var current_state:ENEMYSTATE=ENEMYSTATE.IDLE
var previous_state:ENEMYSTATE=ENEMYSTATE.IDLE
var can_change_state:bool=true


#Target

var player_target:Node2D=null
var last_attack_time:float=0.0
var state_timer:float=0.0
var idle_timer:float=0.0
var attack_start_time:float=0.0


#AI behaviorus
var initial_position:Vector2
var patrol_points:Array[Vector2]=[]
var current_patrol_index:int=0

var player : CharacterBody2D = null

func _ready() -> void:
	
	setup_component()
	connect_signals()
	initial_position=global_position
	setup_patrol_points()
	
	

func setup_patrol_points():
	patrol_points.clear()
	patrol_points.append(initial_position+Vector2(-50,0))
	patrol_points.append(initial_position+Vector2(50,0))
	patrol_points.append(initial_position+Vector2(0,-50))
	patrol_points.append(initial_position+Vector2(0,-50))

func setup_component():
	if enemy_movement_component:
		enemy_movement_component.speed=80.0
		enemy_movement_component.acceleration=400.0
		enemy_movement_component.friction=600
		
		
	if health_component:
		health_component.max_health=100.0
		health_component.current_health=100.0


func take_damage(damage:float):
	pass

func connect_signals():
	if attack_component:
		attack_component.attack_performed.connect(_on_attack_performed)
		attack_component.attack_hit.connect(_on_attack_hit)
		attack_component.attack_finished.connect(_on_attack_finished)
	if dash_component:
		dash_component.dash_started.connect(_on_dash_started)
		dash_component.dash_ended.connect(_on_dash_ended)
	
	#Add the dodge logic too ,now ddodge component misssing
	
	
	#Same with parry component
	
	
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)
		
		
	if enemy_movement_component:
		enemy_movement_component.movement_started.connect(_on_movement_started)
		enemy_movement_component.movement_stopped.connect(_on_movement_stopped)
		enemy_movement_component.direction_changed.connect(_on_direction_changed)

	
	if detection_area:
		detection_area.body_entered.connect(_on_player_entered)
		detection_area.body_exited.connect(_on_player_exited)
	
	if hurt_box_component:
		hurt_box_component.area_entered.connect(func(area: Area2D): player = area.get_parent())
		hurt_box_component.area_exited.connect(func(area: Area2D): player = null)
		

func _physics_process(delta: float) -> void:
	state_timer+=delta
	idle_timer+=delta
	update_ai(delta)
	update_animation()
	

func update_ai(delta:float):
	match current_state:
		ENEMYSTATE.IDLE:
			handle_idle_state(delta)
		ENEMYSTATE.RUN:
			handle_run_state(delta)
			
		ENEMYSTATE.ATTACK:
			handle_attack_state(delta)
			
		ENEMYSTATE.STUNNED:
			handle_stunned_state(delta)
			
		ENEMYSTATE.HURT:
			handle_hurt_state(delta)

func handle_idle_state(delta:float):
	if enemy_movement_component:
		enemy_movement_component.stop_movement()
		
	#Check for player
	if player_target and is_instance_valid(player_target):
		change_state(ENEMYSTATE.RUN)
		return
		
		
	#Random movement when idle
	
	if idle_timer>=idle_move_interval:
		idle_timer=0
		if randf()<idle_move_chance and patrol_points.size()>0:
			var target_point=patrol_points[current_patrol_index]
			current_patrol_index=(current_patrol_index+1)%patrol_points.size()
			if enemy_movement_component:
				enemy_movement_component.move_towards(target_point)
				
				
				
func handle_run_state(delta:float):
	if not player_target or not is_instance_valid(player_target):
		change_state(ENEMYSTATE.IDLE)
		return
		
	var distance=global_position.distance_to(player_target.global_position)
	
	if distance>pursuit_range:
		change_state(ENEMYSTATE.IDLE)
		return
		
	if distance<=attack_range and can_attack():
		#ADD dodge and parry here ig
		
		
		change_state(ENEMYSTATE.ATTACK)
		
	else:
		if enemy_movement_component:
			enemy_movement_component.move_towards(player_target.global_position)
		

func handle_attack_state(delta:float):
	
	if enemy_movement_component:
		enemy_movement_component.stop_movement()
		
	if state_timer<0.1:#Small delay
		perform_attack()
		
	if state_timer>=attack_duration:
		if player_target and is_instance_valid(player_target):
			var distance=global_position.distance_to(player_target.global_position)
			if distance<=pursuit_range:
				change_state(ENEMYSTATE.RUN)
			else:
				change_state(ENEMYSTATE.IDLE)
				
		else:
			change_state(ENEMYSTATE.IDLE)
			
			

func handle_stunned_state(delta:float):
	enemy_movement_component.stop_movement()
	
	if state_timer>=2.0:
		if player_target and is_instance_valid(player_target):
			change_state(ENEMYSTATE.RUN)
		else:
			change_state(ENEMYSTATE.IDLE)
			
			
func handle_hurt_state(delta:float):
	enemy_movement_component.stop_movement()
	if state_timer>=0.5:
		if player_target and is_instance_valid(player_target):
			change_state(ENEMYSTATE.RUN)
		else:
			change_state(ENEMYSTATE.IDLE)

func can_attack():
	var current_time=Time.get_ticks_msec()/1000
	return current_time-last_attack_time>=attack_cooldown

func change_state(new_state:ENEMYSTATE):
	if not can_change_state:
		return
	
	previous_state=current_state
	current_state=new_state
	
	state_timer=0
	match current_state:
		ENEMYSTATE.IDLE:
			enemy_movement_component.stop_movement()
			
		ENEMYSTATE.RUN:
			pass
		ENEMYSTATE.ATTACK:
			attack_start_time=Time.get_ticks_msec()/1000
		ENEMYSTATE.PARRY:
			pass
			
		ENEMYSTATE.DODGE:
			pass
		ENEMYSTATE.DASH:
			if dash_component and player_target:
				var dash_direction=(player_target.global_position-global_position).normalized()
				dash_component.perform_dash(dash_direction)
	state_changed.emit(previous_state,current_state)

func perform_attack():
	if attack_component and enemy_attack:
		attack_component.perform_light_attack()
		last_attack_time=Time.get_ticks_msec()/1000

func update_animation():
	if not animated_sprite_2d:
		return
		
	match  current_state:
		ENEMYSTATE.IDLE:
			animated_sprite_2d.play("idle")
		ENEMYSTATE.RUN:
			animated_sprite_2d.play("run")
		ENEMYSTATE.ATTACK:
			animated_sprite_2d.play("side_attack")
			if player:
				hit_box_component.knockback_direction.x = (player.global_position - self.global_position).normalized().x
				player.Hurtbox_component.take_hit(hit_box_component)
			await animated_sprite_2d.animation_finished
			
	if player_target:
		animated_sprite_2d.flip_h=player_target.global_position.x<global_position.x

func _on_attack_performed(attack_data:AttackData):
	pass
func _on_attack_hit(target:Node2D,damage:float):
	pass
func _on_attack_finished():
	pass
func _on_dash_started():
	pass
func _on_dash_ended():
	pass
func _on_health_changed(old_health:float,new_health:float):
	pass
	
func _on_died():
	enemy_died.emit()
	queue_free()

func _on_movement_started():
	pass
	
func _on_movement_stopped():
	pass

func _on_direction_changed(new_direction:Vector2):
	pass
	
	
func _on_player_entered(body:Node2D):
	if body.is_in_group("player"):
		player_target=body
		player_detected.emit(body)
		if current_state==ENEMYSTATE.IDLE:
			change_state(ENEMYSTATE.RUN)

func _on_player_exited(body:Node2D):
	if body.is_in_group("player"):
		player_target=null

func _process(delta: float) -> void:
	pass

func Take_Damage(Power : float) -> void:
	health_component.take_damage(Power)
