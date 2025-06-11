extends Control

signal resume_pressed

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/ui_menu.tscn")
