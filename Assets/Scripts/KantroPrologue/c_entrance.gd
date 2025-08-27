extends Room

@onready var gateOpener = $gateOpenAnimation
@onready var title = $DateTitle/Control

func _ready() -> void:
	SaveLoader.party = ["kantro"]
	$blackScreen.visible = true
	SaveLoader.emit_signal("pause")
	$Intro.play("Intro")
	await $Intro.animation_finished
	await dialogue("KantroIntro1")
	$Intro.play("Intro_2")
	await $Intro.animation_finished
	$AudioStreamPlayer.play()
	await dialogue("KantroIntro2")
	SaveLoader.emit_signal("resume")

func _on_intract_reciever_action():
	SaveLoader.emit_signal("pause")
	gateOpener.play("gate_open")
	await gateOpener.animation_finished
	SaveLoader.emit_signal("resume")
