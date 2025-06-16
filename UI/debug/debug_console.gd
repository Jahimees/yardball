extends Control

@onready var fps_label: Label = $MarginContainer/VBoxContainer/MarginContainer/FpsLabel
@onready var physics_frames_label: Label = $MarginContainer/VBoxContainer/MarginContainer2/physicsFramesLabel

func _process(delta: float) -> void:
	if OS.is_debug_build():
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		physics_frames_label.text = "Physics Frames: " + str(Engine.get_physics_frames())
