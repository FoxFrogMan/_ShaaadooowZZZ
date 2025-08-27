extends Room

@onready var runner: AnimatedSprite2D = $Runing
@onready var announcement_camera = $Camera
@onready var people = [$arthur,$blacksmith,$Lair,$muddy,$n6,$samurai,$"blonde hair",$"black hair",$"shop man"]
var move_tween: Tween

var movement_sequence := [
	{"anim": "up", "target": Vector2(744,1488), "duration": 0.0},
	{"anim": "up", "target": Vector2(744,930), "duration": 7.0},
	{"anim": "left", "target": Vector2(456,930), "duration": 4.0},
	{"anim": "up", "target": Vector2(456,370), "duration": 6.0}
]

func _ready() -> void:
	$Camera.enabled = false
	$Camera.position = Vector2(454,150)
	$Camera.zoom = Vector2.ONE
	y_sort_enabled = true
	await initiateBlackCanvas()
	$AudioStreamPlayer.play(SaveLoader.musicSave1)
	SaveLoader.musicSave1 = 0.0
	runner.position = movement_sequence[0]["target"] #+ Vector2(10, 0)
	perform_movements()

func perform_movements() -> void:
	for step in movement_sequence:
		runner.play(step["anim"])
		
		var t := create_tween()
		t.tween_property(runner, "position", step["target"], step["duration"])
		await t.finished
	await fade()
	$Runing.queue_free()
	announcement_cutscene()

func announcement_cutscene():
	announcement_camera.enabled = true
	fade(0.6,false)
	$AudioStreamPlayer2.play()
	var t = get_tree().create_tween()
	t.tween_property($Camera,"position",Vector2($Camera.position.x,262),3)
	await t.finished
	await dialogue("villageIntro3")
	t = get_tree().create_tween()
	t.tween_property($Camera,"position",Vector2($Camera.position.x,370),3)
	$omyx.visible = true
	$yamex.visible = true
	$omyx.play("walkUp")
	$yamex.play("new_animation")
	await t.finished
	t = get_tree().create_tween()
	t.parallel().tween_property($Camera,"zoom",Vector2(1.5,1.5),6)
	t.parallel().tween_property($omyx,"position",Vector2($omyx.position.x,350),3)
	t.parallel().tween_property($yamex,"position",Vector2($yamex.position.x,350),3)
	await get_tree().create_timer(3).timeout
	$omyx.play("idle2")
	$yamex.play("idle2")
	$"blonde hair".play("idle2")
	await dialogue("villageIntro1")
	$yamex.play("idle")
	t = get_tree().create_tween()
	t.tween_property($Camera,"position",Vector2(522,370),3)
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/villageIntro2.json")
	await t.finished
	$omyx.play("idle")
	$omyx.position = Vector2($omyx.position.x,246)
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
	t = get_tree().create_tween()
	t.tween_property($Camera,"position",Vector2(454,370),2)
	await t.finished
	for i in 3:
		$OmyxLines.visible = true
		await get_tree().create_timer(0.5).timeout
		$OmyxLines.visible = false
		await get_tree().create_timer(0.5).timeout
	$yamex/Red.visible = true
	t = get_tree().create_tween()
	t.chain().tween_property($yamex,"position",Vector2($yamex.position.x,$yamex.position.y - 5),0.2)
	t.chain().tween_property($yamex,"position",Vector2($yamex.position.x,$yamex.position.y + 5),0.2)
	await t.finished
	$yamex/Red.visible = false
	t = get_tree().create_tween()
	t.parallel().tween_property($Camera,"position",Vector2(454,262),2)
	t.parallel().tween_property($Camera,"zoom",Vector2(0.75,0.75),2)
	await t.finished
	t = get_tree().create_tween()
	$yamex.play("new_animation")
	t.tween_property($yamex,"position",Vector2($yamex.position.x,246),2)
	d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/villageIntro4.json")
	for i in people:
		var twe = get_tree().create_tween()
		i.play("down")
		twe.tween_property(i,"position",Vector2(i.position.x,460),2)
		await get_tree().create_timer(2).timeout
		twe.kill()
		$yamex.play("idle")
		$AudioStreamPlayer2.volume_db -= 10
	$AudioStreamPlayer2.queue_free()
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
	addQuest(0)
	addQuest(1)
