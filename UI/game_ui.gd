extends Control

func _on_resume_pressed() -> void:
	self.hide()
	
func _on_quit_pressed() -> void:
	NetworkManager.disconnect_me()
