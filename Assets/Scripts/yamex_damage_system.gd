extends Node2D

signal registered

@onready var bar: Node2D = $Bar
@onready var bar2: Node2D = $Bar2
@onready var bar3: Node2D = $Bar3
@onready var bar4: Node2D = $Bar4

@onready var bars: Array = [
	bar,
	bar2,
	bar3,
	bar4
]

@onready var arrows: Array = [
	$Arrow1,
	$Arrow2,
	$Arrow3,
	$Arrow4
]

var stock_pattern = {}
var bar_speed = 0.8
var strike_force = 0.0

func _start_damage_sequence():
	for i in range(bars.size()):
		var bar = bars[i]
		bar.scale = Vector2(3, 3)
	for arrow_node in arrows:
		strike_force = 0.0
		Global.strike_force = 0
		var arrow = arrow_node.get_node("Arrow")
		arrow.modulate = Color(1, 1, 1, 1)
		arrow.scale = Vector2(1, 1)
		arrow.z_index = 0
	_generate_random_pattern()
	_apply_stock_pattern()
	await slide_down()
	for i in range(bars.size()):
		await _DamageInput(bars[i], i)
	slide_up()
	emit_signal("registered")

func _generate_random_pattern():
	var directions = ["right", "left", "up", "down"]
	stock_pattern.clear()
	for i in range(4):
		var random_direction = directions[randi() % directions.size()]
		stock_pattern[i] = random_direction

func _apply_stock_pattern():
	for i in range(4):
		var arrow_node = arrows[i]
		var direction = stock_pattern[i]
		var path = "res://Assets/Sprites/Battle/arrow_%s.png" % direction
		arrow_node.get_node("Arrow").texture = load(path)

func _DamageInput(obj: Node2D, index: int) -> void:
	obj.scale = Vector2(3.0, 3.0)
	obj.modulate.a = 0.0
	var tww = create_tween()
	tww.tween_property(obj, "modulate:a", 1.0, bar_speed / 2.5)
	tww.parallel().tween_property(obj, "scale", Vector2(0, 0), bar_speed)
	
	var correct_input = await _WaitingInput(tww, obj, index)

	if correct_input:
		var scale_length = obj.scale.length()
		var ideal_length = Vector2(1, 1).length()
		var deviation = abs(scale_length - ideal_length)
		var score = 1.0 - deviation
		score = clamp(score, 0.0, 1.0)
		strike_force += score / 4
		Global.strike_force = snapped(strike_force, 0.01)

func _WaitingInput(tween_to_kill: Tween, obj: Node2D, index: int) -> bool:
	var direction = stock_pattern.get(index, "none")
	var expected_input = ""
	match direction:
		"right":
			expected_input = "ui_right"
		"left":
			expected_input = "ui_left"
		"up":
			expected_input = "ui_up"
		"down":
			expected_input = "ui_down"
		_:
			expected_input = ""

	var all_inputs = ["ui_right", "ui_left", "ui_up", "ui_down"]
	while true:
		await get_tree().process_frame
		for input_name in all_inputs:
			if Input.is_action_just_pressed(input_name):
				if tween_to_kill.is_running():
					tween_to_kill.kill()
				var arrow = arrows[index].get_node("Arrow")
				if input_name == expected_input:
					obj.modulate = Color(0, 1, 0)
				else:
					obj.modulate = Color(1, 0, 0)
				arrow.z_index = 1
				var fade_out = create_tween()
				fade_out.tween_property(obj, "modulate:a", 0.0, bar_speed / 2.5)
				fade_out.parallel().tween_property(arrow, "modulate:a", 0.0, bar_speed / 2.5)
				fade_out.parallel().tween_property(arrow, "scale", arrow.scale + Vector2(1, 1), bar_speed / 2.5)
				await fade_out.finished
				obj.modulate = Color(1, 1, 1, 0)
				arrow.z_index = 0
				return input_name == expected_input
	return false



func slide_down():
	var tween_speed = 1.0
	var target_pos = Vector2(100, 12)
	var tween_pos = create_tween()
	tween_pos.tween_property(self, "position:y", target_pos.y, tween_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween_pos.finished
	pass

func slide_up():
	var tween_speed = 1.0
	var target_pos = Vector2(100, -7.6)
	var tween_pos = create_tween()
	tween_pos.tween_property(self, "position:y", target_pos.y, tween_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween_pos.finished
	pass
