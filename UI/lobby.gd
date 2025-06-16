extends Control

@onready var right_players_container: VBoxContainer = $MarginContainer/CommonField/CenterField/HBoxContainer/HBoxContainer/RightPlayersContainer
@onready var left_players_container: VBoxContainer = $MarginContainer/CommonField/CenterField/HBoxContainer/HBoxContainer/LeftPlayersContainer
@onready var goals_count_input: LineEdit = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/GoalsCountSetting/GoalsCountInput
@onready var match_time_input: LineEdit = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/MatchTimeSetting/MatchTimeInput

func _ready() -> void:
	if !multiplayer.is_server():
		match_time_input.editable = false
		goals_count_input.editable = false
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

@rpc("any_peer", "call_local")
func change_scene():
	get_tree().change_scene_to_file("res://game/game_field/game_field.tscn")

func _on_play_btn_pressed() -> void:
	#if multiplayer.is_server():
		#Globals.game_time = match_time_input.text.to_int()
	change_scene.rpc()
	
func _on_exit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/ui_menu_host-join.tscn")

func _on_up_pressed() -> void:
	if multiplayer.is_server():
		goals_count_input.text = str(goals_count_input.text.to_int() + 1)

func _on_down_pressed() -> void:
	if multiplayer.is_server():
		if goals_count_input.text.to_int() > 0:
			goals_count_input.text = str(goals_count_input.text.to_int() - 1)

func _on_up_time_pressed() -> void:
	if multiplayer.is_server():
		match_time_input.text = str(match_time_input.text.to_int() + 10)

func _on_down_time_pressed() -> void:
	if multiplayer.is_server():
		if match_time_input.text.to_int() > 0:
			match_time_input.text = str(match_time_input.text.to_int() - 10)
