extends Control


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/ui_menu_host-join.tscn")


func _on_button_quit_pressed() -> void:
	get_tree().quit()
