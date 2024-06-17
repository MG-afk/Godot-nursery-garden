class_name ResourcesManager

signal goldChanged
var gold = 10

func increase_gold(amount):
	gold += amount
	goldChanged.emit()

func try_spend_gold(amount) -> bool:
	if gold - amount < 0:
		return false
	
	gold -= amount
	goldChanged.emit()
	return true;
