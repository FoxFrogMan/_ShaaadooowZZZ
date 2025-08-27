extends Node

class Quest:
	var id: int
	var title: String
	var completed: bool = false
	var trigger_node: Node2D
	var quest_manager: Node

	func _init(new_id: int, new_title: String, new_trigger: Node2D, manager: Node):
		id = new_id
		title = new_title
		trigger_node = new_trigger
		quest_manager = manager
		trigger_node.quest_ref = self

	func complete():
		completed = true
		quest_manager.complete_current_quest()


var quests: Array[Quest] = []
var current_quest_index: int = 0


func _ready():
	SaveLoader.party = ["omyx", "yamex"]

	#quests.append(Quest.new(0, "Find the sword and shield", $cutscene_find, self))
	quests.append(Quest.new(1, "Move", $move, self))

	_activate_current_quest()


func _activate_current_quest():
	if current_quest_index < quests.size():
		var current = quests[current_quest_index]
		if current.trigger_node and current.trigger_node.has_method("_start"):
			current.trigger_node.call("_start")


func complete_current_quest():
	if current_quest_index < quests.size():
		quests[current_quest_index].completed = true
		current_quest_index += 1
		if current_quest_index < quests.size():
			_activate_current_quest()
