extends RigidBody2D
class_name  Ball

@onready var ball_animation: AnimatedSprite2D = $ballAnimation
@onready var tail_particles: CPUParticles2D = $CPUParticles2D


var current_speed
var max_speed := 1.5

var target_position = Vector2(0, 0)

func _ready() -> void:
	Signals.reset.connect(_on_reset_pressed)

func _process(delta: float) -> void:
	#position = position.lerp(target_position, delta * 10)
	
	if !multiplayer.is_server():
		#position = position.lerp(target_position, delta * 10)
		return
	
	current_speed = linear_velocity.length()
	
	var speed_noralized := clampf(current_speed/max_speed, 0.0, 0.7)
	
	var animation_speed := lerpf(0.1, max_speed, speed_noralized)
	
	ball_animation.speed_scale = animation_speed
	
	update.rpc(position)
	
	tail_emitting()
	
	print(linear_velocity)

@rpc("any_peer", "unreliable_ordered")
func update(position1):
	target_position = position1
	
func _on_reset_pressed():
	print("МЯЧЕГ ДОЛЖЕН БЫТЬ УТСАНОВЛЕН В НАЧАЛЬНОЕ ПОЛОЖЕНИЕ")

func tail_emitting():
	if abs(linear_velocity) > Vector2(250, 250):
		tail_particles.emitting = true
	else:
		tail_particles.emitting = false
