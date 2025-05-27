extends Node2D
class_name Field

func _on_right_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		print("ball")
		Signals.right_goal.emit()


func _on_left_goal_area_body_entered(body: Node2D) -> void:
	if body is Ball:
		Signals.left_goal.emit()
