extends Node2D

func _on_change_scene_body_entered(body: CharacterBody2D) -> void:
	call_deferred("change_scene")
	
func change_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/TileSet/level_3.tscn")
