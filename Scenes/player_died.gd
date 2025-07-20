extends CanvasLayer

func _on_retry_pressed() -> void:
	call_deferred("change_scene","res://Scenes/TileSet/jungle_map.tscn")

func _on_main_menu_pressed() -> void:
	call_deferred("change_scene","res://Scenes/main_menu.tscn")

func change_scene(location : String) -> void:
	get_tree().change_scene_to_file(location)
