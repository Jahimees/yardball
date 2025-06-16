extends RigidBody2D
class_name Ball

@onready var tail_particles: CPUParticles2D = $CPUParticles2D

var should_reset := false
var last_update_time := 0.0
var target_position = Vector2(0, 0)

func _ready() -> void:
	Signals.reset_ball.connect(_on_reset_ball)

func _process(delta: float) -> void:
	if multiplayer.is_server():
		last_update_time += delta
		if last_update_time >= Globals.SYNC_UPDATE_INTERVAL:
			last_update_time = 0.0
			update.rpc(position)
	tail_emitting()
	
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
		state.transform.origin = Globals.GAME_FIELD_CENTER_POS
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		should_reset = false

func tail_emitting():
	if abs(linear_velocity) > Vector2(250, 250):
		tail_particles.emitting = true
	else:
		tail_particles.emitting = false
