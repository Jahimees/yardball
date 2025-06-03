extends Node2D
class_name Field

var multiplayer_peer = ENetMultiplayerPeer.new()
var players = {}

func host_game():
	var err = multiplayer_peer.create_server(8080, 3)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	spawn_player(1)
	print("СЕРВЕР УРА")

func join_game(ip: String):
	print("подключение...")
	multiplayer_peer.create_client(ip, 8080)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("подключение")
	
func _on_peer_connected(peer_id):
	print("Client connected: ", peer_id)
	players[peer_id] = { "position": Vector2(400, 300) }
	spawn_player(peer_id)
	sync_game_state.rpc(players)

func _on_peer_disconnected(peer_id):
	print("Client disconnected: ", peer_id)
	players.erase(peer_id)
	despawn_player(peer_id)
	return

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id):
	var player_scene = load("res://game/player/player.tscn")
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	call_deferred("add_child", player)
	
@rpc("authority", "call_local", "reliable")
func sync_game_state(game_state):
	for peer_id in game_state:
		if has_node(str(peer_id)):
			get_node(str(peer_id)).position = game_state[peer_id]["position"]
	
func despawn_player(peer_id):
	var player_node = get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
	

func _on_right_goal_area_body_entered(body: Node2D) -> void:
	print("НУ ПОДНИМИСЯ")
	host_game()
	if body is Ball:
		print("ball")
		Signals.right_goal.emit()


func _on_left_goal_area_body_entered(body: Node2D) -> void:
	join_game("26.233.123.79")
	if body is Ball:
		Signals.left_goal.emit()
