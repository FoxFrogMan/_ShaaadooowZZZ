extends CanvasLayer

@onready var animPlayer = $HUDanim
@onready var animPlayer2 = $UIanim
@onready var timer = $InputCooldown
@onready var partyMembers = $HUD/grid
@onready var HUDflash = $HUD/ColorRect
@onready var CC = $INFO
@onready var previewSprite = $INFO/C/RatioDivider/CenterContainer/CharPreview/Sprite2D
@onready var infoCont = %infoCont
@onready var PageIcons = $INV/C/RatioDivider/VSplitContainer/GridContainer/HBoxContainer.get_children(false)
@onready var optionLister = $INV/C/RatioDivider/VSplitContainer/VBoxContainer
@onready var leftArrow = $INV/C/RatioDivider/VSplitContainer/GridContainer/Label
@onready var rightArrow = $INV/C/RatioDivider/VSplitContainer/GridContainer/Label2
@onready var itemInfoPanel = $INV/C/RatioDivider/MarginContainer/VBoxContainer
@onready var sfx = $sfx

const spriteList={
	"kantro":["res://Assets/Sprites/Kantro/Kantro red all.png",4],
	"omyx":["res://Assets/Sprites/Characters/Omyx .png",0],
	"yamex":["res://Assets/Sprites/Characters/Yamex.png",0]
}

enum{ON,OFF,NO}

const pageList = ["items","charms","quests","key","people"]
var inventory := false
var state = OFF:
	set(value):
		state = value
		#print(value)
var selected : String #the name of the selected item

var itemIndex := 0:
	set(value):
		var list = optionLister.get_children(false)
		for i in list:
			if list.find(i) == value:
				i.set("selected",true)
			else:
				i.set("selected",false)
		itemIndex = value
		if pageList[pageIndex] == "items":
			itemInfo(itemIndex)
		elif pageList[pageIndex] == "charms":
			charmInfo(itemIndex)
		elif pageList[pageIndex] == "quests":
			questInfo(itemIndex)
		elif pageList[pageIndex] == "people":
			peopleInfo(itemIndex)
var maxIndex := 1

var pageIndex := 0:
	set(value):
		if value < -4 or value > 4:
			pageIndex = 0
		else :
			pageIndex = value
		var nextIndex = pageIndex + 1
		if value == 4:
			nextIndex = 0
		var iconList = [pageList[pageIndex-1],pageList[pageIndex],pageList[nextIndex]]
		for i in PageIcons:
			var n = PageIcons.find(i)
			i.set("texture",load("res://Assets/InventorySystem/InvIcons/"+iconList[n]+" icon.png"))
		itemIndex = 0
		InvPageLogic()

var memberIndex := 0:
	set(value):
		memberIndex = clamp(value,0,len(SaveLoader.party))
		for i in len(SaveLoader.party)+1 :
			var select = partyMembers.get_child(i).find_child("selector")
			if i != memberIndex :
				select.visible = false
			else :
				select.visible = true
				CharInfo(clamp(i,0,len(SaveLoader.party)-1))

func _ready() -> void:
	SaveLoader.UIfocus.connect(turnNo)
	SaveLoader.UIhold.connect(turnOn)

func PartyInfo():# the bottom hud
	for i in partyMembers.get_children():
		i.queue_free()
	var n = 0
	for i in SaveLoader.party :
		if n > 3 :
			break
		var x = load("res://Assets/InventorySystem/member_card.tscn").instantiate()
		if n == 0 :
			x.get_child(-2).visible = true
			x.get_child(-1).visible = true
		if x == null :
			break
		x.visible = true
		x.get_child(0).texture = load("res://Assets/InventorySystem/PartyIcons/"+str(SaveLoader.player_stats[str(i)]["name"])+"Icon.png")
		x.get_child(1).find_child("name").text = tr("NAME_" + str(SaveLoader.player_stats[str(i)]["name"]).to_upper())
		x.get_child(1).find_child("level").text = tr("LV") + " " + str(int(SaveLoader.player_stats[str(i)]["lv"]))
		x.get_child(1).find_child("health").max_value = SaveLoader.player_stats[str(i)]["maxhp"]
		x.get_child(1).find_child("health").value = SaveLoader.player_stats[str(i)]["hp"]
		partyMembers.add_child(x,true)
		n += 1
	var b = load("res://Assets/InventorySystem/inventoryButton.tscn").instantiate()
	partyMembers.add_child(b)
	memberIndex = 0
	CharInfo()

