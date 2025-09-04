extends Sprite2D

#region Exports
@export var ButtonType: String
@export_group("Button Upgrade: Main")
@export_subgroup("Text Data")
@export var Name := ""
@export var Number := ""
@export_multiline var Text := ""
@export_subgroup("Value Data")
@export var IsExponent := false
var CurLevel := 0
@export var Value := 0.0
@export var Cost := 0.0
@export var Exponent := 1.0
@export var MaxLevel := 1
@export var UnlockBtn := ["Seed - 00", "Seed - 00"]
@export_group("Button Upgrade: Types")
@export_subgroup("Boost Data")
@export var BoostToggle := false
@export var BoostSource := ""
@export var BoostTarget := ""
@export var BoostValue := 0.0
@export_subgroup("Bloom Data")
@export var BloomToggle := false
@export var BloomInterval := 0
@export var BloomValue := 1.0
@export_subgroup("Synergy Data")
@export var SynergyToggle := false
@export var SynergyTargets := ["", ""]
@export var SynergyReward := [
	{"Type": "Multi", "Source": "", "Target": "", "ValueType": "", "Value": 1.0},
	{"Type": "Boost", "Source": "", "Target": "", "ValueType": "", "Value": 1.0},
	{"Type": "Reduce", "Source": "", "Target": "", "ValueType": "", "Value": 1.0},
	{"Type": "Delta", "Source": "", "Target": "", "ValueType": "", "Value": 1.0}
	]
@export_multiline var SynergyRewardText := ""
@export_subgroup("Cost Reduction Data")
@export var ReduceToggle := false
@export var ReduceTarget := ""
@export var ReduceValue := 0
@export_subgroup("Timer Reduction Data")
@export var TimerToggle := false
@export var TimerValue := 0.0
#endregion

#region Create UI
func CreateLabel(UpName: String, UpPos: Vector2, UpSize: Vector2):
	var label := Label.new()
	label.position = UpPos
	label.size = UpSize
	label.text = UpName
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	return label

func CreateButton():
	var button := Button.new()
	button.size = Vector2(512, 256)
	button.position = Vector2(-256, -128)
	button.text = Text
	button.flat = true
	button.add_theme_font_size_override("font_size", 28)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(_on_pressed)
	Labels["Button"] = button
	add_child(button)
	Labels["Name"] = CreateLabel(Name, Vector2(-242, -114), Vector2(360, 48))
	Labels["Number"] = CreateLabel(Number, Vector2(132, -114), Vector2(110, 48))
	Labels["Number"].add_theme_font_size_override("font_size", 20)
	Labels["Cost"] = CreateLabel("Cost: %s" % Cost, Vector2(-4, 60), Vector2(248, 54))
	Labels["Level"] = CreateLabel("Level: %d / %s" % [CurLevel, MaxLevel], Vector2(-242, 60), Vector2(224, 54))
#endregion

#region Mechanics
func BoostFunction():
	if not BoostToggle or IncomeH == null: return
	var SourceNode = get_tree().get_first_node_in_group(BoostSource)
	var _Owned: float = 0.0
	if SourceNode != null:
		if SourceNode.has_variable("Seed"): _Owned = float(SourceNode.Seed)
	else: _Owned = float(CurLevel)
	IncomeH.ApplyBoost(BoostTarget, BoostValue)
	UpdateBoostedIncome()

func BloomFunction():
	if not BloomToggle or IncomeH == null: return
	if CurLevel % BloomInterval == 0 and CurLevel > 0: Data.Seed_BaseIncome *= BloomValue
	UpdateBoostedIncome()

