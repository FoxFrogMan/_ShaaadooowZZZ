extends Node2D

@export var move_duration: float = 1.0
@export var transition_duration: float = 0.6
@export var second_move_duration: float = 1.8

@export var omyx_target: Vector2 = Vector2(100, 177)
@export var enemy_target: Vector2 = Vector2(100, -55)
@export var omyx_second_target: Vector2 = Vector2(100, 105)
@export var enemy_second_target: Vector2 = Vector2(100, 35)

@onready var omyx: Node2D = %Omyx
@onready var yamex: Node2D = %Yamex
@onready var enemy: Node2D = %Enemy

func _start(movements: Array) -> void:
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	
	for movement in movements:
		var obj: Node2D = movement[0]
		var target_pos: Vector2 = movement[1]
		tween.parallel().tween_property(obj, "position", target_pos, move_duration)
	
	await tween.finished
	enemy.get_node("Sprite/Sprite").play("fight_idle")
	omyx.position = omyx_target
	enemy.position = enemy_target
	
	var second_tween = create_tween()
	second_tween.parallel().tween_property(omyx, "position", omyx_second_target, second_move_duration)
	second_tween.parallel().tween_property(enemy, "position", enemy_second_target, second_move_duration)
	
	await second_tween.finished
	
