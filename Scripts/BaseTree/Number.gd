extends Node
class_name NumberFormatter

var Suffixes := ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"]

func Format(Value: float) -> String:
	if Value == 0:
		return "0"
	var ABSValue := absf(Value)
	var Index := 0
	while ABSValue >= 1000.0 and Index < Suffixes.size() - 1:
		ABSValue /= 1000.0
		Value /= 1000.0
		Index += 1
	if Index == Suffixes.size() - 1 and ABSValue >= 1000.0:
		return "%.2e" % float(Value)
	var StringValue := String.num(Value, 2).rstrip("0").rstrip(".")
	return "%s%s" % [StringValue, Suffixes[Index]]
