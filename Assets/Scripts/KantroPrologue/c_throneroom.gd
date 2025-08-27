extends Room

func _ready() -> void:
	await initiateBlackCanvas()
	$king.frame = 5
	$AudioStreamPlayer.play(SaveLoader.musicSave1)
	$kantroKingTalk.play("intro")

func kingDia():
	await dialogue("prologueKing")
	$king.frame = 6
	await dialogue("prologueKing2")
	var resume = $AudioStreamPlayer.get_playback_position()
	$AudioStreamPlayer.stop()
	$kantroKingTalk.play("kingLaugh")
	await $kantroKingTalk.animation_finished
	$AudioStreamPlayer.play(resume)
	$king.frame = 5
	await dialogue("prologueKing3")
	$kantroKingTalk.play("kingWalk")
	await $kantroKingTalk.animation_finished
	await dialogue("prologueKing4")
	await fade(3)
	$AudioStreamPlayer.stop()
	var timer = get_tree().create_timer(2)
	await timer.timeout
	get_tree().change_scene_to_file("res://Assets/Rooms/farrm.tscn")
