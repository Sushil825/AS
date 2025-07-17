extends CharacterBody2D


enum ENEMYSTATE{
	IDLE,
	RUN,
	ATTACK,
	PARRY,
	DODGE,
	DASH,
	STUNNED	
}

@onready var movement_component: MovementComponent = $MovementComponent
@onready var hurt_box_component: HurtBoxComponent = $HurtBoxComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_component: AttackComponent = $AttackComponent
@onready var parry_component: ParryComponent = $CoreAbilities/ParryComponent
@onready var dash_component: DashComponent = $CoreAbilities/DashComponent
@onready var dodge_component: DodgeComponent = $CoreAbilities/DodgeComponent


@export var can_dash:bool=false
@export var can_dodge:bool=false
@export var can_parry:bool=false


var current_state:ENEMYSTATE=ENEMYSTATE.IDLE
var previous_state:ENEMYSTATE=ENEMYSTATE.IDLE


func _ready() -> void:
	
	pass
	
	
	
func _process(delta: float) -> void:
	pass
