extends CanvasLayer

signal dialogue_custom_signal(signal_name: String, signal_data: Dictionary)

func set_dialogue_json(json_path: String):
	$oTextSystem.load_dialogue_json(json_path)
