extends Control

@onready var left_points: Label = $VerticalContainer/HprizontalContainer/LeftPoints
@onready var right_points: Label = $VerticalContainer/HprizontalContainer/RightPoints
@onready var timer_label: Label = $VerticalContainer/HBoxContainer/TimerLabel
@onready var timer: Timer = $Timer
@onready var countdown_timer = $CountDownTimer
@onready var countdown_label = $CountdownLabel
@onready var win_label: Label = $WinLabel
@onready var end_game_timer: Timer = $EndGameTimer

var is_countdown_timer_active
var is_end_game_timer_active

func _ready() -> void:
	Signals.goal.connect(_on_goal_scored)
	timer.start(Globals.game_time)
	
func  _process(delta: float) -> void:
	timer_label.text = "%02d:%02d" % [int(timer.time_left) / 60, int(timer.time_left) % 60]
	if is_countdown_timer_active:
		countdown_label.text = str(int(countdown_timer.time_left) + 1)
	
	if is_end_game_timer_active:
		countdown_label.text = "Выход в лобби: " + str(int(end_game_timer.time_left) + 1)

func _on_goal_scored(goal_side):
	
	if multiplayer.is_server():
		add_score.rpc(goal_side)
	
	await do_slow_motion_effect()
	
	if multiplayer.is_server() and !check_end_game():
		start_count_down_timer.rpc()
		
	Signals.reset_players_positions.emit()
	Signals.reset_ball.emit()
	Signals.block_players.emit(true)

@rpc("call_local", "any_peer")
func start_count_down_timer():
	is_countdown_timer_active = true
	countdown_timer.start(3)
	
func _on_count_down_timer_timeout() -> void:
	is_countdown_timer_active = false
	countdown_label.text = ""
	timer.set_paused(false)
	Signals.block_players.emit(false)

func do_slow_motion_effect():
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.25, 0.8)
	await get_tree().create_timer(1).timeout
	tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1, 0)

@rpc("call_local", "reliable")
func add_score(goal_side):
	if goal_side == Globals.GoalSideEnum.LEFT_GOAL:
		Globals.left_goals += 1
	else:
		Globals.right_goals += 1	
	update_score()
	
func update_score():
	left_points.text = str(Globals.left_goals)
	right_points.text = str(Globals.right_goals)
	timer.set_paused(true)

func _on_reset_pressed() -> void:
	timer.set_paused(false)
	Signals.reset.emit()

func check_end_game():
	if Globals.win_goals == 0 and Globals.game_time == 0:
		return
	
	if timer.time_left == 0 and Globals.game_time != 0:
		if Globals.left_goals == Globals.right_goals:
			win_label.text = "Ничья"
			
		elif Globals.left_goals > Globals.right_goals:
			win_label.text = "Левая команда - победила!"
		else:
			win_label.text = "Правая команда - победила!"
		end_game_timer.start(5)
		is_end_game_timer_active = true
		return true
	
	if Globals.left_goals == Globals.win_goals || Globals.right_goals == Globals.win_goals:
		if Globals.left_goals == Globals.win_goals:
			win_label.text = "Левая команда - победила!"
		else:
			win_label.text = "Правая команда - победила!"
		end_game_timer.start(5)
		is_end_game_timer_active = true
		return true

func _on_end_game_timer_timeout() -> void:
	Signals.game_end.emit()


func _on_timer_timeout() -> void:
	check_end_game()
