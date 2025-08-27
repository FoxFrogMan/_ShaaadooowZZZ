extends CharacterBody2D

enum characters { omyx, yamex, kantro }

@export var character : characters
@export var Active := true
@export var direction := "Down"

var in_tween = false
var birdcatching = false
var birdTimer = 0.0
var chosenBird = 0

const speed := 250


@onready var animation = $AnimatedSprite2D
@onready var trigger = $lookAnchor/CollisionShape2D
@onready var walkSfx = $AudioStreamPlayer
@onready var cat: Node2D = %Cat
var cat_busy := false
var cat_tween: Tween = null




func _ready():
	character = characters.yamex
	var spritePath = "res://Assets/tress/AnimatedSprite/Characters/" + str(characters.keys()[character]) + ".tres"
	if FileAccess.file_exists(spritePath):
		animation.sprite_frames = load(spritePath)
	else:
		Active = false
		print("ERROR!!!! NO SPRITE FRAMES FILE DOESNT EXIST FOR CHARACTER")
		await get_tree().create_timer(2).timeout
		get_tree().quit()
	SaveLoader.connect("pause", pause)
	SaveLoader.connect("resume", resume)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("confirm"):
		Global.o_quest._NewQuest("Find the the Sawing saword")
	if in_tween:
		if not $CatPos.top_level:
			$CatPos.top_level = true
			$CatPos.global_position = $CatPos.global_position
	else:
		if $CatPos.top_level:
			$CatPos.top_level = false
	
	trigger.disabled = true
	if not Active:
		return
	
	if not Global.can_move:
		animation.play("Idle" + direction)
		walkSfx.stop()
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		trigger.disabled = false
	moveLogic(delta)


func moveLogic(delta):
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input_vector != Vector2.ZERO:
		if cat_busy and cat.position != $CatPos.global_position:
			move_cat_back()

		if birdcatching:
			SaveLoader.emit_signal("stopBird")
		birdcatching = false
		birdTimer = 0.0
		walkSfx.pitch_scale = randf_range(0.7, 1.1)
		if not walkSfx.playing:
			walkSfx.play()
		velocity = input_vector * speed
		if abs(input_vector.x) > abs(input_vector.y):
			direction = "Right" if input_vector.x >= 0 else "Left"
		else:
			direction = "Down" if input_vector.y >= 0 else "Up"
		animation.play("Move" + direction)
		if Input.is_action_pressed("Sprint"):
			animation.speed_scale = 2.0
			walkSfx.pitch_scale *= 2
			velocity *= 2
		else:
			animation.speed_scale = 1.0
		move_and_slide()
	else:
		walkSfx.stop()
		if not birdcatching:
			animation.play("Idle" + direction)
			birdTimer += delta
			if birdTimer >= 2:
				birdcatching = true
				if character != characters.kantro:
					animation.play("bird")
				if not cat_busy:
					move_cat_to_player()
		elif birdcatching and birdTimer < 4:
			birdTimer += delta
		elif birdcatching and birdTimer >= 4:
			var birds = $birdwatcharea.get_overlapping_bodies()
			var chosenDistance = 212
			for i in birds:
				if self.position.distance_to(i.position) < chosenDistance:
					chosenBird = i
					chosenDistance = self.position.distance_to(i.position)
			if typeof(chosenBird) != 2:
				chosenBird.call("birbMode", Vector2(position.x + 15, position.y - 26))
			else:
				animation.play("Idle" + direction)

func move_cat_to_player():
	if cat_busy:
		return
	cat_busy = true
	if cat_tween and cat_tween.is_running():
		cat_tween.kill()
	var anim_node = cat.get_node_or_null("Anim")
	if anim_node:
		if anim_node is AnimationPlayer:
			anim_node.play("walk")
		elif anim_node is AnimatedSprite2D:
			anim_node.play("walk")
	cat.global_position = $CatPos.global_position
	cat_tween = create_tween()
	cat_tween.tween_property(cat, "global_position", $CatPos2.global_position, 3.0)
	await cat_tween.finished
	if anim_node:
		if anim_node is AnimationPlayer:
			anim_node.play("set_down")
			await anim_node.animation_finished
			anim_node.play("idle_down")
		elif anim_node is AnimatedSprite2D:
			anim_node.play("set_down")
			await anim_node.animation_finished
			anim_node.play("idle_down")

func move_cat_back():
	if not cat_busy:
		return
	if cat_tween and cat_tween.is_running():
		cat_tween.kill()
	var anim_node = cat.get_node_or_null("Anim")
	if anim_node:
		if anim_node is AnimationPlayer:
			anim_node.play("walk")
		elif anim_node is AnimatedSprite2D:
			anim_node.play("walk")
	cat_tween = create_tween()
	cat_tween.tween_property(cat, "global_position", $CatPos.global_position, 2.0)
	in_tween = true
	await cat_tween.finished
	in_tween = false
	if anim_node:
		if anim_node is AnimationPlayer:
			anim_node.play("idle_down")
		elif anim_node is AnimatedSprite2D:
			anim_node.play("idle_down")
	cat_busy = false

func pause():
	animation.play("Idle" + direction)
	Active = false

func resume():
	await get_tree().create_timer(0.5).timeout
	Active = true
