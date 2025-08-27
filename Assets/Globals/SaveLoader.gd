extends Node

var player_stats
var json_path = "res://Save.json"
var party = []
enum saveFiles{STATS,PEOPLE}

@warning_ignore("unused_signal")
signal pause
@warning_ignore("unused_signal")
signal resume
@warning_ignore("unused_signal")
signal UIfocus
@warning_ignore("unused_signal")
signal UIhold
@warning_ignore("unused_signal")
signal stopBird

var musicSave1 : float

func _ready() :
	TranslationServer.set_locale("en")
	print(load_json_file())

func load_json_file():
	# Open the file for reading
	var file = FileAccess.open(json_path, FileAccess.READ_WRITE)
	# Check if the file exists
	assert(FileAccess.file_exists(json_path), "File path does not exist")

	# Read the content of the file as text
	var json = file.get_as_text()
	var json_object = JSON.new()
	# Parse the JSON text
	json_object.parse(json)
	file.flush()
	# Store the parsed data in the content dictionary
	player_stats = json_object.data
	
	return player_stats

func save(_file):
	pass
