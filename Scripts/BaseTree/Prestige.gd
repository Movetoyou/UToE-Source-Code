extends Sprite2D

@onready var Data: Process = $/root/TestScene

@export var Name := ""
@export var Source := ""
@export var Target := ""
@export var Cost := 0.0
@export_multiline var Text := ""

var Labels := {}
var ResourceType = ["Seed", "Root", "Wood"]

func CreateLabel(LabelName: String, LabelPOS: Vector2, LabelSize: Vector2):
	var newLabel = Label.new()
	newLabel.position = LabelPOS
	newLabel.text = LabelName
	newLabel.size = LabelSize
	newLabel.add_theme_font_size_override("font_size", 24)
	newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	newLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(newLabel)
	return newLabel

func CreateButton():
	var newButton = Button.new()
	newButton.size = Vector2(512, 256)
	newButton.position = Vector2(-256, -128)
	newButton.text = Text
	newButton.flat = true
	newButton.add_theme_font_size_override("font_size", 28)
	newButton.focus_mode = Control.FOCUS_NONE
	newButton.mouse_filter = Control.MOUSE_FILTER_STOP
	newButton.pressed.connect(_on_pressed)
	Labels["Button"] = newButton
	add_child(newButton)
	Labels["Name"] = CreateLabel(Name, Vector2(-242, -114), Vector2(484, 46))
	Labels["Cost"] = CreateLabel("", Vector2(14, 68), Vector2(228, 46))
	Labels["Reward"] = CreateLabel("", Vector2(-242, 68), Vector2(228, 46))

func _ready():
	CreateButton()
	Update()

func _process(_delta):
	Update()

func _on_pressed():
	if Data.get(Source) >= Cost:
		var Reward = int(float(Data.get(Source)) / Cost)
		Data.set(Target, Data.get(Target) + Reward)
		var ResetRes := []
		if Target == "Root":
			ResetRes = ["Seed"]
		elif Target == "Wood":
			ResetRes = ["Seed", "Root"]
		for res in ResetRes:
			Data.set(res, 0.0)
			Data.set("Base" + res, 0.0)
			Data.set("BoostCap" + res, 2.5)
			Data.set("Time" + res, 1.0)
			Data.set("Multi" + res, 1.0)
			Data.Boost[res] = 0.0
		ResetButton(Target)
		Data.UpdateUI()
		Update()

func ResetButton(TargetRes: String):
	var ResetGroup := []
	if TargetRes == "Root":
		ResetGroup = ["Seed"]
	elif TargetRes == "Wood":
		ResetGroup = ["Seed", "Root"]
	for Res in ResetGroup:
		for Upg in get_tree().get_nodes_in_group(Res):
			Upg.CurLevel = 0
			Upg.Cost = Upg.StartCost
			if Upg.Labels.has("Button"):
				Upg.Labels["Button"].disabled = false
			Upg.UpdateButtonText()
			for Synergy in get_tree().get_nodes_in_group("Synergy"):
				Synergy.queue_free()
	for Upg in get_tree().get_nodes_in_group("ButtonUpgrade"):
		Upg.UnlockButtonFunction()
		if Upg.UnlockToggle:
			Upg.UnlockFunc()

func Update():
	var Reward = int(float(Data.get(Source)) / Cost)
	Labels["Reward"].text = "Get %s %s" % [Num.Format(Reward), Target]
	if Reward > 1:
		Labels["Cost"].text = "Cost: %s %s" % [Num.Format(Cost * Reward), Source]
	else:
		Labels["Cost"].text = "Cost: %s %s" % [Num.Format(Cost), Source]
