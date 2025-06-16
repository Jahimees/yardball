extends Control
	
@onready var left_players_container = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/LeftPlayersContainer
@onready var right_players_container = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/RightPlayersContainer

func _ready() -> void:
	Signals.teams_changed.connect(_on_teams_changed)

func _process(delta: float) -> void:
	pass
	
func _on_teams_changed():

	for node in left_players_container.get_children():
		node.queue_free()
		
	for node in right_players_container.get_children():
		node.queue_free()
	
	for player in Globals.left_team_lobby:
		var label = Label.new()
		label.text = str(player)
		left_players_container.add_child(label)
		
	for player in Globals.right_team_lobby:
		var label = Label.new()
		label.text = str(player)
		right_players_container.add_child(label)
	
func _on_play_btn_pressed() -> void:
	change_scene.rpc()
	
@rpc("any_peer", "call_local")
func change_scene():
	get_tree().change_scene_to_file("res://game/game_field/game_field.tscn")
	
