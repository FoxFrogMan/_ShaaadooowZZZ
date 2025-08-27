extends Node2D

var current_stage = false
@onready var battle_menu: CanvasLayer = %BattleMenu
@onready var box_info : Node2D = null

var target_pos = {
	"down": Vector2(-5.0, 22.745),
	"up": Vector2(-5.0, 0.0),
}

var target_hide = {
	"Omyx" : {"position" : Vector2(-19, -17), "scale" : Vector2(38, 17)},
	"Omyx_to" : {"position" : Vector2(-19, -12),"scale" : Vector2(38, 12)},
	"Yamex" : {"position" : Vector2(-19, -17), "scale" : Vector2(38, 17)},
	"Yamex_to" : {"position" : Vector2(-19, -12), "scale" : Vector2(38, 12)},
}


func _ready() -> void:
	battle_menu.offset = target_pos["down"]

func _process(delta: float) -> void:
	if current_stage != Global.can_select:
		current_stage = Global.can_select

		if !current_stage:
			box_info = get_node("%" + "o_" + Global.specific_character + "Info")
			var box_hide = box_info.get_node("Hide")
			var tween = create_tween()
			tween.tween_property(box_hide, "position", target_hide[Global.specific_character + "_to"]["position"], 0.5)
			tween.parallel().tween_property(box_hide, "size", target_hide[Global.specific_character + "_to"]["scale"], 0.5)
			battle_menu.offset = target_pos["up"]
			var tween_up = create_tween()
			tween_up.tween_property(battle_menu, "offset", target_pos["down"], 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		else:
			box_info = get_node("%" + "o_" + Global.specific_character + "Info")
			var box_hide = box_info.get_node("Hide")
			var tween = create_tween()
			tween.tween_property(box_hide, "position", target_hide[Global.specific_character]["position"], 0.5)
			tween.parallel().tween_property(box_hide, "size", target_hide[Global.specific_character]["scale"], 0.5)
			battle_menu.offset = target_pos["down"]
			var tween_down = create_tween()
			tween_down.tween_property(battle_menu, "offset", target_pos["up"], 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
