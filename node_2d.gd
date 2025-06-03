extends Node2D

const PORT = 8081
var peer = ENetMultiplayerPeer.new()

var players = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	spawn_player.rpc_id(1, multiplayer.get_unique_id())

func join_game(ip):
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id = 1):
	if players.get(id) == null:
		var player = preload("res://test/man.tscn").instantiate()
		player.name = str(id)
		call_deferred("add_child", player)
		players[id] = player
		
func _on_peer_connected(id):
	spawn_player.rpc(id)
	
func _on_peer_disconnected(id):
	print("ПОКА ПОКА")

func _on_button_2_pressed() -> void:
	join_game("localhost")

#HOST
func _on_button_pressed() -> void:
	host_game()
