extends Node2D


@export var font_size: int = 20
@export var name_font_size: int = 24
@export var text_color: Color = Color.WHITE
@export var border_width: int = 4
@export var padding: int = 25
@export var rect_width: int = 576
@export var rect_height: int = 128
@export var line_spacing: int = 4
@export var default_speed: float = 0.02
@export var skip_key: String = "o"
@export var next_key: String = "x"
@export var box_color: Color = Color(0, 0, 0, 1)
@export var image_scale: float = 3.0

# متغيرات الخيارات المحدثة
@export var option_spacing: int = 30          # المسافة بين الخيارات
@export var option_fixed_y: int = 100        # الموقع الثابت للخيارات من أعلى الصندوق

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
var image_animation_timer: Timer
var is_paused: bool = false
var char_sound: AudioStreamPlayer
var image_textures: Array[Texture2D] = []
var current_image_index: int = 0
var image_duration: float = 0.0
var image_size: Vector2
var image_side_padding: int = 10
var image_side: int = 0
var auto_advance: bool = false

var line_pause_time: float = 0.2
var punctuation_pause_time: float = 0.2
var punctuation_marks: Array = [".", "", "!", ",", ":", ";"]

# إعلان الإشارات المخصصة
signal dialogue_finished
signal option_selected(option_index: int, option_text: String)
signal custom_signal_triggered(signal_name: String, signal_data: Dictionary)

# متغيرات جديدة للألوان
var color_codes: Dictionary = {
	"[red]": Color.RED,
	"[green]": Color.GREEN,
	"[blue]": Color.BLUE,
	"[yellow]": Color.YELLOW,
	"[purple]": Color.PURPLE,
	"[cyan]": Color.CYAN,
	"[orange]": Color.ORANGE,
	"[pink]": Color.PINK,
	"[white]": Color.WHITE,
	"[black]": Color.BLACK,
	"[gray]": Color.GRAY,
	"[lime]": Color.LIME_GREEN,
	"[brown]": Color(0.6, 0.4, 0.2, 1.0)
}

var processed_words: Array = []  # الكلمات بعد معالجة أكواد الألوان
var word_colors: Array = []      # ألوان الكلمات المقابلة
var current_word_color: Color = Color.WHITE

# متغيرات الخيارات
var has_options: bool = false
var options: Array = []
var current_option_index: int = 0
var option_color_selected: Color = Color(1.0, 0.7, 0.2, 1.0)  # أصفر مايل للبرتقالي
var option_color_normal: Color = Color.WHITE
var option_prefix: String = ""

# متغيرات جديدة للخيارات الأفقية
var option_positions: Array = []  # مواضع الخيارات
var total_options_width: float = 0  # العرض الإجمالي للخيارات

# متغيرات سلسلة النصوص للخيارات
var option_dialogue_sequence: Array = []
var current_option_dialogue_index: int = 0
var is_in_option_sequence: bool = false

func _ready():
	font = load("res://Assets/font/undertale-deltarune-text-font-extended.otf")
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

	image_animation_timer = Timer.new()
	add_child(image_animation_timer)
	image_animation_timer.timeout.connect(_on_image_animation_timeout)

