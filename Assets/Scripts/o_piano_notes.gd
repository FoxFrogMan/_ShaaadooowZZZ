extends Node2D

@export var spawn_interval: float = 0.5

var markers: Array[Node2D] = []
var spawn_timer: float = 0.0
var last_marker_index: int = -1
var regions = [
	Rect2(Vector2(18.0, 3.0), Vector2(12.0, 10.0)),
	Rect2(Vector2(4.0, 3.0), Vector2(8.0, 10.0))
]

func _ready() -> void:
	randomize()
	for child in get_children():
		if child is Marker2D:
			markers.append(child)

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_object()

func _spawn_object() -> void:
	if markers.is_empty():
		return
	var index := randi() % markers.size()
	while index == last_marker_index and markers.size() > 1:
		index = randi() % markers.size()
	last_marker_index = index
	var marker = markers[index]
	var instance := preload("res://Assets/Scenes/piano_notes.tscn").instantiate()
	instance.global_position = marker.global_position
	instance.region_rect = regions[randi() % regions.size()]
	marker.add_child(instance)
	if instance.has_node("Anim"):
		var anim = instance.get_node("Anim")
		anim.play("Idle")
		anim.connect("animation_finished", Callable(instance, "_on_anim_finished"))

func _on_anim_finished():
	queue_free()
