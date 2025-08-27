extends Node2D

enum MovementMode {
	LOOP,
	PINGPONG, 
	ONCE
}

@export var path_points: Array[Vector2] = []
@export var movement_mode: MovementMode = MovementMode.PINGPONG
@export var base_speed: float = 100.0
@export var rotate_character: bool = false
@export var look_distance: float = 20.0
@export var speed_variation: bool = true
@export var min_speed: float = 60.0
@export var max_speed: float = 140.0
@export var pause_randomly: bool = true
@export var max_pause_duration: float = 3.0

@onready var animated_sprite: AnimatedSprite2D = $Sprite

var curve: Curve2D
var current_progress: float = 0.0
var direction_multiplier: int = 1
var is_paused: bool = false
var pause_timer: float = 0.0
var current_animation: String = "down"
var is_turning: bool = false
var turn_timer: float = 0.0
var target_animation: String = ""
var last_direction: Vector2 = Vector2.ZERO

func _ready():
	setup_path_curve()
	if curve and curve.get_point_count() > 0:
		global_position = curve.sample_baked(current_progress)

func _physics_process(delta):
	if not curve or curve.get_point_count() < 2:
		return
		
	if is_paused:
		pause_timer -= delta
		if pause_timer <= 0.0:
			is_paused = false
		else:
			update_animation(Vector2.ZERO)
			return
	
	if is_turning:
		turn_timer -= delta
		if turn_timer <= 0.0:
			is_turning = false
			current_animation = target_animation
			animated_sprite.play(current_animation)
		else:
			animated_sprite.play(current_animation)
			animated_sprite.frame = 0
			animated_sprite.pause()
			return
	
	var movement_speed = base_speed
	if speed_variation:
		movement_speed = randf_range(min_speed, max_speed)
	
	current_progress += delta * movement_speed * direction_multiplier
	var path_length = curve.get_baked_length()
	
	handle_path_boundaries(path_length)
	
	var target_position = curve.sample_baked(clamp(current_progress, 0.0, path_length), true)
	var movement_vector = target_position - global_position
	
	if rotate_character:
		var ahead_position = curve.sample_baked(clamp(current_progress + look_distance, 0.0, path_length), true)
		rotation = (ahead_position - target_position).angle()
	
	global_position = target_position
	update_animation(movement_vector)
	
	if pause_randomly and randf() < 0.3 * delta:
		is_paused = true
		pause_timer = randf_range(0.8, max_pause_duration)

func handle_path_boundaries(path_length: float):
	if current_progress > path_length:
		match movement_mode:
			MovementMode.LOOP:
				current_progress = 0.0
				trigger_direction_change()
			MovementMode.PINGPONG:
				current_progress = path_length
				direction_multiplier = -1
				trigger_direction_change()
			MovementMode.ONCE:
				current_progress = path_length
				set_physics_process(false)
	elif current_progress < 0.0:
		match movement_mode:
			MovementMode.PINGPONG:
				current_progress = 0.0
				direction_multiplier = 1
				trigger_direction_change()
			MovementMode.LOOP:
				current_progress = path_length + fposmod(current_progress, path_length)
				trigger_direction_change()
			MovementMode.ONCE:
				current_progress = 0.0
				set_physics_process(false)

func trigger_direction_change():
	is_paused = true
	pause_timer = randf_range(0.5, 1.2)

func setup_path_curve():
	curve = Curve2D.new()
	curve.clear_points()
	
	for point in path_points:
		curve.add_point(point)

func update_animation(movement_direction: Vector2):
	if not animated_sprite:
		return
		
	if movement_direction.length_squared() < 0.001:
		animated_sprite.play(current_animation)
		animated_sprite.frame = 0
		animated_sprite.pause()
		return
	
	var angle_degrees = rad_to_deg(movement_direction.angle())
	var new_animation = ""
	
	if angle_degrees > -45 and angle_degrees <= 45:
		new_animation = "right"
	elif angle_degrees > 45 and angle_degrees <= 135:
		new_animation = "down"
	elif angle_degrees < -45 and angle_degrees >= -135:
		new_animation = "up"
	else:
		new_animation = "left"
	
	if current_animation != new_animation:
		var direction_change = calculate_direction_change(last_direction, movement_direction)
		
		if direction_change > 90 and not is_turning:
			is_turning = true
			target_animation = new_animation
			turn_timer = randf_range(0.3, 0.8)
			animated_sprite.play(current_animation)
			animated_sprite.frame = 0
			animated_sprite.pause()
		elif not is_turning:
			current_animation = new_animation
			animated_sprite.play(new_animation)
	elif not animated_sprite.is_playing() and not is_turning:
		animated_sprite.play(current_animation)
	
	last_direction = movement_direction

func calculate_direction_change(old_dir: Vector2, new_dir: Vector2) -> float:
	if old_dir.length_squared() < 0.001:
		return 0.0
	
	var old_angle = old_dir.angle()
	var new_angle = new_dir.angle()
	var angle_diff = abs(new_angle - old_angle)
	
	if angle_diff > PI:
		angle_diff = 2 * PI - angle_diff
	
	return rad_to_deg(angle_diff)

func add_path_point(point: Vector2):
	path_points.append(point)
	setup_path_curve()

func clear_path():
	path_points.clear()
	setup_path_curve()

func set_path_points(points: Array[Vector2]):
	path_points = points
	setup_path_curve()

func start_movement():
	set_physics_process(true)

func stop_movement():
	set_physics_process(false)

func pause_movement(duration: float = -1):
	is_paused = true
	if duration > 0:
		pause_timer = duration

func resume_movement():
	is_paused = false
	pause_timer = 0.0
