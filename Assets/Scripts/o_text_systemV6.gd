extends Node2D

@export var font_size: int = 28
@export var name_font_size: int = 24
@export var text_color: Color = Color.WHITE
@export var border_width: int = 2
@export var padding: int = 20
@export var rect_width: int = 725
@export var rect_height: int = 179
@export var line_spacing: int = 5
@export var default_speed: float = 0.05
@export var skip_key: String = "o"
@export var next_key: String = "x"
@export var box_color: Color = Color(0, 0, 0, 0.8)
@export var image_scale: float = 3.0


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
var char_sound: AudioStreamPlayer
var image_texture: Texture2D
var image_size: Vector2
var image_side_padding: int = 10
var image_side: int = 0

var line_pause_time: float = 0.2
var punctuation_pause_time: float = 0.35
var punctuation_marks: Array = [".", "?", "!", "*", ":", ";"]

func _ready():
	font = load("res://undertale-deltarune.otf")
	if font == null:
		font = ThemeDB.fallback_font
	setup_timers()
	char_sound = AudioStreamPlayer.new()
	add_child(char_sound)

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
	words = Array(str(current_dialogue.get("text", "")).split(" "))
	current_char_index = 0
	current_line = ""
	lines.clear()
	current_word_index = 0
	current_word_char_index = 0
	is_typing = true
	is_paused = false

	if current_dialogue.has("sound"):
		char_sound.stream = load(current_dialogue["sound"])

	if current_dialogue.has("image"):
		image_texture = load(current_dialogue["image"])
		image_side = int(current_dialogue.get("image_side", "0"))
		image_size = image_texture.get_size() * image_scale if image_texture else Vector2(128, 128)
		if image_texture:
			image_texture = image_texture.duplicate()
			image_texture.set("flags/filter", false)
	else:
		image_texture = null
		image_size = Vector2.ZERO

	var left_offset = 0
	var right_offset = 0
	if image_texture:
		if image_side == 0:
			right_offset = image_size.x + image_side_padding
		else:
			left_offset = image_size.x + image_side_padding
	text_rect = Rect2(padding + left_offset, padding, rect_width - padding * 2 - left_offset - right_offset, rect_height - padding * 2)

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
		if char_sound.stream:
			char_sound.play()
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
		var name_pos = Vector2(text_rect.position.x, y_offset + name_font_size)
		draw_string(font, name_pos, speaker_name, HORIZONTAL_ALIGNMENT_LEFT, -1, name_font_size, Color.BLUE)
		y_offset += name_font_size + 10
	y_offset += font_size
	for i in range(lines.size()):
		var line_pos = Vector2(text_rect.position.x, y_offset + i * (font_size + line_spacing))
		draw_string(font, line_pos, str(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
	if current_line.length() > 0:
		var current_line_pos = Vector2(text_rect.position.x, y_offset + lines.size() * (font_size + line_spacing))
		draw_string(font, current_line_pos, current_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
	if image_texture:
		var image_pos = Vector2()
		if image_side == 0:
			image_pos = Vector2(rect_width - image_size.x - image_side_padding, rect_height - image_size.y - image_side_padding)
		else:
			image_pos = Vector2(image_side_padding, rect_height - image_size.y - image_side_padding)
		draw_texture_rect(image_texture, Rect2(image_pos, image_size), false)

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
