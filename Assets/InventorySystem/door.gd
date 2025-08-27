extends Area2D

enum TYPES{MOVE,CUTSCENE}
signal done

@export var type = TYPES.MOVE
@export var target_scene : String = ""
@export var resumeMusic := false
@export var targetMusicPlayer : AudioStreamPlayer = null

@onready var anim_player = $AnimationPlayer

func _on_body_entered(_body: Node2D) -> void:
	match type :
		TYPES.MOVE :
			switch_scene()
		TYPES.CUTSCENE :
			emit_signal("done")
	
func switch_scene():
	SaveLoader.emit_signal("pause")
	anim_player.play("fadeIn")
	await anim_player.animation_finished
	if resumeMusic and (targetMusicPlayer != null):
		SaveLoader.musicSave1 = targetMusicPlayer.get_playback_position()
	get_tree().change_scene_to_file(target_scene)
