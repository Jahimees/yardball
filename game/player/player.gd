extends CharacterBody2D

class_name Player

var speed = 150.0
var stamina = 100

@onready var player_sprite = $AnimatedSprite2D

@export var collision_body:Node = null
@export var is_ball_pushed = false

var can_reduce_stamina: bool = true
var can_add_stamina: bool = true
var add_cooldown_active: bool = false

var target_position = Vector2(0,0)

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		position = position.lerp(target_position, delta * 10)
		return
	
	velocity = Vector2(0, 0)
	
	var direction = (get_global_mouse_position() - self.global_position).normalized()
	#if not is_multiplayer_authority():
		#return
	
	#if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
	sprint()
	move(direction)
	
		#move_and_slide()

	#input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#velocity = input * speed
	move_and_slide()
	
	if multiplayer.is_server():
		update_position.rpc(position)
		
@rpc("authority", "unreliable")
func update_position(new_pos):
	target_position = new_pos
	
@rpc("any_peer", "call_local", "reliable")
func push_ball():
	if collision_body is Ball and !is_ball_pushed:
		is_ball_pushed = true
		collision_body.apply_central_impulse(velocity * 1)
		await get_tree().create_timer(0.3).timeout
		is_ball_pushed = false

@rpc("any_peer", "call_local", "reliable")
func sprint():
	if Input.is_action_pressed("sprint") and stamina > 0:
		speed = 300
		
		if can_reduce_stamina:
			reduce_stamina()
		
	else:
		speed = 150
		
		if (stamina == 0 and !add_cooldown_active):
			activate_restore_cooldown()
	
		if (stamina < 100):
			if (can_add_stamina):
				add_stamina()
				
	$StaminaLabel.text = str(stamina)

@rpc("any_peer", "call_local", "reliable")
func reduce_stamina():
	stamina -= 10
	can_reduce_stamina = false
	get_tree().create_timer(0.1).timeout.connect(func():
		can_reduce_stamina = true)

@rpc("any_peer", "call_local", "reliable")
func add_stamina():
	stamina += 10
	can_add_stamina = false

	get_tree().create_timer(0.3).timeout.connect(func():
		can_add_stamina = true
		)

func activate_restore_cooldown():
	add_cooldown_active = true
	can_add_stamina = false
	get_tree().create_timer(2).timeout.connect(func():
		add_cooldown_active = false
		add_stamina()
		)

@rpc("any_peer", "call_local", "reliable")
func move(direction: Vector2):
	var run_angle = 90
	player_sprite.rotate(player_sprite.get_angle_to(get_global_mouse_position()))
	
	if Input.is_action_pressed("move_forward"):
		run_angle = 45
		velocity = direction * speed
	elif Input.is_action_pressed("move_back"):
		run_angle = -45
		direction = -1 * direction
		velocity = direction * speed
		
	if Input.is_action_pressed("move_left"):
		velocity = direction.rotated(deg_to_rad(-run_angle)) * speed
	elif Input.is_action_pressed("move_right"):
		velocity = direction.rotated(deg_to_rad(run_angle)) * speed
	
	
func _on_collision_area_body_entered(body: Node2D) -> void:
	collision_body = body

func _on_collision_area_body_exited(body: Node2D) -> void:
	collision_body = null
