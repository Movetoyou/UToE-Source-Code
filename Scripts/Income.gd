extends Node
class_name Income

@onready var InfoLabel = $CanvasLayer/InfoDataLabel
@onready var BackButton = $CanvasLayer/InfoDataLabel/Back
@onready var NextButton = $CanvasLayer/InfoDataLabel/Next
@onready var SeedNode = $Seed
@onready var RootNode = $Root
@onready var WoodNode = $Wood
@onready var LeafNode = $Leaf
@onready var TimerLabel = $CanvasLayer/TimerLabel
@onready var TreeSelectButton = $CanvasLayer/BackToTreeSelect

func _ready():
	add_to_group("IncomeHandler")
	TreeSelectButton.pressed.connect(_BackToTreeSelect)
	BackButton.pressed.connect(func(): OnInfoButtonPressed(-1))
	NextButton.pressed.connect(func(): OnInfoButtonPressed(1))
	UpdateLabel()
	OnInfoButtonPressed(0)
	for i in range(SeedNode.get_child_count()):
		var child = SeedNode.get_child(i)
		child.visible = (i == 0)

func _BackToTreeSelect():
	get_tree().change_scene_to_file("res://Scenes/TreeSelect.tscn")

func StartUpgradeTimer():
	Data.LastPurchaseTime = Time.get_ticks_usec()

func _process(delta):
	Data.Seed_CurTime += delta
	if Data.Seed_CurTime >= Data.Seed_IncomeTime:
		Data.Seed_BoostIncome = max(Data.Seed_BaseIncome, Data.Seed_BoostIncome) * GetBoostMultiplier("Seed")
		Data.Seed += Data.Seed_BoostIncome
		UpdateLabel()
		Data.Seed_CurTime = 0.0
	if Data.ShowTimer and Data.LastPurchaseTime > 0:
		var elapsed = (Time.get_ticks_usec() - Data.LastPurchaseTime) / 1000000.0
		TimerLabel.text = "Time after purchased: \n %.2f s" % elapsed

func UpdateLabel():
	var InfoData = Data.Infos[Data.CurInfoIndex]
	if InfoData == 0:
		InfoLabel.text = """Seed: %s
Base Income: %s
Boosted Income: %s
Boost Multiplier: %.3f
Income / sec: %s
Income Timer: %.2f""" % [
			BigNumber.FormatNotation(Data.Seed),
			BigNumber.FormatNotation(Data.Seed_BaseIncome),
			BigNumber.FormatNotation(Data.Seed_BoostIncome),
			GetBoostMultiplier("Seed"),
			BigNumber.FormatNotation(Data.Seed_BoostIncome / Data.Seed_IncomeTime),
			Data.Seed_IncomeTime
		]
	elif InfoData == 1:
		InfoLabel.text = """Root: %s
Base Income: %s
Boosted Income: %s
Boost Multiplier: %.3f
Income / sec: %s
Income Timer: %.2f""" % [
			BigNumber.FormatNotation(Data.Root),
			BigNumber.FormatNotation(Data.Root_BaseIncome),
			BigNumber.FormatNotation(Data.Root_BoostIncome),
			GetBoostMultiplier("Root"),
			BigNumber.FormatNotation(Data.Root_BoostIncome / Data.Root_IncomeTime),
			Data.Root_IncomeTime
		]
	elif InfoData == 2:
		InfoLabel.text = """Wood: %s
Base Income: %s
Boosted Income: %s
Boost Multiplier: %.3f
Income / sec: %s
Income Timer: %.2f""" % [
			BigNumber.FormatNotation(Data.Wood),
			BigNumber.FormatNotation(Data.Wood_BaseIncome),
			BigNumber.FormatNotation(Data.Wood_BoostIncome),
			GetBoostMultiplier("Wood"),
			BigNumber.FormatNotation(Data.Wood_BoostIncome / Data.Wood_IncomeTime),
			Data.Wood_IncomeTime
		]
	else:
		InfoLabel.text = """Leaf: %s
Base Income: %s
Boosted Income: %s
Boost Multiplier: %.3f
Income / sec: %s
Income Timer: %.2f""" % [
			BigNumber.FormatNotation(Data.Leaf),
			BigNumber.FormatNotation(Data.Leaf_BaseIncome),
			BigNumber.FormatNotation(Data.Leaf_BoostIncome),
			GetBoostMultiplier("Leaf"),
			BigNumber.FormatNotation(Data.Leaf_BoostIncome / Data.Leaf_IncomeTime),
			Data.Leaf_IncomeTime
		]

func OnInfoButtonPressed(Direction: int) -> void:
	Data.CurInfoIndex = clamp(Data.CurInfoIndex + Direction, 0, Data.Infos.size() - 1)
	UpdateLabel()
	BackButton.disabled = Data.CurInfoIndex == 0
	BackButton.visible = Data.CurInfoIndex != 0
	NextButton.disabled = Data.CurInfoIndex == Data.Infos.size() - 1
	NextButton.visible = Data.CurInfoIndex != Data.Infos.size() - 1

func ApplyBoost(BoostTarget: String, Multiplier: float) -> void:
	if not Data.Boost.has(BoostTarget): Data.Boost[BoostTarget] = 0.0
	Data.Boost[BoostTarget] += Multiplier / 2

func GetBoostMultiplier(BoostTarget: String) -> float: return 1.0 + Data.Boost.get(BoostTarget, 0.0)
