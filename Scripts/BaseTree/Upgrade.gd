extends Sprite2D
class_name UpgradeData

#region Button Upgrade: Variables & Exports
@onready var Data: Process

@export_group("Upgrade: Main")
@export_subgroup("Text Data")
@export var Name := ""
@export var Number := ""
@export var Source := ""
@export var Target := ""
@export var UnlockBtn: Array[String] = []
@export_multiline var Text := ""
@export_subgroup("Value Data")
@export var IsExponent := false
@export var IsMulti := false
@export var Upgrade := 0.0
@export var Cost := 0.0
@export var CostExponent := 1.0
@export var MaxLevel := 1

@export_group("Upgrade: Types")
@export_subgroup("Timer Mechanic")
@export var TimerToggle := false
@export var TimerValue := 0.0
@export_subgroup("Bloom Mechanic")
@export var BloomToggle := false
@export var BloomInterval := 1
@export var BloomValue := 0.0
@export_subgroup("Boost Mechanic")
@export var BoostToggle := false
@export var BoostSource := ""
@export var BoostTarget := ""
@export var BoostValue := 0.0
@export_subgroup("Cost Mechanic")
@export var ReduceToggle := false
@export var ReduceTarget := ""
@export var ReduceValue := 0.0
@export_subgroup("Synergy Mechanic")
@export var SynergyToggle := false
@export var SynergyTargets := ["", ""]
@export var SynergyReward := [
	{"Type": "Multi", "Target": "", "IsExponent": false, "IsMulti": false, "Value": 1.0},
	{"Type": "Boost", "Target": "", "Value": 1.0},
	{"Type": "Reduce", "Target": "", "Value": 1.0},
	{"Type": "Timer", "Target": "", "Value": 1.0},
	{"Type": "BoostCap", "Target": "", "Value": 1.0}
	]
@export_multiline var SynergyRewardText := ""

@export_group("Upgrade: Extra")
@export_subgroup("BoostCap Increase")
@export var CapToggle := false
@export var CapValue := 0.0
@export_subgroup("Unlock Mechanic")
@export var UnlockToggle := false
@export var UnlockTargets: Array[String] = []
@export var UnlockValues: Array[int] = []

var CurLevel := 0
var Labels := {}
var StartCost := 0.0
var UnlockSource: Node = self
#endregion

#region Button Upgrade: Main Functions & Create Label, Button Functions
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
	Labels["Name"] = CreateLabel(Name, Vector2(-242, -114), Vector2(294, 46))
	Labels["Number"] = CreateLabel(Number, Vector2(80, -114), Vector2(162, 46))
	Labels["Cost"] = CreateLabel("", Vector2(-52, 68), Vector2(294, 46))
	Labels["Level"] = CreateLabel("", Vector2(-242, 68), Vector2(162, 46))

func _ready():
	CreateButton()
	add_to_group("ButtonUpgrade")
	if Source in ["Seed", "Root", "Wood", "Leaf"]:
		add_to_group(Source)
	StartCost = Cost
	call_deferred("CheckUnlocks")
	call_deferred("UpdateButtonText")
	UnlockButtonFunction()

func CheckUnlocks():
	Data = get_tree().get_first_node_in_group("Process")
	if UnlockToggle:
		for Upg in get_tree().get_nodes_in_group("ButtonUpgrade"):
			if Upg.Number in UnlockTargets:
				Upg.Labels["Button"].disabled = true
				UnlockFunc()

func UnlockButtonFunction():
	for UnlockNumber in UnlockBtn:
		if UnlockNumber != "":
			var UpgradeNumbers = get_tree().get_nodes_in_group("ButtonUpgrade")
			for ButtonMain in UpgradeNumbers:
				if ButtonMain.Number == UnlockNumber:
					ButtonMain.visible = true

