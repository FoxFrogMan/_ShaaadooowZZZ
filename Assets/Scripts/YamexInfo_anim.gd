extends Control

@onready var box_info = %ItemInfo
var can_select = true

var target_pos = {
	"Up" : Vector2(167, 104),
	"Down" : Vector2(167, 175)
}

func _ready() -> void:
	box_info.position = target_pos["Down"]

func _process(delta: float) -> void:
	if can_select != Global.can_select:
		can_select = Global.can_select
	if Global.current_options == "Items":
		if !can_select:
			var tween_pos = create_tween()
			tween_pos.tween_property(box_info, "position", target_pos["Up"], 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			
	if can_select or Global.current_options == "":
		var tween_pos = create_tween()
		tween_pos.tween_property(box_info, "position", target_pos["Down"], 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			
			
			
			
			
	
	
	pass
