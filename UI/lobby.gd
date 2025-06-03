extends Control

	
@onready var left_players_container = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/LeftPlayersContainer
@onready var right_players_container = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/RightPlayersContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.TEAMS_CHANGED.connect(_on_teams_changed)
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
	
func _on_teams_changed():

	for node in left_players_container.get_children():
		node.queue_free()
		
	for node in right_players_container.get_children():
		node.queue_free()
	
	for player in Globals.left_team:
		var label = Label.new()
		label.text = str(player)
		left_players_container.add_child(label)
		
	for player in Globals.right_team:
		var label = Label.new()
		label.text = str(player)
		right_players_container.add_child(label)
	
