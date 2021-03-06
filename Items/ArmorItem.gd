extends "res://Items/BaseItem.gd"

const type = "ArmorItem"
const iname = "NAME"
const desc = ""
const defense = [0,0,0,0]
const weight = 0

onready var mesh = ($Model).get_child(0).get_child(0).get_child(0)

func getAbilities():
	return abilities.get_children()

func containsAbility(ability):
	return getAbilities().has(ability)

func startTowardsByName(user, ability, point):
	var a = abilities.find_node(ability)
	if (a != null):
		a.setUser(user)
		a.startTowards(point)

func pointTowardsByName(ability, point):
	var a = abilities.find_node(ability)
	if (a != null):
		a.pointTowards(point)

#TODO: add defensive values and such

func getState():
	var state = .getState()
	var abils = []
	for a in getAbilities():
		abils.append(a.getState())
	state["abilities"] = abils
	return state

func setState(state):
	.setState(state)
	
	for a in state["abilities"]:
		var n = abilities.find_node(a["name"])
		if (n != null):
			n.setState(a)
		else:
			print("item state included ability that was not found")