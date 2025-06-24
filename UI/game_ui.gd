extends Control

func _on_resume_pressed() -> void:
	self.hide()
	
func _on_quit_pressed() -> void:
	if multiplayer.is_server():
		NetworkManager.close_server.rpc()
	else:
		NetworkManager.disconnect_me()
