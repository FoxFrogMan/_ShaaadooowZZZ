extends Area2D





func _on_body_entered(body: Node2D) -> void:
	var dialogue = preload("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	add_child(dialogue)
	dialogue.set_dialogue_json("res://Assets/Strings/Testing.json")
	
	pass # Replace with function body.
