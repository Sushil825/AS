extends PanelContainer

func _ready() -> void:
	self.visible = false

func _on_button_pressed() -> void:
	self.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Toggle quit"):
		self.visible = true

func change_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_quit_pressed() -> void:
	call_deferred("change_scene")
