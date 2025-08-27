extends Node2D

@onready var main_animation_player: AnimationPlayer = $main_animation_player

func _ready() -> void:
	animation_controller()
	pass

func animation_controller():
	main_animation_player.play("talk_with_villagelady")
	await get_tree().create_timer(5.6).timeout
	await _run_dialogue("villagelady_talks")
	
	pass
func _run_dialogue(file):
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	d.offset.y = -30
	 
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/villagelady_talks.json")
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
