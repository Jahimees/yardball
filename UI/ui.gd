extends Control

@onready var left_points: Label = $VerticalContainer/HprizontalContainer/LeftPoints
@onready var right_points: Label = $VerticalContainer/HprizontalContainer/RightPoints
@onready var timer_label: Label = $VerticalContainer/HBoxContainer/TimerLabel
@onready var timer: Timer = $Timer
@onready var reset: Button = $VerticalContainer/Reset


func _ready() -> void:
	Signals.left_goal.connect(_on_left_goal_scored)
	Signals.right_goal.connect(_on_right_goal_scored)
	timer.start()
	reset.hide()
	
func  _process(delta: float) -> void:
	timer_label.text = "%02d:%02d" % [int(timer.time_left) / 60, int(timer.time_left) % 60]
	#timer_label.text = str(get_time_formatted(timer.time_left))

func _on_left_goal_scored():
	Globals.right_goals += 1
	update_score()
	
func _on_right_goal_scored():
	Globals.left_goals += 1
	update_score()

func update_score():
	left_points.text = str(Globals.left_goals)
	right_points.text = str(Globals.right_goals)
	reset.show()
	timer.set_paused(true)


#func get_time_formatted(time_left: float) -> String:
	#var minutes := int(time_left) / 60
	#var seconds := int(time_left) % 60
	#return "%02d:%02d" % [minutes, seconds]

func _on_reset_pressed() -> void:
	timer.set_paused(false)
	reset.hide()
	Signals.reset.emit()
