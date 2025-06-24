extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
var should_close_server = false

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Signals.change_team.connect(_on_change_team)
	
func _process(delta: float) -> void:
	if should_close_server:
		close_server()

func _on_peer_connected(peer_id):
	print("Client connected: ", peer_id)
	register_player.rpc(peer_id)
	if multiplayer.is_server():
		sync_players_in_lobby.rpc_id(peer_id, Globals.left_team_lobby, Globals.right_team_lobby, Globals.players_lobby)

func _on_peer_disconnected(peer_id):
	print("Client disconnected: ", peer_id)
	unregister_player.rpc(peer_id)
	if peer_id == 1:
		disconnect_me()

@rpc("any_peer", "call_local", "reliable")
func register_player_for_game(peer_id):
	
	if Globals.left_team_lobby.get(peer_id) != null or Globals.right_team_lobby.get(peer_id) != null:
		var player_scene = load("res://game/player/player.tscn")
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		
		if Globals.left_team_lobby.get(peer_id):
			Globals.left_team[peer_id] = player
			
		if Globals.right_team_lobby.get(peer_id):
			Globals.right_team[peer_id] = player

@rpc("any_peer", "call_local", "reliable")
func despawn_player(peer_id):
	var player_node: Player
	if Globals.left_team.get(peer_id):
		player_node = Globals.left_team.get(peer_id)
		Globals.left_team.erase(peer_id)
		player_node.queue_free()
		return
	
	if Globals.right_team.get(peer_id):
		player_node = Globals.right_team.get(peer_id)
		Globals.right_team.erase(peer_id)
		Signals.despawn_player_from_field.emit(peer_id)
		
@rpc("any_peer", "call_local", "reliable")
func register_player(peer_id = 1):
	
	if Globals.players_lobby.get(peer_id) == null:
		Globals.players_lobby[peer_id] = peer_id
		
		if Globals.left_team_lobby.size() <= Globals.right_team_lobby.size():
			Globals.left_team_lobby[peer_id] = peer_id
		else:
			Globals.right_team_lobby[peer_id] = peer_id
		
		Signals.teams_changed.emit()
		

@rpc("any_peer", "call_local", "reliable")
func unregister_player(peer_id):
	
	Globals.players_lobby.erase(peer_id)
	if Globals.left_team_lobby.get(peer_id):
		Globals.left_team_lobby.erase(peer_id)
	else:
		Globals.right_team_lobby.erase(peer_id)
	
	despawn_player(peer_id)
		
	Signals.teams_changed.emit()

func host():
	multiplayer_peer.create_server(6005)
	multiplayer.multiplayer_peer = multiplayer_peer
	register_player.rpc_id(1, multiplayer_peer.get_unique_id())
	get_tree().change_scene_to_file("res://UI/lobby.tscn")
	print("server created")
	
func join(ip: String):
	multiplayer_peer.create_client(ip, 6005)
	multiplayer.multiplayer_peer = multiplayer_peer
	get_tree().change_scene_to_file("res://UI/lobby.tscn")
	
@rpc("any_peer", "call_local", "unreliable")
func close_server():
	should_close_server = true
	
	if !multiplayer.is_server():
		disconnect_me()
		should_close_server = false
		return
		
	if multiplayer.get_peers().size() > 0:
		return
	print("Close server")
	should_close_server = false
	disconnect_me()

func disconnect_me():
	get_tree().change_scene_to_file("res://UI/ui_menu.tscn")
	Globals.reset_game_vars()
	multiplayer_peer.close()

@rpc("authority")
func sync_players_in_lobby(left_team_lobby, right_team_lobby, all_players):
	Globals.left_team_lobby = left_team_lobby
	Globals.right_team_lobby = right_team_lobby
	Globals.players_lobby = all_players
	Signals.teams_changed.emit()
	
func _on_change_team():
	var peer_id = multiplayer_peer.get_unique_id()
	if (Globals.left_team_lobby.has(peer_id) and Globals.left_team_lobby.size() == 1) or (Globals.right_team_lobby.has(peer_id) and Globals.right_team_lobby.size() == 1) :
		Signals.show_error_notification.emit()
	else:
		change_team.rpc(peer_id)

@rpc("any_peer", "call_local", "reliable")
func change_team(peer_id):
	
	if Globals.left_team_lobby.has(peer_id) and Globals.left_team_lobby.size() > 1:
		Globals.left_team_lobby.erase(peer_id)
		Globals.right_team_lobby[peer_id] = peer_id
	elif Globals.right_team_lobby.has(peer_id) and Globals.right_team_lobby.size() > 1:
		Globals.right_team_lobby.erase(peer_id)
		Globals.left_team_lobby[peer_id] = peer_id
		
	Signals.teams_changed.emit()
