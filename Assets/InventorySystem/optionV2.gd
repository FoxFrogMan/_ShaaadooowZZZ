class_name option extends GridContainer

var Text = RichTextLabel.new()
var IC #icon container for charms

enum TYPE{items,charms,quests,key,people}
enum states{hold,focus}

@export var type : TYPE = TYPE.items
@export var value := " ":
	set(v):
		value = v
		reloadText()
@export var selected : bool :
	set(value):
		selected = value
		reloadText()
@export var state : states = states.hold

@export var index := 0:
	set(value):
		index = clamp(value,0,len(SaveLoader.party)-1)

func reloadText():
	var prefix = "< > "
	if selected:
		prefix = "<!> "
	Text.text = prefix + value

func initIcon():
	IC = HBoxContainer.new()
	IC.alignment = BoxContainer.ALIGNMENT_END
	IC.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(IC)
	for i in SaveLoader.party:
		var icon = load("res://Assets/InventorySystem/itemIcons/"+str(i)+" icon.png")
		var x = TextureRect.new()
		x.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		x.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		x.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		x.texture = icon
		x.modulate = Color(Color.WHITE,0)
		IC.add_child(x)

func _ready() -> void:
	columns = 2
	Text.bbcode_enabled = true
	Text.fit_content = true
	Text.scroll_active = false
	Text.add_theme_font_size_override("normal_font_size",19)
	Text.add_theme_font_override("normal_font",load("res://Assets/font/undertale-deltarune-text-font-extended.otf"))
	Text.autowrap_mode = TextServer.AUTOWRAP_OFF
	add_child(Text)
	#-
	if type == TYPE.charms:
		initIcon()
	reloadText()

func _input(event: InputEvent) -> void:
	match type:
		TYPE.charms:
			charmInputs(event)

func charmInputs(event: InputEvent) -> void:
	if not selected:
		return
	if event.is_action_pressed("confirm") and selected:
		match state:
			states.focus:
				state = states.hold
				SaveLoader.emit_signal("UIhold")
				for holder in SaveLoader.party:
					if value in SaveLoader.player_stats[holder]["charms"]:
						SaveLoader.player_stats[holder]["charms"].erase(str(value))
				var holder = SaveLoader.party[index]
				SaveLoader.player_stats[holder]["charms"].append(str(value))
			states.hold:
				state = states.focus
				SaveLoader.emit_signal("UIfocus")
		reloadIcons()
		Text.modulate = Color.YELLOW
		create_tween().tween_property(Text,"modulate",Color.WHITE,0.5)
		var sfx = AudioStreamPlayer.new()
		sfx.stream = load("res://Assets/Sound/select 2.mp3")
		sfx.pitch_scale = randf_range(0.9,1.1)
		add_child(sfx)
		sfx.play()
		await sfx.finished
		sfx.queue_free()
	elif event.is_action("Sprint") and selected:
		match state:
			states.focus:
				state = states.hold
				var holder = SaveLoader.party[index]
				if value in SaveLoader.player_stats[holder]["charms"]:
					SaveLoader.player_stats[holder]["charms"].erase(str(value))
				reloadIcons(false)
				await get_tree().create_timer(0.1).timeout
				SaveLoader.emit_signal("UIhold")
				
	if state != states.focus:
		return
	if event.is_action_pressed("right"):
		index += 1
		reloadIcons()
	elif event.is_action_pressed("left"):
		index -= 1
		reloadIcons()

func reloadIcons(select:=true):
	for i in IC.get_children(false):
		if state == states.focus:
			i.set("modulate",Color(Color.WHITE,0.3))
		else:
			i.set("modulate",Color(Color.WHITE,0))
	if select:
		IC.get_child(index).set("modulate",Color.WHITE)
