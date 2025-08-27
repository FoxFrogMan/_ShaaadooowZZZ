extends AnimationPlayer
@onready var main_animation_player: AnimationPlayer = $"."

func _ready() -> void:
	animation_controller()
	pass

func animation_controller():
	main_animation_player.play("find_a_sword_and_sield_cutscene")
	await get_tree().create_timer(2).timeout
	await _run_dialogue("find_a_sword_&_sield1.cutscene")
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://Assets/Rooms/AzwadVillage/village.tscn")
	pass

func _run_dialogue(file):
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	d.offset.y = -30
	 
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/find_a_sword_&_sield1.cutscene.json")
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