func _on_pressed():
	if Data.get(Source) >= Cost and CurLevel < MaxLevel:
		Data.set(Source, Data.get(Source) - Cost)
		if IsExponent:
			if IsMulti:
				Data.set("Multi" + Target, Data.get("Multi" + Target) * Upgrade)
			Data.set("Base" + Target, Data.get("Base" + Target) * Upgrade)
		else:
			if IsMulti:
				Data.set("Multi" + Target, Data.get("Multi" + Target) + Upgrade)
			Data.set("Base" + Target, Data.get("Base" + Target) + Upgrade)
		CurLevel += 1
		Cost *= CostExponent
		Data.UpdateUI()
		TimerFunc()
		BloomFunc()
		BoostFunc()
		BoostCapFunc()
		ReduceFunc()
		SynergyFunc()
		UpdateButtonText()
		UnlockFunc()
		UnlockButtonFunction()

func UpdateButtonText():
	if Labels.has("Number"):
		Labels["Number"].text = Number
	if Labels.has("Level"):
		Labels["Level"].text = "Level: %d / %d" % [CurLevel, MaxLevel]
	if Labels.has("Cost") and Labels.has("Button"):
		if BoostToggle and CurLevel > 0 and Data != null:
			var ratio = min(Data.get("Boost" + Target), Data.get("BoostCap" + Target)) / max(Data.get("Base" + Target), 1.0)
			Labels["Cost"].text = "Currently: %.2fx%s" % [ratio, " (Capped)" if Data.get("Boost" + Target) >= Data.get("BoostCap" + Target) else ""]
			Labels["Button"].text = Text
			Labels["Button"].disabled = false
		elif CurLevel >= MaxLevel:
			Labels["Cost"].text = "Maxed" if MaxLevel > 1 else "Bought"
			Labels["Button"].disabled = true
		else:
			if CurLevel == 0:
				Labels["Cost"].text = "Free" if Cost == 0.0 else "Cost: %s %s" % [Num.Format(Cost), Source]
			else:
				Labels["Cost"].text = "Cost: %s %s" % [Num.Format(Cost), Source]
			Labels["Button"].text = Text
			Labels["Button"].disabled = false
#endregion

#region Button Upgrade: Types & Extra
#region Types
func BloomFunc():
	if BloomToggle and CurLevel % BloomInterval == 0 and CurLevel > 0:
		Data.set("Base" + Target, Data.get("Base" + Target) * BloomValue)

func TimerFunc():
	if TimerToggle:
		Data.set("Time" + Target, Data.get("Time" + Target) - TimerValue)

func BoostFunc():
	if BoostToggle:
		var SourceNode: Node = null
		if BoostSource != "":
			SourceNode = get_tree().get_first_node_in_group(BoostSource)
		var _Owned: float = 0.0
		if SourceNode != null:
			if Data.HasProperty(SourceNode, "Seed"):
				_Owned = float(SourceNode.get("Seed"))
		else:
			_Owned = float(CurLevel)
		Data.ApplyBoost(BoostTarget, BoostValue)
		UpdateButtonText()

func ReduceFunc():
	if ReduceToggle:
		var ButtonInfo = get_tree().get_nodes_in_group("ButtonUpgrade")
		for Upg in ButtonInfo:
			if Upg.Number == ReduceTarget:
				Upg.Cost = ReduceValue
				if Upg.Labels.has("Cost"):
					Upg.Labels["Cost"].text = "Cost: %s %s" % [Num.Format(Upg.Cost), Upg.Source]

