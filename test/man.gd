extends CharacterBody2D


@export var speed = 300
var input = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority():
		return
		
	input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = input * speed
	move_and_slide()
