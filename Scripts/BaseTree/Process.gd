extends Node2D
class_name Process

@onready var Info = $CanvasLayer/InfoLabel
@onready var Back = $CanvasLayer/InfoLabel/Back
@onready var Next = $CanvasLayer/InfoLabel/Next
@onready var SeedNode = $SeedButtons

var Seed := 0.0
var BaseSeed := 0.0
var BoostSeed := 0.0
var CurSeed := 0.0
var TimeSeed := 1.0
var BoostCapSeed := 2.5
var MultiSeed := 1.0

var Root := 0.0
var BaseRoot := 0.0
var BoostRoot := 0.0
var CurRoot := 0.0
var TimeRoot := 1.0
var BoostCapRoot := 2.5
var MultiRoot := 1.0

var Wood := 0.0
var BaseWood := 0.0
var BoostWood := 0.0
var CurWood := 0.0
var TimeWood := 1.0
var BoostCapWood := 2.5
var MultiWood := 1.0

var Leaf := 0.0
var BaseLeaf := 0.0
var BoostLeaf := 0.0
var CurLeaf := 0.0
var TimeLeaf := 1.0
var BoostCapLeaf := 2.5
var MultiLeaf := 1.0

var Boost := {}
var Infos := [0, 1, 2, 3]
var CurInfo := 0

func _ready():
	add_to_group("Process")
	Back.pressed.connect(func(): OnInfoButtonPressed(-1))
	Next.pressed.connect(func(): OnInfoButtonPressed(1))
	UpdateUI()
	OnInfoButtonPressed(0)
	for i in range(SeedNode.get_child_count()):
		var child = SeedNode.get_child(i)
		child.visible = (i == 0)

func _process(delta):
	CurSeed += delta
	if CurSeed >= TimeSeed:
		UpdateBoostedIncome()
		Seed += BoostSeed * MultiSeed
		CurSeed = 0.0
	UpdateUI()

func UpdateUI():
	var InfoType = Infos[CurInfo]
	if InfoType == 0:
		Info.text = "Seed: %s\nBase: %s\nBoosted: %s\nIncome: %s\nTimer: %.2f\nBoost: %.3f\nBoostCap: %s\nMulti: %.2f" % [Num.Format(Seed), Num.Format(BaseSeed), Num.Format(BoostSeed), Num.Format((BoostSeed / TimeSeed) * MultiSeed), TimeSeed, GetBoostMulti("Seed"), BoostCapSeed, MultiSeed]
	elif InfoType == 1:
		Info.text = "Root: %s\nBase: %s\nBoosted: %s\nIncome: %s\nTimer: %.2f\nBoost: %.3f\nBoostCap: %s\nMulti: %.2f" % [Num.Format(Root), Num.Format(BaseRoot), Num.Format(BoostRoot), Num.Format((BoostRoot / TimeRoot) * MultiRoot), TimeRoot, GetBoostMulti("Root"), BoostCapRoot, MultiRoot]
	elif InfoType == 2:
		Info.text = "Wood: %s\nBase: %s\nBoosted: %s\nIncome: %s\nTimer: %.2f\nBoost: %.3f\nBoostCap: %s\nMulti: %.2f" % [Num.Format(Wood), Num.Format(BaseWood), Num.Format(BoostWood), Num.Format((BoostWood / TimeWood) * MultiWood), TimeWood, GetBoostMulti("Wood"), BoostCapWood, MultiWood]
	else:
		Info.text = "Leaf: %s\nBase: %s\nBoosted: %s\nIncome: %s\nTimer: %.2f\nBoost: %.3f\nBoostCap: %s\nMulti: %.2f" % [Num.Format(Leaf), Num.Format(BaseLeaf), Num.Format(BoostLeaf), Num.Format((BoostLeaf / TimeLeaf) * MultiLeaf), TimeLeaf, GetBoostMulti("Leaf"), BoostCapLeaf, MultiLeaf]

func ApplyBoost(_BoostTarget: String, Multiplier: float) -> void:
	if not Boost.has(_BoostTarget):
		Boost[_BoostTarget] = 0.0
	Boost[_BoostTarget] += Multiplier

func GetBoostMulti(_BoostTarget: String) -> float:
	return 1.0 + Boost.get(_BoostTarget, 0.0)

func UpdateBoostedIncome():
	BoostSeed = min(max(BaseSeed, BoostSeed) * GetBoostMulti("Seed"), BaseSeed * BoostCapSeed)
	BoostRoot = min(max(BaseRoot, BoostRoot) * GetBoostMulti("Root"), BaseRoot * BoostCapRoot)
	BoostWood = min(max(BaseWood, BoostWood) * GetBoostMulti("Wood"), BaseWood * BoostCapWood)
	BoostLeaf = min(max(BaseLeaf, BoostLeaf) * GetBoostMulti("Leaf"), BaseLeaf * BoostCapLeaf)

func HasProperty(_Node: Object, _Name: String) -> bool:
	if _Node == null:
		return false
	for label in _Node.get_property_list():
		if label.has("Name") and label["Name"] == _Name:
			return true
	return false

func OnInfoButtonPressed(Direction: int) -> void:
	CurInfo = clamp(CurInfo + Direction, 0, Infos.size() - 1)
	UpdateUI()
	Back.disabled = CurInfo == 0
	Back.visible = CurInfo != 0
	Next.disabled = CurInfo == Infos.size() - 1
	Next.visible = CurInfo != Infos.size() - 1
