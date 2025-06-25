extends CharacterBody2D

class_name Player

var speed = Globals.DEFAULT_PLAYER_SPEED
var stamina = Globals.DEFAULT_PLAYER_STAMINA

@onready var player_sprite = $AnimatedSprite2D
@onready var timer_smash: Timer = $TimerSmash
@onready var timer_stamina: Timer = $TimerStamina
@onready var smash_light: PointLight2D = $SmashLight

@export var collision_body:Node = null
var collision_body_smash:Node = null
@export var is_ball_pushed = false

var can_smash_ball: bool = false
var is_smash_cd_active: bool = false

var is_stamina_timer_active: bool = false

var player_stamina_state = RestoreStaminaState.CAN_RESTORE

enum RestoreStaminaState {
	RESTORE_COOLDOWN, CAN_RESTORE, SPRINT
}

var is_player_blocked = false

@export var target_position = Vector2(0,0)

func _ready() -> void:
	Signals.move_player_to.connect(_on_move_player_to)
	Signals.block_players.connect(func(is_blocked):
		is_player_blocked = is_blocked
	)
	#smash_light.energy = 0.0
	timer_stamina.timeout.connect(func():
		is_stamina_timer_active = false
		if player_stamina_state == RestoreStaminaState.RESTORE_COOLDOWN:
			player_stamina_state = RestoreStaminaState.CAN_RESTORE
		)
		
	if is_multiplayer_authority():
		smash_light.show()

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
		collision_body.apply_impulse_from_player.rpc_id(1, velocity * Globals.PUSH_RATIO)
		await get_tree().create_timer(Globals.DEFAULT_DELAY).timeout
		is_ball_pushed = false

@rpc("any_peer", "call_local", "reliable")
func smash_ball():
	if Input.is_action_just_pressed("Smash") and !is_smash_cd_active:
		if can_smash_ball :
			collision_body_smash.apply_impulse_from_player.rpc_id(1, velocity * Globals.SMASH_RATIO)
		activate_smash_colldown()

@rpc("any_peer", "call_local", "reliable")
func sprint():
	if (is_stamina_timer_active):
		return
	
	if stamina == 0 and player_stamina_state != RestoreStaminaState.CAN_RESTORE:
		player_stamina_state = RestoreStaminaState.RESTORE_COOLDOWN
		
	if Input.is_action_pressed("sprint") and stamina != 0:
		player_stamina_state = RestoreStaminaState.SPRINT
	elif stamina != 0:
		player_stamina_state = RestoreStaminaState.CAN_RESTORE	
		
	if stamina < Globals.DEFAULT_PLAYER_STAMINA and player_stamina_state != RestoreStaminaState.RESTORE_COOLDOWN and player_stamina_state != RestoreStaminaState.SPRINT:
		player_stamina_state = RestoreStaminaState.CAN_RESTORE
	
	match player_stamina_state:
		RestoreStaminaState.SPRINT:
			speed = Globals.SPRINT_PLAYER_SPEED
			reduce_stamina()
		RestoreStaminaState.RESTORE_COOLDOWN:
			speed = Globals.DEFAULT_PLAYER_SPEED
			activate_restore_cooldown()
		RestoreStaminaState.CAN_RESTORE:
			speed = Globals.DEFAULT_PLAYER_SPEED
			if stamina < Globals.DEFAULT_PLAYER_STAMINA:
				add_stamina()

@rpc("any_peer", "call_local", "reliable")
func reduce_stamina():
	stamina -= Globals.REDUCE_STAMINA_RATIO
	timer_stamina.start(0.1)
	is_stamina_timer_active = true

@rpc("any_peer", "call_local", "reliable")
func add_stamina():
	stamina += Globals.RESTORE_STAMINA_RATIO
	timer_stamina.start(Globals.DEFAULT_DELAY)
	is_stamina_timer_active = true

func activate_restore_cooldown():
	timer_stamina.start(2)
	is_stamina_timer_active = true
		
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
	Signals.update_hud_values.emit(1.5 - timer_smash.time_left, stamina)
	
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
		if is_multiplayer_authority():
			var tween = create_tween()
			tween.tween_property(smash_light, "color:g", 0.0, 0.1)
			tween.tween_property(smash_light, "color:b", 0.0, 0.1)

func _on_smash_area_body_exited(body: Node2D) -> void:
	if body is Ball:
		collision_body_smash = null
		can_smash_ball = false
		if is_multiplayer_authority():
			var tween = create_tween()
			tween.tween_property(smash_light, "color:g", 1.0, 0.1)
			tween.tween_property(smash_light, "color:b", 1.0, 0.1)

func escape():
	if Input.is_action_just_pressed("Escape"):
		Signals.change_game_ui_visible.emit(self.name)
