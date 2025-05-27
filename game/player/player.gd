extends CharacterBody2D

class_name Player

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var player_sprite = $AnimatedSprite2D

var collision_body
var is_ball_pushed

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, 0)
	
	var direction = (get_global_mouse_position() - self.global_position).normalized()
	move(direction)
	
	if collision_body is Ball and !is_ball_pushed:
		is_ball_pushed = true
		collision_body.apply_central_impulse(velocity * 1)
		await get_tree().create_timer(0.3).timeout
		is_ball_pushed = false
	
	move_and_slide()
	
func move(direction: Vector2):
	var run_angle = 90
	player_sprite.rotate(player_sprite.get_angle_to(get_global_mouse_position()))
	
	if Input.is_action_pressed("move_forward"):
		run_angle = 45
		velocity = direction * SPEED
	elif Input.is_action_pressed("move_back"):
		run_angle = -45
		direction = -1 * direction
		velocity = direction * SPEED
		
	if Input.is_action_pressed("move_left"):
		velocity = direction.rotated(deg_to_rad(-run_angle)) * SPEED
	elif Input.is_action_pressed("move_right"):
		velocity = direction.rotated(deg_to_rad(run_angle)) * SPEED
	
	
func _on_collision_area_body_entered(body: Node2D) -> void:
	collision_body = body

func _on_collision_area_body_exited(body: Node2D) -> void:
	collision_body = null
