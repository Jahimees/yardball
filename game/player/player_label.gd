extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$".".text = 'Player pos: ' + str($"../Player".global_position.x) + ' ' + str($"../Player".global_position.y)
	$"../MousePos".text = 'Mouse pos ' + str(get_global_mouse_position().x) + ' ' + str(get_global_mouse_position().y)
	var vectorCords = get_global_mouse_position() - $"../Player".global_position
	$"../VectorCord".text = 'Vector: ' + str(vectorCords.x) + ' ' + str(vectorCords.y)
