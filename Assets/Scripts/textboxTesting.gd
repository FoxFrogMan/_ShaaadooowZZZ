extends CanvasLayer


@onready var text_box: MarginContainer = $TextBoxContainer
@onready var name_label: Label = $TextBoxContainer/text/Name
@onready var dialogue_text := $TextBoxContainer/MarginContainer/HBoxContainer/Text
@onready var texture := $texture
@onready var texture2 := $texture2
@onready var text_box_container: MarginContainer = $TextBoxContainer/MarginContainer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
#@onready var end_label: Label = $TextBoxContainer/MarginContainer/HBoxContainer/End
@onready var snd_anim: AnimationPlayer = $AudioStreamPlayer2D/AnimationPlayer
@onready var texture_img: Sprite2D = $texture/TextureIMG
@onready var name_char: MarginContainer = $TextBoxContainer/text
@onready var name_char2: MarginContainer = $TextBoxContainer/text2

var dialogue_data = []
var current_index = 0
var tween: Tween
var typing_speed := 0.03

enum State { IDLE, READING, FINISHED }
var state = State.IDLE

func _ready() -> void:
	TranslationServer.set_locale("en")


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
	#end_label.text = ""
	
	if line.get("image", "") != "":
		texture_img.texture = load(line["image"])
		image()
	else:
		unimage()

		
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
	#end_label.text = "v"
	snd_anim.stop()

func image():
	texture.show()
	name_char.add_theme_constant_override("margin_left", 215)
	text_box_container.add_theme_constant_override("margin_left", 178)

func unimage():
	texture.hide()
	name_char.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_left", 32)
	

func image_right():
	texture2.show()
	name_char2.add_theme_constant_override("margin_left", 468)
	text_box_container.add_theme_constant_override("margin_right", 178)


func unimage_right():
	texture2.hide()
	name_char2.add_theme_constant_override("margin_left", 320)
	text_box_container.add_theme_constant_override("margin_right", 20)
	


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		match state:
			State.READING:
				tween.kill()
				dialogue_text.visible_ratio = 1.0
				#end_label.text = "v"
				state = State.FINISHED
				snd_anim.stop()
			State.FINISHED:
				_show_next_line()

func _hide_textbox():
	texture.hide()
	text_box.hide()
	name_label.text = ""
	dialogue_text.text = ""
	#end_label.text = ""
