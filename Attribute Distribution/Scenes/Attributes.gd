extends Panel

class_name Attributes

var points : int = 100

var strength : int = 10
var agility : int = 10
var wisdom : int = 10

signal attribute_changed(attribute)

# Strength
const HP_INCREASE = 13.0
const HP_RECOVERY_INCREASE = 0.1

var _max_hp : float = 0
var _max_hp_recovery : float = 0

# Agility
const ARMOR_INCREASE = 0.3
const ATTACK_SPEED_INCREASE = 0.1

var _max_armor : float = 0
var _max_attack_speed : float = 0

# Wisdom
const MANA_INCREASE = 13.0
const MANA_RECOVERY_INCREASE = 0.1

var _max_mana : float = 0
var _max_mana_recovery : float = 0


func add_attribute(attribute : String ,value = 1):
	attribute = attribute.to_lower()
	if points >= value:
		points -= value
		set(attribute, get(attribute) + value)
		
		var status_to_change = []
		match attribute:
			"strength":
				status_to_change.append("hp")
				status_to_change.append("hp_recovery")
			"agility":
				status_to_change.append("armor")
				status_to_change.append("attack_speed")
			"wisdom":
				status_to_change.append("mana")
				status_to_change.append("mana_recovery")
		for status in status_to_change:
			set("_max_"+status, get(attribute) * get(status.to_upper()+"_INCREASE"))
		emit_signal("attribute_changed", attribute)

# -------------
func _ready():
	connect("attribute_changed", self, "_update_attributes")
	$Strength/Button.connect("pressed", self, "add_attribute", ["strength"])
	$Agility/Button.connect("pressed", self, "add_attribute", ["agility"])
	$Wisdom/Button.connect("pressed", self, "add_attribute", ["wisdom"])

	add_attribute("strength", 10)
	add_attribute("agility", 10)
	add_attribute("wisdom", 10)

func _update_attributes(attribute : String):
	(get_node("Points/Value") as Label).text = str( points )
	(get_node(attribute.capitalize() + "/Value") as Label).text = str( get(attribute) )
