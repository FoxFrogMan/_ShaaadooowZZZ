extends Area2D

signal action
enum types{DIAL,ACT}

@export var IntractDia := ""
@export var triggerDialogue := false
@export var emitSignal := false
@export var one_shot := false
@onready var shape = $CollisionShape2D

func _on_area_entered(_area):
	SaveLoader.emit_signal("pause")
	if one_shot :
		shape.set_deferred("disabled",true)
	if triggerDialogue :
		var dialogue = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
		add_child(dialogue)
		dialogue.set_dialogue_json(IntractDia)
		await dialogue.get_node("oTextSystem").dialogue_finished
		remove_child(dialogue)
		SaveLoader.emit_signal("resume")
	if emitSignal :
		emit_signal("action")