func SynergyFunction():
	if not SynergyToggle or IncomeH == null: return
	var AllUpgrades = get_tree().get_nodes_in_group("UpgradeButtons")
	var NodeA = null
	var NodeB = null
	for Upgrade in AllUpgrades:
		if Upgrade.Number == SynergyTargets[0]: NodeA = Upgrade
		elif Upgrade.Number == SynergyTargets[1]: NodeB = Upgrade
	if NodeA != null and NodeB != null and NodeA.CurLevel >= 1 and NodeB.CurLevel >= 1:
		NodeA.visible = false
		NodeB.visible = false
		var synergy_texture = Sprite2D.new()
		synergy_texture.texture = preload("res://Sprites/SynergyButton.png")
		var midpoint = (NodeA.global_position + NodeB.global_position) / 2
		synergy_texture.global_position = midpoint
		synergy_texture.scale = Vector2(0.5, 0.5)
		var synergy_label = Label.new()
		synergy_label.add_theme_font_size_override("font_size", 36)
		synergy_label.text = SynergyRewardText
		synergy_label.size = Vector2(1082, 226)
		synergy_label.position = Vector2(-541, -113)
		synergy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		synergy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		synergy_texture.add_child(synergy_label)
		get_tree().current_scene.add_child(synergy_texture)
		for Reward in SynergyReward:
			if typeof(Reward) == TYPE_DICTIONARY and Reward.has("Type"):
				match Reward["Type"]:
					"Multi":
						if Reward.has("Target") and Reward.has("Value"):
							var MultiTarget = Reward["Target"]
							var MultiValue = Reward["Value"]
							if Reward.has("ValueType"): IsExponent = Reward["ValueType"] == "Exponent" or Reward["ValueType"] == true
							if MultiTarget == "Seed":
								if IsExponent: Data.Seed_BaseIncome *= MultiValue
								else: Data.Seed_BaseIncome += MultiValue
							elif MultiTarget == "Root":
								if IsExponent: Data.Root_BaseIncome *= MultiValue
								else: Data.Root_BaseIncome += MultiValue
							elif MultiTarget == "Wood":
								if IsExponent: Data.Wood_BaseIncome *= MultiValue
								else: Data.Wood_BaseIncome += MultiValue
							elif MultiTarget == "Leaf":
								if IsExponent: Data.Leaf_BaseIncome *= MultiValue
								else: Data.Leaf_BaseIncome += MultiValue
					"Boost":
						if Reward.has("Target") and Reward.has("Source") and Reward.has("Value"):
							IncomeH.ApplyBoost(Reward["Target"], Reward["Value"])
					"Reduce":
						if Reward.has("Target") and Reward.has("Value"):
							for ReduceUpgrade in AllUpgrades:
								if ReduceUpgrade.Number == Reward["Target"]:
									if Reward.has("ValueType") and Reward["ValueType"] == "Exponent": ReduceUpgrade.Cost *= Reward["Value"]
									else: ReduceUpgrade.Cost = Reward["Value"]
									if ReduceUpgrade.Labels.has("Cost"):
										ReduceUpgrade.Labels["Cost"].text = "Cost: %s %s" % [BigNumber.FormatNotation(ReduceUpgrade.Cost), ButtonType]
					"Delta":
						if Reward.has("Target") and Reward.has("Value"):
							var DeltaTarget = Reward["Target"]
							var SDeltaValue = Reward["Value"]
							if DeltaTarget == "Seed": Data.Seed_IncomeTime -= SDeltaValue
							elif DeltaTarget == "Root": Data.Root_IncomeTime -= SDeltaValue
							elif DeltaTarget == "Wood": Data.Wood_IncomeTime -= SDeltaValue
							elif DeltaTarget == "Leaf": Data.Leaf_IncomeTime -= SDeltaValue
			UpdateBoostedIncome()

func ReduceFunction():
	if not ReduceToggle or IncomeH == null: return
	var UpgradeButtons = get_tree().get_nodes_in_group("UpgradeButtons")
	for Upgrade in UpgradeButtons:
		if Upgrade.Number == ReduceTarget:
			Upgrade.Cost = ReduceValue
			if Upgrade.Labels.has("Cost"): Upgrade.Labels["Cost"].text = "Cost: %s %s" % [BigNumber.FormatNotation(Upgrade.Cost), ButtonType]
			UpdateBoostedIncome()

func DeltaFunction():
	if not TimerToggle or IncomeH == null: return
	Data.Seed_IncomeTime -= TimerValue
	UpdateBoostedIncome()
#endregion

#region Main Functions
signal level_changed
var IncomeH: Income
var Labels: Dictionary = {}

func UpdateBoostedIncome():
	Data.Seed_BoostIncome = Data.Seed_BaseIncome * IncomeH.GetBoostMultiplier("Seed")
	Data.Root_BoostIncome = Data.Root_BaseIncome * IncomeH.GetBoostMultiplier("Root")
	Data.Wood_BoostIncome = Data.Wood_BaseIncome * IncomeH.GetBoostMultiplier("Wood")
	Data.Leaf_BoostIncome = Data.Leaf_BaseIncome * IncomeH.GetBoostMultiplier("Leaf")

func UnlockButtonFunction():
	for UnlockNumber in UnlockBtn:
		if UnlockNumber != "":
			var UpgradeNumbers = get_tree().get_nodes_in_group("UpgradeButtons")
			for ButtonMain in UpgradeNumbers:
				if ButtonMain.Number == UnlockNumber:
					ButtonMain.visible = true

func _ready():
	add_to_group("UpgradeButtons")
	call_deferred("Setup")

func Setup():
	IncomeH = get_tree().get_first_node_in_group("IncomeHandler")
	CreateButton()
	UpdateButtonText()
	if BoostToggle: level_changed.connect(BoostFunction)

func _on_pressed():
	if Data.Seed >= Cost and CurLevel < MaxLevel:
		Data.Seed -= Cost
		if IsExponent: Data.Seed_BaseIncome *= Value
		else: Data.Seed_BaseIncome += Value
		CurLevel += 1
		Cost *= Exponent
		emit_signal("level_changed")
		BoostFunction(); BloomFunction(); SynergyFunction(); ReduceFunction(); DeltaFunction()
		UpdateButtonText(); UnlockButtonFunction(); IncomeH.StartUpgradeTimer(); IncomeH.UpdateLabel()
#endregion

#region Update Text
func UpdateButtonText():
	if Labels.has("Number"): Labels["Number"].text = Number
	if Labels.has("Level"): Labels["Level"].text = "Level: %d / %d" % [CurLevel, MaxLevel]
	if Labels.has("Cost") and Labels.has("Button"):
		if CurLevel >= MaxLevel:
			Labels["Cost"].text = "Maxed" if MaxLevel > 1 else "Bought"
			Labels["Button"].disabled = true
		else:
			Labels["Cost"].text = "Free" if is_equal_approx(Cost, 0.0) else "Cost: %s %s" % [BigNumber.FormatNotation(Cost), ButtonType]
			Labels["Button"].text = Text
			Labels["Button"].disabled = false
#endregion
