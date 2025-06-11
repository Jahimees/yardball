extends RigidBody2D
class_name  Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation
@onready var tail_particles: CPUParticles2D = $CPUParticles2D


var current_speed
var max_speed := 1.5
var should_reset := false

var target_position = Vector2(0, 0)

func _ready() -> void:
	Signals.reset_ball.connect(_on_reset_ball)

func _process(delta: float) -> void:
	
	if !multiplayer.is_server():
		return
	
	current_speed = linear_velocity.length()
	
	var speed_noralized := clampf(current_speed/max_speed, 0.0, 0.7)
	
	var animation_speed := lerpf(0.1, max_speed, speed_noralized)
	
	ball_animation.speed_scale = animation_speed
	
	update.rpc(position)
	
	tail_emitting()

@rpc("any_peer", "unreliable_ordered")
func update(position):
	target_position = position
	
func _on_reset_ball():
	should_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if should_reset:
		state.transform.origin = Vector2(576, 322)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		should_reset = false

func tail_emitting():
	if abs(linear_velocity) > Vector2(250, 250):
		tail_particles.emitting = true
	else:
		tail_particles.emitting = false
