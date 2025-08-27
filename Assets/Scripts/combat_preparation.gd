extends Node2D

func _process(delta: float) -> void:
	if Global.current_options != "":
		return
	
	var target_name: String = str(Global.combat_phase).strip_edges()
	if target_name.is_empty():
		return
	
	var target_node := get_tree().get_current_scene().find_child(target_name, true, false)
	if not target_node:
		return
	
	if target_node.has_method("_start"):
		target_node._start()
		
		if %CombatAnim.has_method("_start"):
			%CombatAnim._start([
				[%CombatAnim.omyx, Vector2(-24, 48)],
				[%CombatAnim.yamex, Vector2(-24, 71)],
				[%CombatAnim.enemy, Vector2(226, 61)]
			])
		
		set_process(false)
