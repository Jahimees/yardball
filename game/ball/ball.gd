extends RigidBody2D
class_name Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation
@onready var tail_particles: CPUParticles2D = $CPUParticles2D

var current_speed
var max_speed := 1.5
var should_reset := false

# Для интерполяции
var server_state := {
	"position": Vector2.ZERO,
	"velocity": Vector2.ZERO,
	"angular_velocity": 0.0,
	"time": 0.0
}
var update_interval := 0.1
var last_update_time := 0.0

func _ready() -> void:
	Signals.reset_ball.connect(_on_reset_ball)
	if not multiplayer.is_server():
		# На клиентах физика будет предсказывать движение
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.bounce = 0.9
		physics_material_override.friction = 0.1

func _process(delta: float) -> void:
	if multiplayer.is_server():
		current_speed = linear_velocity.length()
		var speed_normalized := clampf(current_speed/max_speed, 0.0, 0.7)
		var animation_speed := lerpf(0.1, max_speed, speed_normalized)
		ball_animation.speed_scale = animation_speed
		
		# Отправляем состояние с интервалом
		last_update_time += delta
		if last_update_time >= update_interval:
			update_state.rpc(position, linear_velocity, angular_velocity)
			last_update_time = 0.0
	
	tail_emitting()
	
	# На клиентах применяем полученное состояние
	if not multiplayer.is_server():
		var time_passed = Time.get_ticks_msec() / 1000.0 - server_state["time"]
		if time_passed < update_interval * 2:  # Используем только актуальные данные
			position = position.lerp(server_state["position"], 0.3)
			linear_velocity = linear_velocity.lerp(server_state["velocity"], 0.3)
			angular_velocity = lerp(angular_velocity, server_state["angular_velocity"], 0.3)

@rpc("any_peer", "reliable", "call_local")
func update_state(pos: Vector2, vel: Vector2, ang_vel: float):
	server_state = {
		"position": pos,
		"velocity": vel,
		"angular_velocity": ang_vel,
		"time": Time.get_ticks_msec() / 1000.0
	}

func _on_reset_ball():
	should_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if should_reset and multiplayer.is_server():
		reset_ball.rpc()

@rpc("any_peer", "call_local", "reliable")
func reset_ball():
	var state = PhysicsServer2D.body_get_direct_state(get_rid())
	if state:
		state.transform.origin = Vector2(576, 322)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
	should_reset = false
	if not multiplayer.is_server():
		server_state = {
			"position": Vector2(576, 322),
			"velocity": Vector2.ZERO,
			"angular_velocity": 0.0,
			"time": Time.get_ticks_msec() / 1000.0
		}

func tail_emitting():
	tail_particles.emitting = linear_velocity.length_squared() > 250 * 250