func CharInfo(n := 0):
	var skills = infoCont.find_child("skills").get_children(false)
	previewSprite.texture = load(spriteList[SaveLoader.party[n]][0])
	previewSprite.frame = spriteList[SaveLoader.party[n]][1]
	var _dict = SaveLoader.player_stats[SaveLoader.party[clamp(n,0,len(SaveLoader.party)-1)]]
	var _info = infoCont.find_child("info")
	var _stats = infoCont.find_child("stats")
	var _ability = infoCont.find_child("ability")
	_info.find_child("name").text = "NAME_" + str(_dict["name"]).to_upper()
	_info.find_child("lv").text = tr("LV") + " " + str(int(_dict["lv"]))
	infoCont.find_child("desc").text = "DESC_" + str(_dict["name"]).to_upper()
	_stats.find_child("XHP").text = tr("HP") + " " + str(int(_dict["maxhp"]))
	_stats.find_child("ATK").text = tr("ATK") + " " + str(int(_dict["atk"]))
	_stats.find_child("DEF").text = tr("DEF") + " " + str(int(_dict["def"]))
	_ability.get_child(0).text = tr("Ability") + " : " + "[color=" + str(_dict["color"]) + "]" +str(_dict["ability"]) + "[/color]"
	if len(_dict["skills"]) < 1:
		for i in skills:
			i.text = ""
	else:
		for i in _dict["skills"]:
			var l = _dict["skills"].find(i)
			skills[l].text = i

func _input(event):# detects menu inputs like opening and closing
	if event.is_action_pressed("HUD") :
		toggleLogic()
		return
	if state != ON:
		return
	if event.is_action_pressed("confirm") and memberIndex != len(SaveLoader.party) and not inventory:
		state = NO
		var leader = SaveLoader.party[memberIndex]
		SaveLoader.party.pop_at(memberIndex)
		SaveLoader.party.insert(0,leader)
		sfx.stream = load("res://Assets/Sound/for yamen select.mp3")
		sfx.pitch_scale = randf_range(0.85,1.2)
		HUDflash.color = Color.WHITE
		sfx.play()
		PartyInfo()
		await get_tree().create_tween().tween_property(HUDflash,"color",Color(Color.WHITE,0),0.4).finished
		state = ON
	elif event.is_action_pressed("confirm") and memberIndex == len(SaveLoader.party) and not inventory:
		state = NO
		inventory = true
		pageIndex = 0
		animPlayer2.play("infoOutro")
		await animPlayer2.animation_finished
		animPlayer2.play("invIntro")
		await animPlayer2.animation_finished
		state = ON
	if Input.is_action_just_pressed("Sprint") and inventory and state == ON:
		state = NO
		inventory = false
		pageIndex = 0
		memberIndex = 0
		animPlayer2.play("invOutro")
		await animPlayer2.animation_finished
		animPlayer2.play("infoIntro")
		await animPlayer2.animation_finished
		state = ON
	if Input.is_action_just_pressed("right"):
		if inventory :
			pageIndex += 1
			rightArrow.modulate = Color.WEB_GRAY
			var t = get_tree().create_timer(0.2)
			await t.timeout
			rightArrow.modulate = Color.WHITE
		else:
			memberIndex += 1
	if Input.is_action_just_pressed("left"):
		if inventory:
			pageIndex -= 1
			leftArrow.modulate = Color.WEB_GRAY
			var t = get_tree().create_timer(0.2)
			await t.timeout
			leftArrow.modulate = Color.WHITE
		else:
			memberIndex -= 1
	if Input.is_action_just_pressed("up"):
		itemIndex = clamp(itemIndex-1,0,maxIndex)
	elif Input.is_action_just_pressed("down"):
		itemIndex = clamp(itemIndex+1,0,maxIndex)

