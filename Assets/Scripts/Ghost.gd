extends Sprite2D

@onready var ghost_timer := Timer.new()

#var amplitude := 5.0
#var frequency := 2
#var base_y := 0.0
#var time := 0.0
#
#func _process(delta):
	#time += delta
	#position.y = base_y + sin(time * frequency * PI * 2) * amplitude


func _ready() -> void:
	#base_y = position.y 
	_ghost(1.5, 1.25)
	ghost_timer.wait_time = 0.5
	ghost_timer.one_shot = false
	ghost_timer.autostart = true
	add_child(ghost_timer)
	ghost_timer.timeout.connect(_on_ghost_timer_timeout)
	
func _on_ghost_timer_timeout() -> void:
	_ghost(1.5, 1.25)

func _ghost(time: float, value: float) -> void:
	var ghost := Sprite2D.new()
	ghost.texture = texture
	ghost.global_position = global_position
	ghost.global_scale = global_scale
	ghost.flip_h = flip_h
	ghost.flip_v = flip_v
	ghost.rotation = rotation
	ghost.z_index = z_index - 1
	ghost.modulate = Color(1, 1, 1, 1)
	get_tree().current_scene.add_child(ghost)

	var tween_scale := get_tree().create_tween()
	var tween_fade := get_tree().create_tween()
	tween_scale.tween_property(ghost, "scale", ghost.scale * value, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_fade.tween_property(ghost, "modulate:a", 0.0, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_scale.tween_callback(Callable(ghost, "queue_free"))
