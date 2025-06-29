extends Control

@onready var right_players_container: VBoxContainer = $MarginContainer/CommonField/CenterField/HBoxContainer/HBoxContainer/RightPlayersContainer
@onready var left_players_container: VBoxContainer = $MarginContainer/CommonField/CenterField/HBoxContainer/HBoxContainer/LeftPlayersContainer

@onready var goals_count_input: LineEdit = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/GoalsCountSetting/GoalsCountInput
@onready var match_time_input: LineEdit = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/MatchTimeSetting/MatchTimeInput

@onready var play_btn: Button = $MarginContainer/CommonField/BottomButtons/HBoxContainer/playBtn
@onready var up_goals: Button = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/GoalsCountSetting/VBoxContainer/UpGoals
@onready var down_goals: Button = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/GoalsCountSetting/VBoxContainer/DownGoals
@onready var up_time: Button = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/MatchTimeSetting/VBoxContainer/UpTime
@onready var down_time: Button = $MarginContainer/CommonField/CenterField/HBoxContainer/VBoxContainer2/MatchTimeSetting/VBoxContainer/DownTime

@onready var notification_label: Label = $MarginContainer/CommonField/NotificationField/NotificationLabel

var is_server_close: bool = false

func _ready() -> void:
	if !multiplayer.is_server():
		up_goals.disabled = true
		down_goals.disabled = true
		up_time.disabled = true
		down_time.disabled = true
		play_btn.disabled = true
		
	Signals.teams_changed.connect(_on_teams_changed)
	Signals.show_error_notification.connect(_on_show_notification)
	
	if multiplayer.is_server():
		_on_teams_changed()
		
	notification_label.modulate.a = 0

func _process(delta: float) -> void:
	if is_server_close:
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
	
	if multiplayer and multiplayer.is_server():
		set_game_parameters.rpc(goals_count_input.text, match_time_input.text)

@rpc("any_peer", "call_local")
func change_scene():
	get_tree().change_scene_to_file("res://game/game_field/game_field.tscn")

func _on_play_btn_pressed() -> void:
	change_scene.rpc()

func _on_exit_btn_pressed() -> void:
	if multiplayer and !multiplayer.is_server():
		NetworkManager.disconnect_me()
		
	if multiplayer and multiplayer.is_server():
		NetworkManager.close_server.rpc()
	

func _on_up_pressed() -> void:	
	goals_count_input.text = str(goals_count_input.text.to_int() + 1)
	set_game_parameters.rpc(goals_count_input.text, match_time_input.text)

func _on_down_pressed() -> void:
	if goals_count_input.text.to_int() > 0:
		goals_count_input.text = str(goals_count_input.text.to_int() - 1)
	set_game_parameters.rpc(goals_count_input.text, match_time_input.text)

func _on_up_time_pressed() -> void:
	match_time_input.text = str(match_time_input.text.to_int() + 10)
	set_game_parameters.rpc(goals_count_input.text, match_time_input.text)

func _on_down_time_pressed() -> void:
	if match_time_input.text.to_int() > 0:
		match_time_input.text = str(match_time_input.text.to_int() - 10)
	set_game_parameters.rpc(goals_count_input.text, match_time_input.text)

@rpc("any_peer", "call_local", "reliable")
func set_game_parameters(goals, time):
	Globals.win_goals = goals.to_int()
	Globals.game_time = time.to_int()
	if multiplayer and !multiplayer.is_server():
		goals_count_input.text = str(Globals.win_goals)
		match_time_input.text = str(Globals.game_time)

func _on_change_team_pressed() -> void:
	Signals.change_team.emit()

func _on_show_notification():
	var tween = create_tween()
	tween.tween_property(notification_label, "modulate:a", 1.0, 0.5)
	
	tween.tween_interval(2.0)
	
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)
