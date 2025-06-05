extends Node2D
class_name Field

var multiplayer_peer = ENetMultiplayerPeer.new()
var players = {}

func _ready() -> void:
	for player_id in Globals.all_players:
		NetworkManager.spawn_player.rpc(player_id)
	
	for player_id in Globals.players:
		add_child(Globals.players[player_id])

func _on_right_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		Signals.right_goal.emit()


func _on_left_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		Signals.left_goal.emit()
