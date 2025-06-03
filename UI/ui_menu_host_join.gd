extends Control

@onready var ip_address: LineEdit = $Control/VBoxContainer/MargContQuit/VBoxContainer/MarginContainer/ip_address

func _on_button_host_pressed() -> void:
	NetworkManager.host()


func _on_button_connect_pressed() -> void:
	NetworkManager.join(ip_address.text)
