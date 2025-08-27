extends Node2D

@onready var runner: AnimatedSprite2D = $"../NPC1"
var move_tween: Tween

var movement_sequence := [
	{"anim": "left", "target": Vector2(631, 101), "duration": 1.0},
	{"anim": "left", "target": Vector2(631, 158.388), "duration": 3.0},
]

func _ready() -> void:
	runner.position = movement_sequence[0]["target"] + Vector2(10, 0)
	perform_movements()
	await get_tree().create_timer(5.5).timeout
	$"../NPC4".play("default")
	

func perform_movements() -> void:
	for step in movement_sequence:
		runner.play(step["anim"])
		
		var t := create_tween()
		t.tween_property(runner, "position", step["target"], step["duration"])
		await t.finished
	
