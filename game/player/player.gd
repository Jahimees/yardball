extends CharacterBody2D
class_name Player

@export var speed = 150.0
@export var sprint_speed = 250.0
var current_speed = 150.0
var stamina = 100

@onready var player_sprite = $AnimatedSprite2D
@onready var stamina_cd: ProgressBar = $CanvasLayer/Control/HBoxContainer/StaminaContainer/Stamina
@onready var smash_cd: ProgressBar = $CanvasLayer/Control/HBoxContainer/SmashContainer/SmashCD
@onready var timer_smash: Timer = $TimerSmash
@onready var timer_stamina: Timer = $TimerStamina
@onready var smash_light: PointLight2D = $SmashLight
@onready var game_ui: Control = $CanvasLayer/Game_UI

var can_reduce_stamina: bool = true
var can_add_stamina: bool = true
var add_cooldown_active: bool = false
var can_smash_ball: bool = false
var is_smash_cd_active: bool = false
var is_game_ui_showed: bool = false
var is_player_blocked = false

func _ready() -> void:
	Signals.block_players.connect(func(is_blocked): is_player_blocked = is_blocked)
	smash_light.energy = 0.0
	current_speed = speed

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if is_player_blocked or not is_multiplayer_authority():
		return
	
	var direction = (get_global_mouse_position() - global_position).normalized()
	velocity = Vector2.ZERO
	
	handle_movement(direction)
	handle_stamina()
	handle_ball_interaction()
	
	move_and_slide()
	update_ui()

func handle_movement(direction: Vector2) -> void:
	var move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if move_input != Vector2.ZERO:
		var move_direction = direction.rotated(move_input.angle())
		velocity = move_direction * current_speed
		player_sprite.rotation = move_direction.angle()

func handle_stamina() -> void:
	if Input.is_action_pressed("sprint") and stamina > 0:
		current_speed = sprint_speed
		if can_reduce_stamina:
			stamina -= 5
			can_reduce_stamina = false
			get_tree().create_timer(0.1).timeout.connect(func(): can_reduce_stamina = true)
	else:
		current_speed = speed
		if stamina < 100 and can_add_stamina and not add_cooldown_active:
			stamina += 10
			can_add_stamina = false
			get_tree().create_timer(0.3).timeout.connect(func(): can_add_stamina = true)
		
	if stamina <= 0 and not add_cooldown_active:
		add_cooldown_active = true
		get_tree().create_timer(2.0).timeout.connect(func(): add_cooldown_active = false)

func handle_ball_interaction() -> void:
	if Input.is_action_just_pressed("Smash") and can_smash_ball and not is_smash_cd_active:
		smash_ball.rpc()
		is_smash_cd_active = true
		timer_smash.start()

@rpc("call_local", "reliable")
func smash_ball() -> void:
	# Логика удара по мячу будет в мяче, здесь только вызов сигнала
	Signals.ball_smashed.emit(get_global_mouse_position().direction_to(global_position))

func update_ui() -> void:
	stamina_cd.value = stamina
	smash_cd.value = timer_smash.time_left / timer_smash.wait_time * 100
	game_ui.visible = is_game_ui_showed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		is_game_ui_showed = !is_game_ui_showed
