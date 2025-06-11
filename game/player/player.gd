extends CharacterBody2D

class_name Player

var speed = 150.0
var stamina = 100

@onready var player_sprite = $AnimatedSprite2D
@onready var stamina_cd: ProgressBar = $CanvasLayer/Control/HBoxContainer/StaminaContainer/Stamina
@onready var smash_cd: ProgressBar = $CanvasLayer/Control/HBoxContainer/SmashContainer/SmashCD
@onready var timer_smash: Timer = $TimerSmash
@onready var timer_stamina: Timer = $TimerStamina
@onready var smash_light: PointLight2D = $SmashLight
@onready var game_ui: Control = $CanvasLayer/Game_UI

@export var collision_body:Node = null
var collision_body_smash:Node = null
@export var is_ball_pushed = false

var can_reduce_stamina: bool = true
var can_add_stamina: bool = true
var add_cooldown_active: bool = false
var can_smash_ball: bool = false
var is_smash_cd_active: bool = false
var is_game_ui_showed: bool = false

var is_player_blocked = false

@export var target_position = Vector2(0,0)

func _ready() -> void:
	Signals.move_player_to.connect(_on_move_player_to)
	Signals.block_players.connect(func(is_blocked):
		is_player_blocked = is_blocked
	)
	smash_light.energy = 0.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if is_player_blocked:
		return
		
	if !is_multiplayer_authority():
		position = position.lerp(target_position, delta * 10)
		return
	
	var direction = (get_global_mouse_position() - self.global_position).normalized()
	
	velocity = Vector2(0, 0)
	escape()
	sprint()
	move(direction)
	push_ball()
	smash_ball()
	move_and_slide()
	update_cooldown()
	
	update_position.rpc(position)
		
@rpc("any_peer", "unreliable_ordered")
func update_position(new_position: Vector2) -> void:
	target_position = new_position
	
@rpc("any_peer", "call_local", "reliable")
func push_ball():
	if collision_body is Ball and !is_ball_pushed:
		is_ball_pushed = true
		collision_body.apply_central_impulse(velocity * 1)
		await get_tree().create_timer(0.3).timeout
		is_ball_pushed = false

@rpc("any_peer", "call_local", "reliable")
func smash_ball():
	if Input.is_action_just_pressed("Smash") and !is_smash_cd_active:
		if can_smash_ball :
			collision_body_smash.apply_impulse(velocity * 4)
		activate_smash_colldown()

@rpc("any_peer", "call_local", "reliable")
func sprint():
	if Input.is_action_pressed("sprint") and stamina > 0:
		speed = 250
		
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
	stamina -= 5
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
		
func activate_smash_colldown():
	is_smash_cd_active = true
	can_smash_ball = false
	timer_smash.start()
	timer_smash.timeout.connect(
		func():
			is_smash_cd_active = false
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
	
func update_cooldown():
	smash_cd.value = 1.5 - timer_smash.time_left
	stamina_cd.value = stamina
	
func _on_collision_area_body_entered(body: Node2D) -> void:
	collision_body = body

func _on_collision_area_body_exited(body: Node2D) -> void:
	collision_body = null
	
func _on_move_player_to(peer_id, new_position):
	if peer_id == name.to_int():
		position = new_position

func _on_smash_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		collision_body_smash = body
		can_smash_ball = true
		var tween = create_tween()
		tween.tween_property(smash_light, "energy", 0.7, 0.1)

func _on_smash_area_body_exited(body: Node2D) -> void:
	if body is Ball:
		collision_body_smash = null
		can_smash_ball = false
		var tween = create_tween()
		tween.tween_property(smash_light, "energy", 0.0, 0.2)

func escape():
	if Input.is_action_just_pressed("Escape"):
		is_game_ui_showed = !is_game_ui_showed
		
	game_ui.show() if is_game_ui_showed else game_ui.hide()
		
func _on_game_ui_resume_pressed() -> void:
	is_game_ui_showed = false
