extends CanvasLayer

class_name DialogueManagerV1

signal dialogue_finished

@onready var text_box: MarginContainer = $TextBoxContainer
@onready var name_label: Label = $TextBoxContainer/text/Name
@onready var dialogue_text := $TextBoxContainer/MarginContainer/HBoxContainer/Text
@onready var texture := $texture
@onready var text_box_container: MarginContainer = $TextBoxContainer/MarginContainer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var snd_anim: AnimationPlayer = $AudioStreamPlayer2D/AnimationPlayer
@onready var texture_img: Sprite2D = $texture/TextureIMG
@onready var name_char: MarginContainer = $TextBoxContainer/text

var dialogue_data = []
var current_index = 0
var tween: Tween
var typing_speed := 0.03

enum State { IDLE, READING, FINISHED }
var state = State.IDLE

func _ready() -> void:
	TranslationServer.set_locale("en")
	set_dialogue("res://Assets/Strings/cutscene_1.json")

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

func _show_next_line():
	if current_index >= dialogue_data.size():
		_hide_textbox()
		emit_signal("dialogue_finished")
		state = State.IDLE
		return
	
	var line = dialogue_data[current_index]
	current_index += 1
	
	name_label.text = line.get("name", "")
	dialogue_text.text = line.get("text", "")
	dialogue_text.visible_ratio = 0.0
	
	# عرض الصورة مع الجهة
	if line.get("image", "") != "":
		texture_img.texture = load(line["image"])
		var side = line.get("image_side", "0")
		if side == "1":
			image_right()
		else:
			image()
	else:
		unimage()
		
	# تشغيل الصوت إن وُجد
	if line.get("sound", "") != "":
		audio_player.stream = load(line["sound"])
		audio_player.play()
		snd_anim.play("snd")
	else:
		snd_anim.stop()
		
	text_box.show()
	state = State.READING
	tween = create_tween()
	tween.tween_property(dialogue_text, "visible_ratio", 1.0, dialogue_text.text.length() * typing_speed)
	await tween.finished
	state = State.FINISHED
	snd_anim.stop()

# الصورة يسار
func image():
	texture.show()
	texture.position.x = 40
	texture_img.flip_h = false
	name_char.add_theme_constant_override("margin_left", 200)
	text_box_container.add_theme_constant_override("margin_left", 178)
	text_box_container.add_theme_constant_override("margin_right", 20)

# الصورة مخفية
func unimage():
	texture.hide()
	name_char.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_left", 32)

# الصورة يمين
func image_right():
	texture.show()
	texture.position.x = 580  # عدّل حسب حجم الـ UI لديك
	name_char.add_theme_constant_override("margin_left", 56)
	text_box_container.add_theme_constant_override("margin_left", 32)
	text_box_container.add_theme_constant_override("margin_right", 178)

# الصورة يمين مخفية
func unimage_right():
	texture.hide()
	name_char.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_right", 20)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		match state:
			State.READING:
				tween.kill()
				dialogue_text.visible_ratio = 1.0
				state = State.FINISHED
				snd_anim.stop()
			State.FINISHED:
				_show_next_line()

func _hide_textbox():
	texture.hide()
	text_box.hide()
	name_label.text = ""
	dialogue_text.text = ""
