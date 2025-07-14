extends CharacterBody2D
@onready var dash_component: DashComponent = $CoreAbilities/DashComponent
@onready var parry_component: ParryComponent = $CoreAbilities/ParryComponent
@onready var attack_component: AttackComponent = $AttackComponent
@onready var dodge_component: DodgeComponent = $CoreAbilities/DodgeComponent
var direction:Vector2=Vector2.RIGHT

func _ready() -> void:
	#Connect all the signal from the components
	
	attack_component.attack_performed.connect(_on_attack_performed)
	dash_component.dash_started.connect(_on_dash_started)
	dodge_component.dodge_started.connect(_on_dodge_started)
	parry_component.parry_successful.connect(_on_parry_successful)


func _get_input_direction():
	if Input.is_action_pressed("a"):
		direction=Vector2.LEFT
	elif Input.is_action_pressed("d"):
		direction=Vector2.RIGHT

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		attack_component.perform_light_attack()
	elif event.is_action_pressed("heavy_attack"):
		attack_component.perform_heavy_attack()
	elif event.is_action_pressed("dash"):
		dash_component.peerform_dash(direction)
	elif event.is_action_pressed("dodge"):
		dodge_component.peerform_dodge()
	elif event.is_action_pressed("parry"):
		parry_component.attempt_parry()

func _on_attack_performed(attack_data):
	pass
	
func _on_dash_started():
	pass
	
func _on_dodge_started():
	pass
	
func _on_parry_successful(attacker):
	pass