func SynergyFunc():
	if not SynergyToggle: 
		return
	var NodeA: UpgradeData = null
	var NodeB: UpgradeData = null
	for Upg in get_tree().get_nodes_in_group("ButtonUpgrade"):
		if Upg.Number == SynergyTargets[0]:
			NodeA = Upg
		elif Upg.Number == SynergyTargets[1]:
			NodeB = Upg
	if NodeA != null and NodeB != null and NodeA.CurLevel >= 1 and NodeB.CurLevel >= 1:
		var SynergyTexture = Sprite2D.new()
		SynergyTexture.texture = preload("res://Sprites/UpgradeTree/SynergyButton.png")
		SynergyTexture.global_position = (NodeA.global_position + NodeB.global_position) / 2
		SynergyTexture.scale = Vector2(0.519, 0.5)
		SynergyTexture.add_to_group("Synergy")
		var SynergyLabel = Label.new()
		SynergyLabel.add_theme_font_size_override("font_size", 24)
		SynergyLabel.text = SynergyRewardText
		SynergyLabel.size = Vector2(897, 128)
		SynergyLabel.position = Vector2(-448, -64)
		SynergyLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		SynergyLabel.vertical_alignment = VERTICAL_ALIGNMENT_FILL
		SynergyTexture.add_child(SynergyLabel)
		get_tree().current_scene.add_child(SynergyTexture)
		for Reward in SynergyReward:
			if typeof(Reward) == TYPE_DICTIONARY and Reward.has("Type"):
				match Reward["Type"]:
					"Multi":
						if Reward.has("Target") and Reward.has("Value") and Data.has_method("get") and Data.has_method("set"):
							if Reward.has("IsExponent") and Reward["IsExponent"] == true:
								if Reward.has("IsMulti") and Reward["IsMulti"] == true:
									Data.set("Multi" + Reward["Target"], Data.get("Multi" + Reward["Target"]) * Reward["Value"])
								else:
									Data.set("Base" + Reward["Target"], Data.get("Base" + Reward["Target"]) * Reward["Value"])
							else:
								if Reward.has("IsMulti") and Reward["IsMulti"] == true:
									Data.set("Multi" + Reward["Target"], Data.get("Multi" + Reward["Target"]) + Reward["Value"])
								else:
									Data.set("Base" + Reward["Target"], Data.get("Base" + Reward["Target"]) + Reward["Value"])
					"Reduce":
						if Reward.has("Target") and Reward.has("Value"):
							for ReduceUpgrade in get_tree().get_nodes_in_group("ButtonUpgrade"):
								if ReduceUpgrade.Number == Reward["Target"]:
									ReduceUpgrade.Cost = Reward["Value"]
									if ReduceUpgrade.Labels.has("Cost"):
										ReduceUpgrade.Labels["Cost"].text = "Cost: %s %s" % [Num.Format(ReduceUpgrade.Cost), ReduceUpgrade.Source]
					"Boost":
						if Reward.has("Target") and Reward.has("Value"):
							Data.ApplyBoost(Reward["Target"], Reward["Value"])
					"Timer":
						if Reward.has("Target") and Reward.has("Value"):
							Data.set("Time" + Reward["Target"], Data.get("Time" + Reward["Target"]) - Reward["Value"])
					"BoostCap":
						if Reward.has("Target") and Reward.has("Value"):
							Data.set("BoostCap" + Reward["Target"], Data.get("BoostCap" + Reward["Target"]) + Reward["Value"])
#endregion
#region Extra
func BoostCapFunc():
	if CapToggle:
		Data.set("BoostCap" + Target, Data.get("BoostCap" + Target) + CapValue)

func UnlockFunc():
	if not UnlockToggle or not Labels.has("Button"):
		return
	for Index in range(min(UnlockTargets.size(), UnlockValues.size())):
		var TargetID = UnlockTargets[Index]
		var NeededLevel = UnlockValues[Index]
		for Upg in get_tree().get_nodes_in_group("ButtonUpgrade"):
			if Upg.Number == TargetID:
				var button_pos = Upg.Labels["Button"].global_position + Vector2(128, 64)
				if UnlockSource.CurLevel < NeededLevel:
					var texture_exists = false
					for child in get_tree().current_scene.get_children():
						if child is Sprite2D and child.global_position == button_pos:
							texture_exists = true
							break
					if not texture_exists:
						var LockedTexture = Sprite2D.new()
						LockedTexture.texture = preload("res://Sprites/UpgradeTree/LockedButton.png")
						LockedTexture.scale = Vector2(0.5, 0.5)
						LockedTexture.global_position = button_pos
						LockedTexture.add_to_group("Locked")
						get_tree().current_scene.add_child(LockedTexture)
					Upg.Labels["Button"].disabled = true
					Upg.Labels["Button"].tooltip_text = "Unlocks at Level %d of '%s'" % [NeededLevel, Number]
				else:
					for child in get_tree().current_scene.get_children():
						if child is Sprite2D and child.is_in_group("Locked") and child.global_position == button_pos:
							child.queue_free()
					Upg.Labels["Button"].disabled = false
					Upg.Labels["Button"].tooltip_text = ""
#endregion
#endregion
