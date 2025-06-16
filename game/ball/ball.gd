extends RigidBody2D
class_name  Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation
@onready var tail_particles: CPUParticles2D = $CPUParticles2D

var current_speed
var max_speed := 1.5
var should_reset := false

var last_update_time := 0.0
var update_interval := 0.1

var target_position = Vector2(0, 0)

func _ready() -> void:
	Signals.reset_ball.connect(_on_reset_ball)

func _process(delta: float) -> void:
	#if not multiplayer.is_server():
		#position = position.lerp(target_position, 0.2)
		#
	if multiplayer.is_server():
		update.rpc(position)
	
		#return
	
	#current_speed = linear_velocity.length()
	#var speed_noralized := clampf(current_speed/max_speed, 0.0, 0.7)
	#var animation_speed := lerpf(0.1, max_speed, speed_noralized)
	#ball_animation.speed_scale = animation_speed
	
	#last_update_time += delta
	#if last_update_time >= update_interval:
		#last_update_time = 0.0
	
	#tail_emitting()

@rpc("any_peer", "reliable", "call_local")
func apply_impulse_from_player(velocity):
	if multiplayer.is_server():
		apply_central_impulse(velocity)
	
@rpc("any_peer", "reliable", "call_local")
func update(position):
	target_position = position
	
func _on_reset_ball():
	should_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !multiplayer.is_server():
		state.transform.origin = Vector2(target_position.x, target_position.y)
		
	if should_reset:
		state.transform.origin = Vector2(576, 322)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		should_reset = false
		#reset_ball.rpc(state)

func obrabotatb_myach():
	pass

@rpc("any_peer", "call_local", "reliable")
func reset_ball(state: PhysicsDirectBodyState2D):
	state.transform.origin = Vector2(576, 322)
	state.linear_velocity = Vector2.ZERO
	state.angular_velocity = 0
	should_reset = false

func tail_emitting():
	if abs(linear_velocity) > Vector2(250, 250):
		tail_particles.emitting = true
	else:
		tail_particles.emitting = false