func calculate_horizontal_options_positions():
	"""حساب مواضع الخيارات الأفقية في موقع ثابت"""
	option_positions.clear()
	total_options_width = 0
	
	if options.size() == 0:
		return
	
	# حساب عرض كل خيار
	var option_widths: Array = []
	for i in range(options.size()):
		var option_text = str(options[i])
		var width = font.get_string_size(option_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		option_widths.append(width)
		total_options_width += width
	
	# إضافة المسافات بين الخيارات
	if options.size() > 1:
		total_options_width += option_spacing * (options.size() - 1)
	
	# حساب نقطة البداية (من المنتصف)
	var start_x = (rect_width - total_options_width) / 2.0
	
	# حساب موضع كل خيار باستخدام الموقع الثابت
	var current_x = start_x
	var fixed_y = option_fixed_y  # استخدام الموقع الثابت
	
	for i in range(options.size()):
		option_positions.append(Vector2(current_x, fixed_y))
		current_x += option_widths[i] + option_spacing

func load_dialogue_json(json_path: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("خطأ: لا يمكن فتح الملف: ", json_path)
		return
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("خطأ في تحليل JSON: ", json.get_error_message())
		return
	dialogue_data = json.data
	if dialogue_data.size() > 0:
		start_dialogue(0)

func process_color_codes(text: String) -> void:
	"""معالجة أكواد الألوان وإنشاء قوائم الكلمات والألوان"""
	processed_words.clear()
	word_colors.clear()
	
	var current_color = text_color
	var processed_text = text
	
	# معالجة أكواد النص الملون المحدد [color: text]
	var regex = RegEx.new()
	regex.compile("\\[([a-zA-Z]+):\\s*([^\\]]+)\\]")
	
	var result = regex.search(processed_text)
	while result:
		var color_name = result.get_string(1).to_lower()
		var colored_text = result.get_string(2)
		var full_match = result.get_string(0)
		
		# التحقق من وجود اللون في القاموس
		var color_key = "[" + color_name + "]"
		if color_key in color_codes:
			# استبدال النص الملون بالنص العادي مع إضافة معرف مؤقت
			var temp_marker = "<!COLOR_" + str(processed_words.size()) + "_" + color_name + "!>" + colored_text + "<!END_COLOR!>"
			processed_text = processed_text.replace(full_match, temp_marker)
		
		result = regex.search(processed_text)
	
	# تقسيم النص إلى كلمات (مع الحفاظ على \n)
	var raw_words = processed_text.replace("\n", " \n ").split(" ")
	
	for word in raw_words:
		var word_str = str(word)
		
		# التحقق من وجود معرف لون مؤقت
		if word_str.begins_with("<!COLOR_"):
			var end_marker_pos = word_str.find("!>")
			if end_marker_pos != -1:
				var color_info = word_str.substr(8, end_marker_pos - 8)  # إزالة "<!COLOR_"
				var parts = color_info.split("_")
				if parts.size() >= 2:
					var color_name = parts[1]
					var color_key = "[" + color_name + "]"
					if color_key in color_codes:
						current_color = color_codes[color_key]
				
				# إزالة المعرف المؤقت
				word_str = word_str.substr(end_marker_pos + 2)
		
		# التحقق من نهاية النص الملون
		if word_str.ends_with("<!END_COLOR!>"):
			word_str = word_str.replace("<!END_COLOR!>", "")
			# إعادة تعيين اللون الافتراضي بعد انتهاء النص الملون
			var next_color = text_color
			
			# إضافة الكلمة إذا لم تكن فارغة
			if word_str.length() > 0:
				processed_words.append(word_str)
				word_colors.append(current_color)
			
			current_color = next_color
			continue
		
		# البحث عن كود لون تقليدي في بداية الكلمة (للدعم المزدوج)
		var color_found = false
		for code in color_codes.keys():
			if word_str.begins_with(code):
				current_color = color_codes[code]
				word_str = word_str.substr(code.length())  # إزالة كود اللون
				color_found = true
				break
		
		# إضافة الكلمة إذا لم تكن فارغة
		if word_str.length() > 0:
			processed_words.append(word_str)
			word_colors.append(current_color)
		# إذا كانت الكلمة فقط كود لون، لا نضيفها للقائمة
		elif not color_found and not word_str.begins_with("<!"):
			processed_words.append(word_str)
			word_colors.append(current_color)

func start_dialogue(dialogue_index: int):
	if dialogue_index >= dialogue_data.size():
		return
	current_dialogue_index = dialogue_index
	current_dialogue = dialogue_data[dialogue_index]
	auto_advance = current_dialogue.get("no_skip", false)
	
	# التحقق من وجود خيارات
	has_options = current_dialogue.has("options")
	if has_options:
		options = current_dialogue.get("options", [])
		current_option_index = 0
	else:
		options.clear()
	
	# معالجة النص وأكواد الألوان
	var dialogue_text = str(current_dialogue.get("text", ""))
	process_color_codes(dialogue_text)
	
	words = processed_words
	current_char_index = 0
	current_line = ""
	lines.clear()
	current_word_index = 0
	current_word_char_index = 0
	is_typing = true
	is_paused = false
	image_textures.clear()
	current_image_index = 0
	image_animation_timer.stop()
	
	# تعيين لون الكلمة الحالية
	if word_colors.size() > 0:
		current_word_color = word_colors[0]
	else:
		current_word_color = text_color

	if current_dialogue.has("sound"):
		char_sound.stream = load(current_dialogue["sound"])

	if current_dialogue.has("image"):
		var image_data = current_dialogue["image"]
		if image_data is Array:
			for path in image_data:
				var tex = load(path)
				if tex:
					image_textures.append(tex.duplicate())
					image_textures[-1].set("flags/filter", false)
		else:
			var tex = false
			if FileAccess.file_exists(image_data):
				tex = load(image_data)
			if tex:
				image_textures.append(tex.duplicate())
				image_textures[-1].set("flags/filter", false)

		image_duration = current_dialogue.get("image_duration", 0.2)
		if image_textures.size() > 1:
			image_animation_timer.wait_time = image_duration
			image_animation_timer.start()

	image_side = int(current_dialogue.get("image_side", "0"))
	image_size = image_textures[0].get_size() * image_scale if image_textures.size() > 0 else Vector2(128, 128)

	var left_offset = 0
	var right_offset = 0
	if image_textures.size() > 0:
		
		if image_side == 0:
			left_offset = image_size.x + image_side_padding
		else:
			right_offset = image_size.x + image_side_padding

	text_rect = Rect2(padding + left_offset, padding, rect_width - padding * 2 - left_offset - right_offset, rect_height - padding * 2)

	typing_timer.wait_time = current_dialogue.get("speed", default_speed)
	typing_timer.start()
	
	# حساب مواضع الخيارات عند بدء الحوار
	if has_options:
		calculate_horizontal_options_positions()
	
	queue_redraw()

func _on_image_animation_timeout():
	current_image_index = (current_image_index + 1) % image_textures.size()
	image_animation_timer.start()
	queue_redraw()

func _on_typing_timer_timeout():
	if is_paused or not is_typing:
		return

	if current_word_index >= words.size():
		is_typing = false
		# إضافة السطر الحالي إذا لم يكن فارغاً
		if current_line.length() > 0:
			lines.append(current_line)
			current_line = ""
		
		queue_redraw()
		if auto_advance and not has_options:
			await get_tree().create_timer(0.5).timeout
			next_dialogue()
		return

	# تحديث لون الكلمة الحالية
	if current_word_index < word_colors.size():
		current_word_color = word_colors[current_word_index]

	var current_word = str(words[current_word_index])
	if current_word == "\n":
		lines.append(current_line)
		current_line = ""
		current_word_index += 1
		current_word_char_index = 0
		queue_redraw()
		# إزالة التوقف التلقائي بين الأسطر - فقط للـ \n المحددة يدوياً
		pause_typing(line_pause_time)
		return

	if current_word_char_index < current_word.length():
		@warning_ignore("shadowed_global_identifier")
		var char = current_word[current_word_char_index]
		var test_line = current_line + char
		if current_word_char_index == 0 and current_line.length() > 0:
			test_line = current_line + " " + current_word
		var text_size = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if text_size.x > text_rect.size.x and current_word_char_index == 0 and current_line.length() > 0:
			lines.append(current_line)
			current_line = ""
			# لا نضيف توقف هنا - نكمل الكتابة مباشرة
			queue_redraw()
			typing_timer.wait_time = current_dialogue.get("speed", default_speed)
			typing_timer.start()
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

func start_option_dialogue_sequence(dialogues: Array):
	"""بدء سلسلة النصوص الخاصة بالخيار المحدد"""
	option_dialogue_sequence = dialogues
	current_option_dialogue_index = 0
	is_in_option_sequence = true
	start_option_dialogue(option_dialogue_sequence[0])

func start_option_dialogue(dialogue_dict: Dictionary):
	"""بدء حوار من سلسلة نصوص الخيار"""
	# تعيين الحوار الحالي مؤقتاً
	var original_dialogue = current_dialogue
	current_dialogue = dialogue_dict
	
	# إعادة تعيين المتغيرات
	has_options = dialogue_dict.has("options")
	if has_options:
		options = dialogue_dict.get("options", [])
		current_option_index = 0
	else:
		options.clear()
	
	# معالجة النص وأكواد الألوان
	var dialogue_text = str(dialogue_dict.get("text", ""))
	process_color_codes(dialogue_text)
	
	words = processed_words
	current_char_index = 0
	current_line = ""
	lines.clear()
	current_word_index = 0
	current_word_char_index = 0
	is_typing = true
	is_paused = false
	
	# تعيين لون الكلمة الحالية
	if word_colors.size() > 0:
		current_word_color = word_colors[0]
	else:
		current_word_color = text_color

	# معالجة الصوت إذا كان موجود
	if dialogue_dict.has("sound"):
		char_sound.stream = load(dialogue_dict["sound"])

	# بدء الكتابة
	typing_timer.wait_time = dialogue_dict.get("speed", default_speed)
	typing_timer.start()
	
	# التحقق من وجود إشارة مخصصة وإطلاقها عند بدء حوار الخيار
	call_deferred("check_and_emit_custom_signal")
	
	queue_redraw()

func next_dialogue():
	# إذا كنا في سلسلة نصوص الخيارات
	if is_in_option_sequence and current_option_dialogue_index + 1 < option_dialogue_sequence.size():
		current_option_dialogue_index += 1
		start_option_dialogue(option_dialogue_sequence[current_option_dialogue_index])
		return
	
	# إذا انتهت سلسلة نصوص الخيارات، عد للحوار الرئيسي
	if is_in_option_sequence:
		is_in_option_sequence = false
		option_dialogue_sequence.clear()
		current_option_dialogue_index = 0
		# الانتقال للحوار التالي في السلسلة الرئيسية
		if current_dialogue_index + 1 < dialogue_data.size():
			start_dialogue(current_dialogue_index + 1)
		else:
			emit_signal("dialogue_finished")
			queue_free()
		return
	
	if has_options:
		return  # لا ننتقل للحوار التالي إذا كانت هناك خيارات
		
	if current_dialogue_index + 1 < dialogue_data.size():
		start_dialogue(current_dialogue_index + 1)
	else:
		emit_signal("dialogue_finished")
		queue_free()

func select_option():
	"""تحديد الخيار الحالي"""
	if has_options and current_option_index < options.size():
		var selected_option = options[current_option_index]
		emit_signal("option_selected", current_option_index, selected_option)
		
		# التحقق من وجود نصوص مختلفة للخيارات في نفس الحوار
		if current_dialogue.has("option_dialogues") and current_dialogue.option_dialogues.size() > current_option_index:
			var option_dialogues = current_dialogue.option_dialogues[current_option_index]
			if option_dialogues is Array and option_dialogues.size() > 0:
				# بدء سلسلة النصوص الخاصة بالخيار المحدد
				start_option_dialogue_sequence(option_dialogues)
				return
		
		# التحقق من وجود next_dialogue في الخيار المحدد (الطريقة القديمة)
		if current_dialogue.has("option_actions") and current_dialogue.option_actions.size() > current_option_index:
			var action = current_dialogue.option_actions[current_option_index]
			if action.has("next_dialogue"):
				start_dialogue(action.next_dialogue)
				return
		
		# إذا لم يكن هناك إجراء محدد، انتقل للحوار التالي
		next_dialogue()

func check_and_emit_custom_signal():
	"""التحقق من وجود إشارة مخصصة وإطلاقها"""
	if not current_dialogue.has("custom_signal"):
		return
		
	var signal_info = current_dialogue.get("custom_signal")
	
	# إذا كان signal_info نص بسيط (اسم الإشارة فقط)
	if signal_info is String:
		var signal_name = str(signal_info)
		call_deferred("emit_custom_signal_deferred", signal_name, {})
	
	# إذا كان signal_info قاموس يحتوي على تفاصيل أكثر
	elif signal_info is Dictionary:
		var signal_name = signal_info.get("name", "")
		var signal_data = signal_info.get("data", {})
		
		if signal_name != "":
			call_deferred("emit_custom_signal_deferred", signal_name, signal_data)

func emit_custom_signal_deferred(signal_name: String, signal_data: Dictionary):
	"""إطلاق الإشارة المخصصة مع تأخير"""
	custom_signal_triggered.emit(signal_name, signal_data)

func draw_colored_text(text: String, pos: Vector2, color: Color):
	"""رسم نص ملون"""
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw():
	draw_rect(Rect2(0, 0, rect_width, rect_height), box_color)
	draw_rect(Rect2(border_width, border_width, rect_width - 2 * border_width, rect_height - 2 * border_width), Color.WHITE, false, border_width)

	var speaker_name = current_dialogue.get("name", "")
	var y_offset = padding
	if speaker_name != "":
		var name_pos = Vector2(text_rect.position.x, y_offset + name_font_size)
		draw_string(font, name_pos, speaker_name, HORIZONTAL_ALIGNMENT_LEFT, -1, name_font_size, Color.WHITE)
		y_offset += name_font_size + 10
	else:
		y_offset -= 10

	y_offset += font_size

	# رسم الأسطر المكتملة بالألوان الصحيحة
	for i in range(lines.size()):
		var line_pos = Vector2(text_rect.position.x, y_offset + i * (font_size + line_spacing))
		draw_colored_line(str(lines[i]), line_pos, i)
	
	# رسم السطر الحالي بالألوان الصحيحة
	if current_line.length() > 0:
		var current_line_pos = Vector2(text_rect.position.x, y_offset + lines.size() * (font_size + line_spacing))
		draw_colored_line(current_line, current_line_pos, lines.size())
	
	# رسم الخيارات إذا انتهت الكتابة وكانت موجودة
	if has_options and not is_typing:
		draw_horizontal_options()
	
	if image_textures.size() > 0:
		var tex = image_textures[current_image_index]
		var image_pos = Vector2()
		
		if image_side == 0:
			image_pos = Vector2(image_side_padding, rect_height - image_size.y - image_side_padding)
		else:
			image_pos = Vector2(rect_width - image_size.x - image_side_padding, rect_height - image_size.y - image_side_padding)
		draw_texture_rect(tex, Rect2(image_pos, image_size), false)

func draw_horizontal_options():
	"""رسم الخيارات أفقياً في موقع ثابت"""
	for i in range(options.size()):
		if i < option_positions.size():
			var option_text = str(options[i])
			var option_color = option_color_selected if i == current_option_index else option_color_normal
			var option_pos = option_positions[i]
			
			draw_string(font, option_pos, option_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, option_color)

func draw_colored_line(line_text: String, start_pos: Vector2, line_index: int):
	"""رسم سطر بالألوان الصحيحة لكل كلمة"""
	var words_in_line = line_text.split(" ")
	var x_offset = 0
	@warning_ignore("unused_variable")
	var word_index_in_line = 0
	
	# حساب فهرس الكلمة الإجمالي للسطر
	var global_word_index = 0
	for i in range(line_index):
		var prev_line_words = str(lines[i]).split(" ") if i < lines.size() else []
		global_word_index += prev_line_words.size()
	
	for word in words_in_line:
		if str(word).length() > 0:
			var word_color = text_color
			if global_word_index < word_colors.size():
				word_color = word_colors[global_word_index]
			
			var word_pos = Vector2(start_pos.x + x_offset, start_pos.y)
			draw_string(font, word_pos, str(word), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, word_color)
			
			# حساب عرض الكلمة والمسافة
			var word_width = font.get_string_size(str(word), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			var space_width = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			x_offset += word_width + space_width
			
			global_word_index += 1
		else:
			global_word_index += 1

func _input(event):
	if has_options and not is_typing:
		# التحكم في الخيارات أفقياً
		if event.is_action_pressed("ui_left"):
			current_option_index = (current_option_index - 1) % options.size()
			if current_option_index < 0:
				current_option_index = options.size() - 1
			queue_redraw()
		elif event.is_action_pressed("ui_right"):
			current_option_index = (current_option_index + 1) % options.size()
			queue_redraw()
		elif event.is_action_pressed(next_key) or event.is_action_pressed("ui_accept"):
			select_option()
		return
	
	if event.is_action_pressed(next_key):
		if not is_typing and not auto_advance and not has_options:
			next_dialogue()
	if event.is_action_pressed(skip_key):
		if is_typing:
			skip_typing()
	elif event.is_action_pressed("ui_cancel"):
		restart_dialogue()

func skip_typing():
	"""تخطي الكتابة وإظهار النص كاملاً مع \n"""
	is_typing = false
	is_paused = false
	typing_timer.stop()
	pause_timer.stop()
	lines.clear()
	current_line = ""
	
	var temp_line = ""
	var word_index = 0
	
	for word in words:
		var word_str = str(word)
		
		# إذا كانت الكلمة \n، أضف السطر الحالي للأسطر وابدأ سطراً جديداً
		if word_str == "\n":
			if temp_line.length() > 0:
				lines.append(temp_line)
			temp_line = ""
			word_index += 1
			continue
		
		var test_line = temp_line
		if temp_line.length() > 0:
			test_line += " "
		test_line += word_str
		
		var text_size = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if text_size.x > text_rect.size.x and temp_line.length() > 0:
			lines.append(temp_line)
			temp_line = word_str
		else:
			temp_line = test_line
		
		word_index += 1
	
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

# دوال مساعدة للإشارات المخصصة
func emit_custom_signal_manually(signal_name: String, signal_data: Dictionary = {}):
	"""إطلاق إشارة مخصصة يدوياً من الكود"""
	custom_signal_triggered.emit(signal_name, signal_data)

func connect_to_custom_signal(target_object: Object, target_method: String):
	"""ربط الإشارات المخصصة بكائن معين"""
	var callable = Callable(target_object, target_method)
	if not custom_signal_triggered.is_connected(callable):
		custom_signal_triggered.connect(callable)
