extends Node2D

@onready var current_options: Label = %Label
@onready var combat_phase: Label = %Label2
@onready var character_selected: Label = %Label3
@onready var fight_pos = %EnemyMarker
@onready var can_select: Label = %Label6
@onready var damage_system: Node2D = %DamageSystem
@onready var strike_force: Label = %Label9
@onready var damage_text: Label = %DamageText
@onready var omyx_damage: Label = %Label7
@onready var yamex_damage: Label = %Label8
@onready var omyx_marker: Marker2D = %OmyxMarker
@onready var yamex_marker: Marker2D = %YamexMarker
@onready var options_battle: Control = %OptionsBattle
@onready var yamex_damage_system: Node2D = %YamexDamageSystem
@onready var selected_item: Label = %Label10
@onready var can_select_item: Label = %Label11

var character : Node2D = null
var roles = 0
var start_damge = false
var target_positions := {}
var select = false

func _ready() -> void:
	character = get_node("%" + Global.specific_character)
	target_positions = {
		"Omyx_fight": fight_pos.global_position,
		"Yamex_fight": fight_pos.global_position,
		"Omyx": omyx_marker.global_position,
		"Yamex": yamex_marker.global_position,
	}


func _process(delta: float) -> void:
	options_event()
	omyx_damage.text = "Omyx Damage : " + str(Global.damage_value["Omyx"])
	yamex_damage.text = "Yamex Damage : " + str(Global.damage_value["Yamex"])
	current_options.text = "Current Options : " + Global.current_options
	character_selected.text = "Specific Character : " + Global.specific_character
	can_select.text = "Can Select : " + str(Global.can_select)
	strike_force.text = "Strike force : " + str(Global.strike_force)
	selected_item.text = "selected item : " + str(Global.selected_item)
	can_select_item.text = "can select item : " + str(Global.can_select_item)



func options_event():
	match Global.current_options:
		"Fight" :
			if Input.is_action_just_pressed("confirm") and !start_damge:
				Global.can_select = false
				start_damge = true
				var anim_player = character.get_node("Anim")
				anim_player.stop()
				anim_player.current_animation = "fight"
				anim_player.seek(0.0, true)
				anim_player.playback_active = false 
				var tween_pos = create_tween()
				tween_pos.tween_property(character, "position", target_positions[Global.specific_character + "_fight"], 1)
				await tween_pos.finished
				if character.name == "Omyx":
					damage_system._start_damage_sequence()
					await damage_system.registered
				elif character.name == "Yamex":
					yamex_damage_system._start_damage_sequence()
					await yamex_damage_system.registered
				anim_player.play("fight")
				anim_player.playback_active = true 
				damage_text.text = str(int(Global.damage_value[character.name] * Global.strike_force))
				damage_text.get_node("Anim").play("damage")
				await get_tree().create_timer(0.5).timeout
				await get_tree().create_timer(0.5).timeout
				anim_player.play("idle")
				var tween_return = create_tween()
				tween_return.tween_property(character, "position", target_positions[Global.specific_character], 1)
				await tween_return.finished
				if roles + 1 < Global.battle_characters.size():
					roles += 1
					Global.strike_force = 0
					Global.can_select = true
					Global.specific_character = Global.battle_characters[roles]
					character = get_node("%" + Global.specific_character)
					start_damge = false
					options_battle.set_yallow(%Fight)
				else:
					Global.can_select = false
					Global.current_options = ""
		"Items":
			if Input.is_action_just_pressed("confirm") and !select:
				Global.can_select = false
				%ItemInfo.get_node("SelectItem").input_enabled = true
				select = true
				Global.can_select_item = true
				
				var selected = await %ItemInfo.get_node("SelectItem").wait_for_selection()
				
				if roles + 1 < Global.battle_characters.size():
					roles += 1
					Global.specific_character = Global.battle_characters[roles]
					character = get_node("%" + Global.specific_character)
					options_battle.set_yallow(%Fight)
					print("true")
					Global.can_select = true
				else:
					Global.can_select = false
					Global.current_options = ""
					Global.can_select_item = false
					select = true
				return
				Global.can_select_item = false
			if Input.is_action_just_pressed("confirm") and select and Global.can_select:
				select = false