func toggleLogic():# logic for in and out animation
	match state :
		ON:
			SaveLoader.emit_signal("resume")
			state = NO
			animPlayer.play("selectOutro")
			if inventory :
				animPlayer2.play("invOutro")
			else :
				animPlayer2.play("infoOutro")
				await animPlayer2.animation_finished
			timer.start()
			await timer.timeout
			state = OFF
		OFF:
			SaveLoader.emit_signal("pause")
			PartyInfo()
			state = NO
			inventory = false
			rightArrow.modulate = Color.WHITE
			leftArrow.modulate = Color.WHITE
			animPlayer.play("selectIntro")
			#it should always start with the info menu
			animPlayer2.play("infoIntro")
			await animPlayer2.animation_finished
			timer.start()
			await timer.timeout
			state = ON
		NO:
			pass

func itemInfo(index := 0): #the side menu showing item info
	if len(SaveLoader.player_stats["items"]) < 1:
		return
	var item = SaveLoader.player_stats["items"][index]
	var file = FileAccess.open("res://items.json",FileAccess.READ)
	assert(FileAccess.file_exists("res://items.json"),"items file doesnt exist")
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.flush()
	var data = json.data[item]
	itemInfoPanel.get_child(0).set("texture",load(data["img"]))
	itemInfoPanel.get_child(1).set("text",item)
	var statsText := "" 
	for i in data["stats"]:
		var color
		var x = "+"
		if data[i] < 0:
			x = ""
		match i:
			"hp":
				color = "#00ff00"
			"def":
				color = "#0000ff"
			"atk":
				color = "ff0000"
		statsText += "[color="+color+"] "+x+str(int(data[i]))+" "+str(i)
	itemInfoPanel.get_child(2).set("text",statsText)
	itemInfoPanel.get_child(3).set("text",data["desc"])

func charmInfo(index := 0):
	if len(SaveLoader.player_stats["charms"]) < 1:
		return
	var charm = SaveLoader.player_stats["charms"][index]
	var file = FileAccess.open("res://charms.json",FileAccess.READ_WRITE)
	assert(FileAccess.file_exists("res://charms.json"),"items file doesnt exist")
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.flush()
	var data = json.data[charm]
	itemInfoPanel.get_child(0).set("texture",load(data["img"]))
	itemInfoPanel.get_child(1).set("text",charm)
	var statsText := "" 
	for i in data["stats"]:
		var color
		var x = "+"
		if data[i] < 0:
			x = ""
		match i:
			"hp":
				color = "#00ff00"
			"def":
				color = "#0000ff"
			"atk":
				color = "ff0000"
		statsText += "[color="+color+"] "+x+str(int(data[i]))+" "+str(i)
	itemInfoPanel.get_child(2).set("text",statsText)
	itemInfoPanel.get_child(3).set("text",data["desc"])

func questInfo(index := 0):
	if len(SaveLoader.player_stats["quests"]) < 1:
		return
	var file = FileAccess.open("res://quests.json",FileAccess.READ)
	var json_object = JSON.new()
	json_object.parse(file.get_as_text())
	var quest = json_object.data[str(int(SaveLoader.player_stats["quests"][index]))]
	var img
	match int(quest["type"]):
		0:
			img = load("res://Assets/InventorySystem/red.png")
		1:
			img = load("res://Assets/InventorySystem/orange.png")
	itemInfoPanel.get_child(0).set("texture",img)
	itemInfoPanel.get_child(0).set("custom_minimum_size",Vector2(0,80))
	itemInfoPanel.get_child(1).add_theme_font_size_override("normal_font_size",15)
	itemInfoPanel.get_child(1).set("text",quest["name"])
	var rewardText := ""
	if quest["rewards"]["money"] != 0:
		rewardText += "[color=#00ff00]$"+str(int(quest["rewards"]["money"]))+"[/color]\t"
	if quest["rewards"]["xp"] != 0:
		rewardText += "[color=#ffff00]⁜"+str(int(quest["rewards"]["xp"]))+"[/color]"
	itemInfoPanel.get_child(2).set("text",rewardText)
	itemInfoPanel.get_child(3).set("text",quest["desc"])

