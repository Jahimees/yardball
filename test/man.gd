extends CharacterBody2D


@export var speed = 300
var input = Vector2.ZERO
var target_position = position

func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority():
		position = position.lerp(target_position, delta * 10)
		return
		
	input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
	velocity = input * speed
	move_and_slide()
	
	if multiplayer.is_server():
		update_position.rpc(position)
		
@rpc("authority", "unreliable")
func update_position(new_pos):
	target_position = new_pos
