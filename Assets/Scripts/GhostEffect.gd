extends Sprite2D

var ghost_timer := 0.0
var start_time := 0.0

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0

func _process(delta):
	var current_time = Time.get_ticks_msec() / 1000.0 - start_time
	apply_float_motion(self, current_time)

	ghost_timer += delta
	if ghost_timer >= 0.075:
		ghost_timer = 0.0
		spawn_ghost()

func spawn_ghost():
	var ghost = Sprite2D.new()
	ghost.position = global_position
	ghost.scale = scale
	ghost.texture = texture
	ghost.region_enabled = region_enabled
	ghost.region_rect = region_rect
	ghost.modulate.a = 0.8
	ghost.z_index = z_index - 1
	get_tree().current_scene.add_child(ghost)

	var tween = ghost.create_tween()
	tween.tween_property(ghost, "position:x", ghost.position.x + 20, 0.5)
	tween.parallel().tween_property(ghost, "modulate:a", 0.0, 0.5)
	tween.tween_callback(ghost.queue_free)

func apply_float_motion(node: Node2D, time: float, amplitude := 0.15, speed := 3.0) -> void:
	var y_offset := sin(time * speed) * amplitude
	node.position.y = position.y + y_offset
