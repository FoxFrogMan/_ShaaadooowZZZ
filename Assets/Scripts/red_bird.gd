class_name bird
extends StaticBody2D

enum s{LOOP,BIRB,WAIT}
@onready var anim = $redBird
var n := 0
var target
var state := s.LOOP
var broken := false

@export var path : Array[Dictionary]= [
	{"xy":Vector2(383,371),"wait":1},
	{"xy":Vector2(513,345),"wait":1}
]

func birbMode(xy : Vector2):
	state = s.BIRB
	target = {"xy":xy,"wait":null}

func stopBirb():
	broken = true

func _ready() -> void:
	SaveLoader.stopBird.connect(stopBirb)
	position = Vector2(513,345)
	anim.play("idle")

func _physics_process(delta: float) -> void:
	match state:
		s.LOOP:
			broken = false
			target = path[n]
			if position.distance_to(target["xy"]) >= 3:
				position = position.lerp(target["xy"],delta)
				if target["xy"].x > position.x:
					anim.flip_h = true
				else:
					anim.flip_h = false
				anim.play("fly")
			else:
				anim.play("idle")
				state = s.WAIT
				await get_tree().create_timer(target["wait"]).timeout
				n += 1
				if n == len(path):
					n=0
				state = s.LOOP
		s.BIRB:
			if broken:
				state = s.LOOP
			if position.distance_to(target["xy"]) >= 1:
				position = position.lerp(target["xy"],delta)
				if target["xy"].x > position.x:
					anim.flip_h = true
				else:
					anim.flip_h = false
				anim.play("fly")
			else:
				anim.play("idle")

		s.WAIT:
			pass
