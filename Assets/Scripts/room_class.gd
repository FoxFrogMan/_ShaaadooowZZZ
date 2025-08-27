@icon("res://Assets/InventorySystem/charms icon.png")
class_name Room
extends Node2D

@export var fadeIntro : bool = true

var black : ColorRect = ColorRect.new()
var canvas : CanvasLayer = CanvasLayer.new()

func addQuest(code:int) -> void:
	SaveLoader.player_stats["quests"].append(str(code))
func addPerson(n:String) -> void:
	var file = FileAccess.open("res://people.json",FileAccess.READ_WRITE)
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.flush()
	var data = json.data
	for i in data:
		if i["name"] == n:
			i["unlocked"] = true
			break
	file = FileAccess.open("res://people.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

# creates a black canvas item and stores it
# "fadeIntro" decides wether the room starts with a fadeOut from black
func initiateBlackCanvas():
	self.add_child(canvas)
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT,true)
	canvas.add_child(black)
	if fadeIntro :
		black.modulate = Color.WHITE
		var tween = get_tree().create_tween()
		tween.tween_property(black,"modulate",Color(Color.WHITE,0),0.6)
		await tween.finished
		tween.kill()
	elif not fadeIntro :
		black.modulate = Color(Color.WHITE,0)

# function used for fading in incase it wasnt for switching rooms
func fade(seconds = 0.6,toBlack=true):
	var tween = get_tree().create_tween()
	if toBlack:
		tween.tween_property(black,"modulate",Color.WHITE,seconds)
	else:
		tween.tween_property(black,"modulate:a",0,seconds)
	await tween.finished
	tween.kill()

# all the steps to initiation a dialogue in one function, give the file name as (n)
func dialogue(n, up:=false) :
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	if up:
		d.offset.y = -340
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/" + str(n) + ".json")
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()

#ready function for all rooms
func _ready() -> void:
	y_sort_enabled = true
	await initiateBlackCanvas()
