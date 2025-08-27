extends Node2D

@onready var camera: Camera2D = %camera

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	camera.global_position = get_parent().get_node("%" + SaveLoader.party[0]).global_position
	pass
