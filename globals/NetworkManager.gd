extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
var players = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id):
	print("Client connected: ", peer_id)
	register_player.rpc(peer_id)
	#spawn_player.rpc(peer_id)

func _on_peer_disconnected(peer_id):
	print("Client disconnected: ", peer_id)
	unregister_player.rpc(peer_id)
	#despawn_player.rpc(peer_id)

@rpc("any_peer", "call_local", "reliable")
func spawn_player(peer_id):
	if players[peer_id] == null:
		var player_scene = load("res://game/player/player.tscn")
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		players[peer_id] = { "position": Vector2(400, 300) }

@rpc("any_peer", "call_local", "reliable")
func despawn_player(peer_id):
	players.erase(peer_id)
	var player_node = get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
		
@rpc("any_peer", "call_local", "reliable")
func register_player(peer_id = 1):
	
	if Globals.all_players.get(peer_id) == null:
		Globals.all_players[peer_id] = peer_id
		
		if Globals.left_team.size() <= Globals.right_team.size():
			Globals.left_team[peer_id] = peer_id
		else:
			Globals.right_team[peer_id] = peer_id
		
		Signals.TEAMS_CHANGED.emit()
		

@rpc("any_peer", "call_local", "reliable")	
func unregister_player(peer_id):
	Globals.all_players.erase(peer_id)
	if Globals.left_team.get(peer_id) != null:
		Globals.left_team.erase(peer_id)
	else:
		Globals.right_team.erase(peer_id)

func host():
	multiplayer_peer.create_server(6005)
	multiplayer.multiplayer_peer = multiplayer_peer
	register_player.rpc_id(1, multiplayer_peer.get_unique_id())
	get_tree().change_scene_to_file("res://UI/lobby.tscn")
	#spawn_player.rpc_id(1, multiplayer_peer.get_unique_id())
	
func join(ip: String):
	multiplayer_peer.create_client(ip, 6005)
	multiplayer.multiplayer_peer = multiplayer_peer
	get_tree().change_scene_to_file("res://UI/lobby.tscn")
	
	