func peopleInfo(index := 0):
	var file = FileAccess.open("res://people.json",FileAccess.READ)
	var json_object = JSON.new()
	json_object.parse(file.get_as_text())
	file.flush()
	var data = []
	for i in json_object.data:
		if i["unlocked"] == true:
			data.append(i)
	if len(data) < 1:
		return
	var person = data[index]
	itemInfoPanel.get_child(0).set("texture",load(person["img"]))
	itemInfoPanel.get_child(0).set("custom_minimum_size",Vector2(0,100))
	itemInfoPanel.get_child(1).set("text",person["name"])
#	itemInfoPanel.get_child(2).set("text","")
	itemInfoPanel.get_child(3).set("text",person["desc"])
	itemInfoPanel.get_child(3).add_theme_font_size_override("normal_font_size",10)

func keyInfo(index := 0):
	if not len(SaveLoader.player_stats["keyitems"]) >= 1:
		return
	var keyFile = FileAccess.open("res://key.json",FileAccess.READ)
	var json_object = JSON.new()
	json_object.parse(keyFile.get_as_text())
	var key = json_object.data[str(SaveLoader.player_stats["keyitems"][index])]
	itemInfoPanel.get_child(0).set("texture",load(key["img"]))
	itemInfoPanel.get_child(1).set("text",key["name"])
	itemInfoPanel.get_child(2).set("text","")
	itemInfoPanel.get_child(3).set("text",key["desc"])

func page(list:Array):
	maxIndex = len(list)-1
	for i in list:
		var x = option.new()
		if list.find(i) != 0:
			x.selected = false
		else:
			x.selected = true
		x.value = str(i)
		x.state = option.states.hold
		x.type = option.TYPE.values()[pageIndex]
		optionLister.add_child(x)
		if pageList[pageIndex] == "charms":
			var holder : String
			for h in SaveLoader.party:
				if i in SaveLoader.player_stats[h]["charms"]:
					holder = h
					x.index = SaveLoader.party.find(holder)
					x.reloadIcons()
					break

func InvPageLogic():
	for i in optionLister.get_children():
		i.queue_free()
	itemInfoPanel.get_child(0).set("texture",null)
	itemInfoPanel.get_child(0).set("custom_minimum_size",Vector2(0,120))
	itemInfoPanel.get_child(1).set("text","")
	itemInfoPanel.get_child(2).set("text","")
	itemInfoPanel.get_child(3).set("text","")
	itemInfoPanel.get_child(3).add_theme_font_size_override("normal_font_size",14)
	match pageList[pageIndex] :
		"items":
			page(SaveLoader.player_stats["items"])
			itemInfo()
		"charms":
			page(SaveLoader.player_stats["charms"])
			charmInfo()
		"quests":
			var list : Array
			var currentQuests = SaveLoader.player_stats["quests"]
			var file = FileAccess.open("res://quests.json",FileAccess.READ)
			var json = JSON.new()
			json.parse(file.get_as_text())
			var data = json.data
			for i in data.keys():
				if i in currentQuests:
					list.append(data[i]["name"])
			page(list)
			questInfo()
		"key":
			page(SaveLoader.player_stats["keyitems"])
			keyInfo()
			
		"people":
			var list = []
			var file = FileAccess.open("res://people.json",FileAccess.READ)
			var json_object = JSON.new()
			json_object.parse(file.get_as_text())
			file.flush()
			var data = []
			for i in json_object.data:
				if i["unlocked"] == true:
					data.append(i)
			if len(data) < 1:
				return
			for i in data:
				list.append(i["name"])
			page(list)
			peopleInfo()

func turnNo():
	state=NO
func turnOn():
	state=ON
