extends Node2D

signal registered

@onready var damage_bar: NinePatchRect = %DamgeBar
@onready var bar := damage_bar.get_node("Bar")
@onready var bar2 := damage_bar.get_node("Mask/Bar2")

var speed: float = 60.0
var move_tween: Tween
var result: float = -1.0

var measuring := false
var bar_position_chosen := false
var bar2_started := false
var bar2_finished := false
var sequence_active := false


func _process(delta: float) -> void:
	if not sequence_active:
		return

	if bar2_started and not bar2_finished:
		bar2.position.x += delta * speed
		if bar2.position.x >= 55.0:
			bar2_finished = true
			emit_signal("registered")
			_end_damage_sequence()

	if Input.is_action_just_pressed("confirm") and bar2_started and not bar2_finished:
		bar2_finished = true
		measuring = true
		var dist = abs(bar.position.x - bar2.position.x)
		if dist <= 10.0:
			result = 1.0 - (dist / 10.0)
		else:
			result = 0.0
		Global.strike_force = snapped(result, 0.01)
		emit_signal("registered")
		_end_damage_sequence()


func _start_damage_sequence() -> void:
	if sequence_active:
		return
	sequence_active = true
	_reset_state()

	move_tween = create_tween()
	move_tween.tween_property(damage_bar, "position:y", 4.0, 0.5)
	move_tween.tween_callback(Callable(self, "_on_tween_finished"))


func _on_tween_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	bar2_started = true


func _end_damage_sequence() -> void:
	bar2_started = false
	measuring = false
	bar2_finished = false
	bar_position_chosen = false
	sequence_active = false

	move_tween = create_tween()
	move_tween.tween_property(damage_bar, "position:y", -14.0, 0.4)


func _reset_state() -> void:
	bar2.position.x = -5.0
	bar.position.x = randf_range(15.0, 55.25)
	result = -1.0
