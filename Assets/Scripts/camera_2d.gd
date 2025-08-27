extends Camera2D

var shake_amount = 0

@onready var timer = $Timer

func _ready():
	TranslationServer.set_locale("en")
	pass

func _process(_delta):
	offset = Vector2(randf_range(-3, 3) * shake_amount, randf_range(-3, 3) * shake_amount)
	pass



func shake(time, amount):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()
pass



func _on_timer_timeout():
	set_process(false)
	offset = Vector2(0, 0)
	pass 
