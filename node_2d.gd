extends Node2D

const PORT = 8081
var peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	pass # Replace with function body.

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	spawn_player(1)
	print("Сервер красава")

func join_game(ip):
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	print("Подключение КЫ", ip)
	
func spawn_player(id):
	print("spawn player with id ", id)
	var player = preload("res://test/man.tscn").instantiate()
	player.name = str(id)
	get_tree().root.add_child(player)
	
	if id == multiplayer.get_unique_id():
		player.set_multiplayer_authority(id)
	else:
		player.set_physics_process(false)
	
func _on_peer_connected(id):
	print("Игрок молодец подключился", id)
	spawn_player(id)
	
func _on_peer_disconnected(id):
	print("ПОКА ПОКА")

func _on_button_2_pressed() -> void:
	join_game("26.233.123.79")

#HOST
func _on_button_pressed() -> void:
	host_game()
