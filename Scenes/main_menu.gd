extends CanvasLayer

@onready var new_game : Button = $"PanelContainer/MarginContainer/HBoxContainer/HBoxContainer/New Game"
@onready var options : Button = $"PanelContainer/MarginContainer/HBoxContainer/HBoxContainer/Options"
@onready var quit : Button = $"PanelContainer/MarginContainer/HBoxContainer/HBoxContainer/Quit"
@onready var instructions_panel: PanelContainer = $"Instructions Panel"

func _ready() -> void:
	instructions_panel.visible = false

func change_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/TileSet/jungle_map.tscn")

func _on_new_game_pressed() -> void:
	call_deferred("change_scene")

func _on_options_pressed() -> void:
	instructions_panel.visible = true
	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_toggle_instructions_pressed() -> void:
	instructions_panel.visible = false
	
