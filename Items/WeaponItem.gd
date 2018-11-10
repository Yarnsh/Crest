extends "res://Items/BaseItem.gd"

const type = "WeaponItem"
const slot = "Weapon"
const desc = ""
const attack = 0
const defense = [0,0,0,0]

func getAbilities():
	return abilities.get_children()

func containsAbility(ability):
	if !ability:
		return false
	return getAbilities().has(ability.get_ref())

func startTowardsByName(user, ability, point):
	var a = abilities.find_node(ability)
	if (a != null):
		a.setUser(user)
		a.startTowards(point)

func pointTowardsByName(ability, point):
	var a = abilities.find_node(ability)
	if (a != null):
		a.pointTowards(point)

func rMesh():
	pass

func lMesh():
	pass


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
