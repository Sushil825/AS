extends CharacterBody2D

#State enum
enum PlayerState{
	IDLE,
	MOVING,
	ATTACKING,
	JUMPING,
	DASHING,
	DODGING,
	PARRYING,
	STUNNED
}

@onready var dash_component: DashComponent = $CoreAbilities/DashComponent
@onready var parry_component: ParryComponent = $CoreAbilities/ParryComponent
@onready var attack_component : AttackComponent = $AttackComponent
@onready var dodge_component: DodgeComponent = $CoreAbilities/DodgeComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_component: MovementComponent = $MovementComponent
@onready var Hurtbox_component : HurtBoxComponent = $HurtBoxComponent
@onready var hurt_box_component: HurtBoxComponent = $HurtBoxComponent
@export var direction: Vector2 = Vector2.ZERO
@export var debug_mode:bool=false

var current_state:PlayerState=PlayerState.IDLE
var previous_state:PlayerState=PlayerState.IDLE

var Enemy : CharacterBody2D = null
var Attack_Type : AttackData.Type = AttackData.Type.LIGHT


func _ready() -> void:
	#Connect all the signal from the components
	attack_component.attack_performed.connect(_on_attack_performed)
	attack_component.attack_finished.connect(_on_attack_finished)
	dash_component.dash_started.connect(_on_dash_started)
	dash_component.dash_ended.connect(_on_dash_ended)
	dodge_component.dodge_started.connect(_on_dodge_started)
	dodge_component.dodge_ended.connect(_on_dodge_ended)
	parry_component.parry_successful.connect(_on_parry_successful)
	Hurtbox_component.area_entered.connect(func(area : Area2D): Enemy = area.get_parent())
	Hurtbox_component.area_exited.connect(func(_area : Area2D): Enemy = null)


func _physics_process(_delta: float) -> void:
	
	_get_input_direction()
	if debug_mode:
		print("Current_State: ",PlayerState.keys()[current_state],
				"Is Attacking: ",attack_component.get_is_attacking(),
				"IS Dashing: ",dash_component.is_dashing)
	
	match current_state:
		PlayerState.IDLE:
			handle_idle_state()
		PlayerState.MOVING:
			handle_moving_state()
		PlayerState.ATTACKING:
			handle_attacking_state()
		PlayerState.DASHING:
			handle_dashing_state()
		PlayerState.DODGING:
			handle_dodging_state()
		PlayerState.PARRYING:
			handle_parrying_state()
		PlayerState.STUNNED:
			handle_stunned_state()
		PlayerState.JUMPING:
			handle_jumping_state()


func _get_input_direction():
	direction=movement_component.get_direction()


func enter_state(state:PlayerState):
	
	if debug_mode:
		print("Entering State: ",PlayerState.keys()[state])
	
	match state:
		PlayerState.IDLE:
			animated_sprite_2d.play("idle")
		
		PlayerState.MOVING:
			animated_sprite_2d.flip_h = true if direction.x < 0 else false
			animated_sprite_2d.play("run")
		
		PlayerState.ATTACKING:
			if Enemy and Enemy.has_method("Take_Damage"):
				Enemy.Take_Damage(attack_component.light_attack_dmg if Attack_Type == AttackData.Type.LIGHT else attack_component.heavy_attack_dmg)
		
		PlayerState.JUMPING:
			animated_sprite_2d.flip_h = true if direction.x < 0 else false
			#Checking jump states in order
			if movement_component.is_on_ground() and movement_component.just_landed():
				animated_sprite_2d.play("jump_end")
			elif movement_component.is_in_air():
				animated_sprite_2d.play("in_air")
			elif movement_component.is_Jumping() or movement_component.just_jumped():
				animated_sprite_2d.play("jump_start")

func exit_state(state:PlayerState):
	if debug_mode:
		print("Exiting State: ",PlayerState.keys()[state])
	match state:
		PlayerState.PARRYING:
			pass
		PlayerState.ATTACKING:
			pass

func change_state(new_state:PlayerState):
	if current_state==new_state:
		return
	
	exit_state(current_state)
	previous_state=current_state
	current_state=new_state
	enter_state(new_state)


func _input(event: InputEvent) -> void:
	match current_state:
		PlayerState.IDLE,PlayerState.MOVING:
			
			if event.is_action_pressed("light_attack"):
				if attack_component.can_attack():
					change_state(PlayerState.ATTACKING)
					attack_component.perform_light_attack()
			elif event.is_action_pressed("heavy_attack"):
				if attack_component.can_attack():
					change_state(PlayerState.ATTACKING)
					attack_component.perform_heavy_attack()
			elif event.is_action_pressed("dash"):
				change_state(PlayerState.DASHING)
				dash_component.perform_dash(direction)
			elif event.is_action_pressed("dodge"):
				change_state(PlayerState.DODGING)
				dodge_component.perform_dodge()
			elif event.is_action_pressed("parry"):
				change_state(PlayerState.PARRYING)
				parry_component.attempt_parry()
				
		PlayerState.ATTACKING:
			if event.is_action_pressed("dash"):
				if dash_component.can_dash:
					attack_component.cancel_attack()
					change_state(PlayerState.DASHING)
					dash_component.perform_dash(direction)
					

#Handling Idle state

func handle_idle_state():
	if movement_component.get_direction().length()>0:
		change_state(PlayerState.MOVING)
	
	if movement_component.is_Jumping():
		change_state(PlayerState.JUMPING)
	
func handle_moving_state():
	if movement_component.get_direction().length()==0:
		change_state(PlayerState.IDLE)
	
	if movement_component.is_Jumping():
		change_state(PlayerState.JUMPING)
	
func handle_attacking_state():
	if attack_component.can_attack() and attack_component.is_attacking==false:
		change_state(PlayerState.IDLE)
	
	if movement_component.is_Jumping():
		change_state(PlayerState.JUMPING)
	
func handle_dashing_state():
	if not dash_component.is_dashing and self.direction.x!=0:
		change_state(PlayerState.MOVING)
	elif  not dash_component.is_dashing and self.direction.x==0:
		change_state(PlayerState.IDLE)
	
func handle_dodging_state():
	pass

func handle_parrying_state():
	pass
	
func handle_stunned_state():
	pass

func handle_jumping_state():
	if movement_component.is_on_ground():
		if movement_component.get_direction().length()>0:
			change_state(PlayerState.MOVING)
		
		if movement_component.get_direction().length()==0:
			change_state(PlayerState.IDLE)

func _on_attack_performed(attack_data):
	Attack_Type = attack_data.type
	match attack_data.type:
		AttackData.Type.LIGHT:
			animated_sprite_2d.play("light_attack")
		AttackData.Type.HEAVY:
			animated_sprite_2d.play("heavy_attack")
	
func _on_dash_started():
	if not dash_component.is_dashing:
		change_state(PlayerState.IDLE)
		
func _on_dash_ended():
	change_state(PlayerState.IDLE)

func _on_dodge_started():
	pass

func _on_dodge_ended():
	change_state(PlayerState.IDLE)

func _on_parry_successful(_attacker):
	pass

func _on_attack_finished():
	if debug_mode:
		print("Attack Finished signal received")
	if movement_component.get_direction().length()>0:
		change_state(PlayerState.MOVING)
	else:
		change_state(PlayerState.IDLE)
