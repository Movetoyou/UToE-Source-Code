extends Node

var Seed: float = 0.0
var Seed_BaseIncome: float = 0.0
var Seed_BoostIncome: float = 0.0
var Seed_CurTime: float = 0.0
var Seed_IncomeTime: float = 1.0

var Root: float = 0.0
var Root_BaseIncome: float = 0.0
var Root_BoostIncome: float = 0.0
var Root_CurTime: float = 0.0
var Root_IncomeTime: float = 1.0

var Wood: float = 0.0
var Wood_BaseIncome: float = 0.0
var Wood_BoostIncome: float = 0.0
var Wood_CurTime: float = 0.0
var Wood_IncomeTime: float = 1.0

var Leaf: float = 0.0
var Leaf_BaseIncome: float = 0.0
var Leaf_BoostIncome: float = 0.0
var Leaf_CurTime: float = 0.0
var Leaf_IncomeTime: float = 1.0

var Boost := {}

var Infos = [0, 1, 2, 3]
var CurInfoIndex := 0
var LastPurchaseTime: int = 0
var ShowTimer: bool = true
