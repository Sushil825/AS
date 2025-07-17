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
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_component: AttackComponent = $AttackComponent
@onready var parry_component: ParryComponent = $CoreAbilities/ParryComponent
@onready var dash_component: DashComponent = $CoreAbilities/DashComponent
@onready var dodge_component: DodgeComponent = $CoreAbilities/DodgeComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_movement_component: EnemyMovementComponent = $EnemyMovementComponent
@onready var detection_area: Area2D = $DetectionArea

#Toggleable abilities
@export var can_dash:bool=false
@export var can_dodge:bool=false
@export var can_parry:bool=false


#Combat
@export var current_weapon:WeaponResource
@export var enemy_attack:AttackData
@export var attack_range:float=50.0
@export var move_speed:float=80.0


#AI behavior for the swordsman
@export var idle_move_chance:float=0.3
@export var idle_move_interval:float=2.0
@export var attack_cooldown:float=2.0


#States management vars
var current_state:ENEMYSTATE=ENEMYSTATE.IDLE
var previous_state:ENEMYSTATE=ENEMYSTATE.IDLE
var can_change_state:bool=true



#Target

var player_target:Node2D=null
var last_attack_time:float=0.0


func _ready() -> void:
	
	setup_component()
	connect_signals()
	
	

func setup_component():
	if enemy_movement_component:
		enemy_movement_component.speed=80.0
		enemy_movement_component.acceleration=400.0
		enemy_movement_component.friction=600
		
		
	if health_component:
		health_component.max_health=100.0
		health_component.current_health=100.0

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

func _physics_process(delta: float) -> void:
	update_ai()
	
	update_animation()

func update_ai():
	
	match current_state:
		ENEMYSTATE.IDLE:
			if player_target:
				change_state(ENEMYSTATE.RUN)
				
		ENEMYSTATE.RUN:
			if not player_target:
				change_state(ENEMYSTATE.IDLE)
				return
				
			var distance=global_position.distance_to(player_target.global_position)
			
			if distance<=attack_range and can_attack():
				change_state(ENEMYSTATE.ATTACK)
			else:
				enemy_movement_component.move_towards(player_target.global_position)
			
		ENEMYSTATE.ATTACK:
			enemy_movement_component.stop_movement()
			
		ENEMYSTATE.STUNNED:
			enemy_movement_component.stop_movement()
			
		ENEMYSTATE.HURT:
			enemy_movement_component.stop_movement()

func can_attack():
	var current_time=Time.get_ticks_msec()/1000
	return current_time-last_attack_time>=attack_cooldown

func change_state(new_state:ENEMYSTATE):
	if not can_change_state:
		return
	
	previous_state=current_state
	current_state=new_state
	state_changed.emit(previous_state,current_state)
	
	match current_state:
		ENEMYSTATE.ATTACK:
			pass
		ENEMYSTATE.PARRY:
			pass
			
		ENEMYSTATE.DODGE:
			pass
		ENEMYSTATE.DASH:
			pass


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
	print("body")
	if body.is_in_group("player"):
		player_target=body
		player_detected.emit(body)

func _on_player_exited(body:Node2D):
	if body.is_in_group("player"):
		player_target=null

func _process(delta: float) -> void:
	pass
