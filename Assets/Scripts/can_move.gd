extends Node2D

func _process(delta: float) -> void:
	if Global.can_move:
		if not get_parent().has_node("o_following"):
			var follow = preload("res://Assets/Scenes/o_following.tscn").instantiate()
			follow.name = "o_following"
			get_parent().add_child(follow)
	else:
		if get_parent().has_node("o_following"):
			get_parent().get_node("o_following").queue_free()
