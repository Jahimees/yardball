extends RigidBody2D
class_name  Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation

var current_speed
var max_speed := 1.5

func _process(delta: float) -> void:
	current_speed = linear_velocity.length()
	
	var speed_noralized := clampf(current_speed/max_speed, 0.0, 0.7)
	
	var animation_speed := lerpf(0.1, max_speed, speed_noralized)
	
	ball_animation.speed_scale = animation_speed
	
