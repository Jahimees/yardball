extends Label


func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	$".".text = 'Player pos: ' + str($"../Player".global_position.x) + ' ' + str($"../Player".global_position.y)
	$"../MousePos".text = 'Mouse pos ' + str(get_global_mouse_position().x) + ' ' + str(get_global_mouse_position().y)
	var vectorCords = get_global_mouse_position() - $"../Player".global_position
	$"../VectorCord".text = 'Vector: ' + str(vectorCords.x) + ' ' + str(vectorCords.y)
