extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
var players = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#multiplayer_peer.create_server(8080)
	#print("server created")
	#multiplayer.multiplayer_peer = multiplayer_peer
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	pass # Replace with function body.

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
	pass

@rpc("authority", "call_local", "reliable")
func sync_game_state(game_state):
	for peer_id in game_state:
		if has_node(str(peer_id)):
			get_node(str(peer_id)).position = game_state[peer_id]["position"]
			
func despawn_player(peer_id):
	var player_node = get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
	
