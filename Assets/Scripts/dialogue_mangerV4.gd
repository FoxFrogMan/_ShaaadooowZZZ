extends CanvasLayer

class_name DialogueManagerV4

signal dialogue_finished

@onready var text_box: MarginContainer = $TextBoxContainer
@onready var name_label: Label = $TextBoxContainer/text/Name
@onready var dialogue_text: RichTextLabel = $TextBoxContainer/MarginContainer/HBoxContainer/Text
@onready var texture := $texture
@onready var text_box_container: MarginContainer = $TextBoxContainer/MarginContainer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var snd_anim: AnimationPlayer = $AudioStreamPlayer2D/AnimationPlayer
@onready var texture_img: Sprite2D = $texture/TextureIMG
@onready var name_char: MarginContainer = $TextBoxContainer/text

var dialogue_data = []
var current_index = 0
var typing_speed := 0.03
var skip_allowed := true

enum State { IDLE, READING, FINISHED }
var state = State.IDLE

var image_timer: Timer
var image_index: int = 0
var image_list: Array = []
var typing_sounds: Array = []

func _ready() -> void:
	TranslationServer.set_locale("en")
	image_timer = Timer.new()
	image_timer.one_shot = false
	image_timer.timeout.connect(_on_image_timer_timeout)
	add_child(image_timer)

func set_dialogue(file_path):
	load_dialogue(file_path)

func load_dialogue(json_path: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		printerr("فشل في فتح الملف: ", json_path)
		return
	var content = file.get_as_text()
	dialogue_data = JSON.parse_string(content)
	current_index = 0
	_show_next_line()

func _show_next_line() -> void:
	if current_index >= dialogue_data.size():
		_hide_textbox()
		emit_signal("dialogue_finished")
		state = State.IDLE
		return

	var line = dialogue_data[current_index]
	current_index += 1

	name_label.text = line.get("name", "")
	dialogue_text.clear()
	dialogue_text.visible_characters = 0
	dialogue_text.bbcode_enabled = false

	var local_speed = line.get("speed", typing_speed)
	skip_allowed = not line.get("no_skip", false)
	var anim = snd_anim.get_animation("snd")
	anim.length = local_speed

	image_index = 0
	image_list = []
	image_timer.stop()

	typing_sounds = []
	if line.has("sound_list"):
		typing_sounds = line["sound_list"]

	var image_data = line.get("image", "")
	if typeof(image_data) == TYPE_ARRAY:
		image_list = image_data
	elif typeof(image_data) == TYPE_STRING and image_data != "":
		image_list = [image_data]

	if image_list.size() > 0:
		var side = line.get("image_side", "0")
		if side == "1":
			image_right()
		else:
			image()
		texture_img.texture = load(image_list[0])
		if image_list.size() > 1:
			var duration = line.get("image_duration", 0.2)
			image_timer.wait_time = duration
			image_timer.start()
	else:
		unimage()

	if line.has("sound") and line["sound"] != "":
		audio_player.stream = load(line["sound"])
		audio_player.play()
		snd_anim.play("snd")
	else:
		snd_anim.stop()

	text_box.show()
	state = State.READING
	await get_tree().process_frame
	await type_text_wrapped(line.get("text", ""), local_speed)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		match state:
			State.READING:
				if skip_allowed:
					dialogue_text.visible_characters = -1
					state = State.FINISHED
					snd_anim.stop()
			State.FINISHED:
				_show_next_line()

func type_text_wrapped(full_text: String, speed: float) -> void:
	dialogue_text.clear()
	dialogue_text.bbcode_enabled = false
	dialogue_text.visible_characters = 0

	await get_tree().process_frame
	var font := dialogue_text.get_theme_font("normal_font")
	var font_size := dialogue_text.get_theme_font_size("normal_font_size")
	var max_width: float = dialogue_text.get_parent().size.x

	var lines := []
	var current_line := ""

	for word in full_text.split(" "):
		var space := "" if current_line == "" else " "
		var test_line := current_line + space + word
		var line_width := font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		if line_width > max_width:
			lines.append(current_line)
			current_line = word
		else:
			current_line = test_line

	if current_line != "":
		lines.append(current_line)

	var full_result := ""
	for line in lines:
		if full_result != "":
			full_result += "\n"
		for i in line.length():
			full_result += line[i]
			dialogue_text.text = full_result
			dialogue_text.visible_characters = -1
			play_typing_sound()
			await get_tree().create_timer(speed).timeout

	state = State.FINISHED
	snd_anim.stop()

	if not skip_allowed:
		await get_tree().create_timer(0.2).timeout
		_show_next_line()

func play_typing_sound():
	if typing_sounds.size() > 0:
		var rand = randi() % typing_sounds.size()
		audio_player.stream = load(typing_sounds[rand])
		audio_player.play()

func image():
	texture.show()
	texture.position.x = 40
	texture_img.flip_h = false
	name_char.add_theme_constant_override("margin_left", 200)
	text_box_container.add_theme_constant_override("margin_left", 178)
	text_box_container.add_theme_constant_override("margin_right", 20)

func unimage():
	texture.hide()
	name_char.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_left", 32)

func image_right():
	texture.show()
	texture.position.x = 580
	texture_img.flip_h = true
	name_char.add_theme_constant_override("margin_left", 56)
	text_box_container.add_theme_constant_override("margin_left", 32)
	text_box_container.add_theme_constant_override("margin_right", 178)

func unimage_right():
	texture.hide()
	name_char.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_right", 20)

func _hide_textbox():
	texture.hide()
	text_box.hide()
	name_label.text = ""
	dialogue_text.text = ""
	image_timer.stop()

func _on_image_timer_timeout():
	image_index += 1
	if image_index >= image_list.size():
		image_index = 0
	texture_img.texture = load(image_list[image_index])
