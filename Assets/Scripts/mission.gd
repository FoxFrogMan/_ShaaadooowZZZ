extends CanvasLayer

@onready var quest_title: Label = $Label
@onready var quest_text: Label = $Label2

func _ready() -> void:
	Global.o_quest = self

func _NewQuest(quest_name : String, description: String) -> void:
	var title_instance: Label = quest_title.duplicate()
	var text_instance: Label = quest_text.duplicate()
	add_child(title_instance)
	add_child(text_instance)
	
	title_instance.text = quest_name
	title_instance.modulate.a = 0.0
	text_instance.visible_ratio = 0.0
	text_instance.text = description
	
	var fade_in_title = create_tween()
	fade_in_title.tween_property(title_instance, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(2.0).timeout

	var typing_effect = create_tween()
	typing_effect.tween_property(text_instance, "visible_ratio", 1.0, description.length() * 0.04)
	await typing_effect.finished
	await get_tree().create_timer(2.5).timeout

	var fade_out_all = create_tween()
	fade_out_all.tween_property(title_instance, "modulate:a", 0.0, 1.0)
	fade_out_all.parallel().tween_property(text_instance, "modulate:a", 0.0, 1.0)
	fade_out_all.tween_property(text_instance, "visible_ratio", 0.0, 0.0)

	await fade_out_all.finished
	title_instance.queue_free()
	text_instance.queue_free()
