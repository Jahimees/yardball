extends RigidBody2D
class_name Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation
@onready var tail_particles: CPUParticles2D = $CPUParticles2D
@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer

var current_speed
var max_speed := 1.5
var should_reset := false

func _ready() -> void:
	Signals.reset_ball.connect(_on_reset_ball)
	
	# Настраиваем синхронизатор (лучше делать в редакторе)
	if multiplayer.is_server():
		sync.set_multiplayer_authority(1)  # Сервер управляет мячом
	else:
		# Клиенты получают предсказуемую физику
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.bounce = 0.9
		physics_material_override.friction = 0.1

func _process(delta: float) -> void:
	if multiplayer.is_server():
		# Только сервер обновляет анимацию и логику
		current_speed = linear_velocity.length()
		var speed_normalized := clampf(current_speed/max_speed, 0.0, 0.7)
		ball_animation.speed_scale = lerpf(0.1, max_speed, speed_normalized)
	
	# Все клиенты обновляют частицы
	tail_emitting()

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

func tail_emitting():
	tail_particles.emitting = linear_velocity.length_squared() > 250 * 250
