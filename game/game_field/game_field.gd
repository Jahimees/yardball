extends Node2D
class_name Field

var multiplayer_peer = ENetMultiplayerPeer.new()
@onready var game_ui: Control = $CanvasLayer/Game_UI
@onready var smash_cd: ProgressBar = $CanvasLayer/Control/HBoxContainer/SmashContainer/SmashCD
@onready var stamina: ProgressBar = $CanvasLayer/Control/HBoxContainer/StaminaContainer/Stamina

@onready var right_goal_area: Area2D = $right_gate/RightGoalArea
@onready var left_goal_area: Area2D = $left_gate/LeftGoalArea
@onready var right_goal_collision: CollisionShape2D = $right_gate/RightGoalArea/RightGoalCollision
@onready var left_goal_collision: CollisionShape2D = $left_gate/LeftGoalArea/LeftGoalCollision

func _ready() -> void:
	spawn_players()
	Signals.reset_players_positions.connect(on_reset_players_positions)
	Signals.change_game_ui_visible.connect(_on_change_game_ui_visible)
	Signals.update_hud_values.connect(_on_update_hud_values)
	Signals.despawn_player_from_field.connect(_on_despawn_player)

func spawn_players():
	for player_id in Globals.players_lobby:
		NetworkManager.register_player_for_game.rpc(player_id)
	
	on_reset_players_positions()
		
	for player_id in Globals.left_team:
		var player: Player = Globals.left_team[player_id]
		player.find_child("AnimatedSprite2D").play("blue_team")
		get_tree().get_first_node_in_group("players").add_child(Globals.left_team[player_id])
	
	for player_id in Globals.right_team:
		var player: Player = Globals.right_team[player_id]
		player.find_child("AnimatedSprite2D").play("white_team")
		get_tree().get_first_node_in_group("players").add_child(Globals.right_team[player_id])

func _on_right_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		Signals.goal.emit(Globals.GoalSideEnum.LEFT_GOAL)
		
func _on_left_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		Signals.goal.emit(Globals.GoalSideEnum.RIGHT_GOAL)
		
#TODO move to globals. adaptive?
func on_reset_players_positions():
	var counter = 0
	var spawn_y_pos = 324
	for player_id in Globals.left_team:
		var player = Globals.left_team.get(player_id)
	
		if counter != 0:
			if counter % 2 == 1:
				spawn_y_pos = 224
			else:
				spawn_y_pos = 424
		
		player.position = Vector2(476, spawn_y_pos)
		Signals.move_player_to.emit(player.name.to_int(), Vector2(476, spawn_y_pos))
		counter += 1
	
	spawn_y_pos = 324
	counter = 0
	for player_id in Globals.right_team:
		var player = Globals.right_team[player_id]
		
		if counter != 0:
			if counter % 2 == 1:
				spawn_y_pos = 224
			else:
				spawn_y_pos = 424
		
		player.position = Vector2(676, spawn_y_pos)
		Signals.move_player_to.emit(player.name.to_int(), Vector2(676, spawn_y_pos))
		counter += 1
	
	goal_areas_enable.rpc()
 
func _on_change_game_ui_visible(peer_id):
	if game_ui.visible:
		game_ui.hide()
	else:
		game_ui.show()

func _on_update_hud_values(smash_cd, stamina):
	self.smash_cd.value = smash_cd
	self.stamina.value = stamina


#TODO не отключается нихера!
@rpc("any_peer", "reliable", "call_local")
func temp_goal_areas_diasble():
	printt(right_goal_area.monitoring, right_goal_area.monitorable, right_goal_collision.disabled)
	
	right_goal_area.monitoring = false
	right_goal_area.monitorable = false
	right_goal_collision.disabled = true
	printt(right_goal_area.monitoring, right_goal_area.monitorable, right_goal_collision.disabled)
	
@rpc("any_peer", "reliable", "call_local")
func goal_areas_enable():
	pass
	#right_goal_area.monitoring = true
	#left_goal_area.monitoring = true

func _on_despawn_player(peer_id):
	for player in get_tree().get_first_node_in_group("players").get_children():
		if peer_id == player.name.to_int():
			player.queue_free()

