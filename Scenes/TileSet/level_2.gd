extends Node2D

@onready var player: CharacterBody2D = $Main/Player
@onready var player_died: CanvasLayer = $Player_Died

func _on_change_scene_body_entered(_body: CharacterBody2D) -> void:
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/TileSet/level_3.tscn")

func _ready() -> void:
	player_died.visible = false
	player.healthComponent.died.connect(func(): player_died.visible = true)
