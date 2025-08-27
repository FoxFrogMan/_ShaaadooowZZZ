extends Node2D

class_name DialogueSystem

@export var font_size: int = 24
@export var text_color: Color = Color.BLACK
@export var border_width: int = 2
@export var padding: int = 20
@export var rect_width: int = 800
@export var rect_height: int = 600
@export var line_spacing: int = 5
@export var default_speed: float = 0.05
@export var skip_key: String = "o"
@export var next_key: String = "x"
@export var box_color: Color = Color(0, 0, 0, 0.8)

var current_char_index: int = 0
var current_line: String = ""
var lines: Array = []
var font: Font
var text_rect: Rect2
var is_typing: bool = false
var words: Array = []
var current_word_index: int = 0
var current_word_char_index: int = 0
var dialogue_data: Array = []
var current_dialogue_index: int = 0
var current_dialogue: Dictionary = {}
var typing_timer: Timer
var pause_timer: Timer
var is_paused: bool = false

var line_pause_time: float = 0.2
var punctuation_pause_time: float = 0.2
var punctuation_marks: Array = [".", "?", "!", "*", ":", ";"]

func _ready():
	font = load("res://Assets/font/undertale-deltarune.otf")
	if font == null:
		font = ThemeDB.fallback_font
	text_rect = Rect2(padding, padding, rect_width - padding * 2, rect_height - padding * 2)
	setup_timers()

func setup_timers():
	typing_timer = Timer.new()
	add_child(typing_timer)
	typing_timer.one_shot = true
	typing_timer.timeout.connect(_on_typing_timer_timeout)

	pause_timer = Timer.new()
	add_child(pause_timer)
	pause_timer.one_shot = true
	pause_timer.timeout.connect(_on_pause_timer_timeout)

func load_dialogue_json(json_path: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		return
	dialogue_data = json.data
	if dialogue_data.size() > 0:
		start_dialogue(0)

func start_dialogue(dialogue_index: int):
	if dialogue_index >= dialogue_data.size():
		return
	current_dialogue_index = dialogue_index
	current_dialogue = dialogue_data[dialogue_index]
	var dialogue_text = current_dialogue.get("text", "")
	if dialogue_text == "":
		next_dialogue()
		return
	words = Array(dialogue_text.split(" "))
	current_char_index = 0
	current_line = ""
	lines.clear()
	current_word_index = 0
	current_word_char_index = 0
	is_typing = true
	is_paused = false
	typing_timer.wait_time = current_dialogue.get("speed", default_speed)
	typing_timer.start()
	queue_redraw()

func _on_typing_timer_timeout():
	if is_paused or not is_typing:
		return
	if current_word_index >= words.size():
		is_typing = false
		return
	var current_word = str(words[current_word_index])
	if current_word_char_index < current_word.length():
		var char = current_word[current_word_char_index]
		var test_line = current_line + char
		if current_word_char_index == 0 and current_line.length() > 0:
			test_line = current_line + " " + current_word
		var text_size = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if text_size.x > text_rect.size.x and current_word_char_index == 0 and current_line.length() > 0:
			lines.append(current_line)
			current_line = ""
			pause_typing(line_pause_time)
			queue_redraw()
			return
		if current_word_char_index == 0 and current_line.length() > 0:
			current_line += " "
		current_line += char
		current_word_char_index += 1
		if char in punctuation_marks:
			pause_typing(punctuation_pause_time)
			queue_redraw()
			return
		queue_redraw()
	else:
		current_word_index += 1
		current_word_char_index = 0
	typing_timer.wait_time = current_dialogue.get("speed", default_speed)
	typing_timer.start()

func pause_typing(pause_duration: float):
	is_paused = true
	pause_timer.wait_time = pause_duration
	pause_timer.start()

func _on_pause_timer_timeout():
	is_paused = false
	if is_typing:
		typing_timer.wait_time = current_dialogue.get("speed", default_speed)
		typing_timer.start()

func next_dialogue():
	if current_dialogue_index + 1 < dialogue_data.size():
		start_dialogue(current_dialogue_index + 1)
	else:
		queue_free()

func _draw():
	draw_rect(Rect2(0, 0, rect_width, rect_height), box_color)
	var speaker_name = current_dialogue.get("name", "")
	var y_offset = padding
	if speaker_name != "":
		var name_pos = Vector2(padding, y_offset + font_size)
		draw_string(font, name_pos, speaker_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLUE)
		y_offset += font_size + 10
	y_offset += font_size
	for i in range(lines.size()):
		var line_pos = Vector2(padding, y_offset + i * (font_size + line_spacing))
		draw_string(font, line_pos, str(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
	if current_line.length() > 0:
		var current_line_pos = Vector2(padding, y_offset + lines.size() * (font_size + line_spacing))
		draw_string(font, current_line_pos, current_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

func _input(event):
	if event.is_action_pressed(skip_key):
		if is_typing:
			skip_typing()
	elif event.is_action_pressed(next_key):
		if not is_typing:
			next_dialogue()
	elif event.is_action_pressed("ui_cancel"):
		restart_dialogue()

func skip_typing():
	is_typing = false
	is_paused = false
	typing_timer.stop()
	pause_timer.stop()
	lines.clear()
	current_line = ""
	var temp_line = ""
	for word in words:
		var test_line = temp_line
		if temp_line.length() > 0:
			test_line += " "
		test_line += str(word)
		var text_size = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if text_size.x > text_rect.size.x and temp_line.length() > 0:
			lines.append(temp_line)
			temp_line = str(word)
		else:
			temp_line = test_line
	if temp_line.length() > 0:
		lines.append(temp_line)
	queue_redraw()

func restart_dialogue():
	current_dialogue_index = 0
	if dialogue_data.size() > 0:
		start_dialogue(0)

func set_dialogue_json(json_path: String):
	load_dialogue_json(json_path)

func set_dialogue(dialogue_index: int):
	if dialogue_index >= 0 and dialogue_index < dialogue_data.size():
		start_dialogue(dialogue_index)

func get_current_dialogue_info() -> Dictionary:
	return current_dialogue

func is_currently_typing() -> bool:
	return is_typing
