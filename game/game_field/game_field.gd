extends Node2D
class_name Field

var multiplayer_peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	spawn_players()
	Signals.reset_players_positions.connect(on_reset_players_positions)

func spawn_players():
	for player_id in Globals.players_lobby:
		NetworkManager.register_player_for_game.rpc(player_id)
	
	on_reset_players_positions()
		
	for player_id in Globals.left_team:
		var player: Player = Globals.left_team[player_id]
		player.find_child("AnimatedSprite2D").play("blue_team")
		add_child(Globals.left_team[player_id])
	
	for player_id in Globals.right_team:
		var player: Player = Globals.right_team[player_id]
		player.find_child("AnimatedSprite2D").play("white_team")
		add_child(Globals.right_team[player_id])

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
 
