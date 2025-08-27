extends Sprite2D

var targeted_skew = 13.0
var time = 0.0
var x = 0.0
var strength = 17.0
var target = null
var inside_bush = false

func _physics_process(delta):
	if round(x) == 0:
		time = Time.get_ticks_msec() / 1000.0
	
	skew = lerp(skew, sin(time) * deg_to_rad(targeted_skew) + x, 0.1)
	x = lerp(x, 0.0, 0.05)
	
	if inside_bush and target:
		if abs(target.velocity.x) > 0:
			x = sign(target.velocity.x) * deg_to_rad(strength)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pp"):
		target = body
		inside_bush = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("pp"):
		target = null
		inside_bush = false
