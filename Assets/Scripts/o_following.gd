extends Node2D



var move_speed := 100
var trail := []
var max_trail_length := 300
var last_trail_pos := Vector2.ZERO
var min_trail_spacing := 1.0

@export var follower_distance := 16
@export var follower2_distance := 32

var move = null
var follower = null

var changet = 1

func _physics_process(delta):
	if Input.is_action_pressed("skip"):
		move_speed = 150
	else:
		move_speed = 100
		
	move = get_parent().get_node("%" + SaveLoader.party[0])
	follower = get_parent().get_node("%" + SaveLoader.party[1])
	if get_parent().has_node("Omyx"):
		move = get_parent().get_node("Omyx")
	if move:
		_mover(delta)
		record_trail()
		move_follower(follower, follower_distance)

func _mover(delta):
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input_vector != Vector2.ZERO:
		move.velocity = input_vector * move_speed
		move.move_and_slide()
		update_animation(move, input_vector)
	else:
		update_animation(move, Vector2.ZERO)

func record_trail():
	if trail.size() == 0 or move.position.distance_to(last_trail_pos) >= min_trail_spacing:
		trail.append(move.position)
		last_trail_pos = move.position
	if trail.size() > max_trail_length:
		trail.pop_front()

func move_follower(follower: Node2D, distance: int):
	if trail.size() > distance:
		var target_pos: Vector2 = trail[trail.size() - distance - 1]
		var direction: Vector2 = (target_pos - follower.position).normalized()
		if follower.position.distance_to(target_pos) > 0.5:
			follower.position = follower.position.move_toward(target_pos, move_speed * get_physics_process_delta_time())
			update_animation(follower, direction)
		else:
			update_animation(follower, Vector2.ZERO)
	else:
		update_animation(follower, Vector2.ZERO)


func update_animation(character: Node2D, direction: Vector2):
	var anim_sprite := character.get_node("Sprite")

	if direction == Vector2.ZERO:
		anim_sprite.stop()
		anim_sprite.frame = 0
		return

	if abs(direction.x) > abs(direction.y):
		anim_sprite.play("right" if direction.x > 0 else "left")
	else:
		anim_sprite.play("down" if direction.y > 0 else "up")
