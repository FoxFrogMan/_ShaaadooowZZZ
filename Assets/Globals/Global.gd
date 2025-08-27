extends Node

var current_options = "Fight"
var battle_characters = ["Omyx", "Yamex"]
var specific_character = "Omyx"
var combat_phase = "FirstFight"
var can_select = true
var strike_force = 0.0
var damage_value = {
	"Omyx" : 20,
	"Yamex" : 10,
}
var selected_item = ""
var can_select_item = false

var saves = []
var can_move: bool = true

@onready var o_quest = null
@onready var o_fade = null
