extends "res://Items/BaseItem.gd"

const type = "WeaponItem"
const slot = "Weapon"

func getAbilities():
	return abilities.get_children()

func containsAbility(ability):
	return getAbilities().has(ability)

func startTowardsByName(user, ability, point):
	var a = abilities.find_node(ability)
	if (a != null):
		a.setUser(user)
		a.startTowards(point)

func rMesh():
	pass

func lMesh():
	pass


func getState():
	var abils = []
	for a in getAbilities():
		abils.append(a.getState())
	return {"id":id, "type":type, "pos":get_position(), "abilities":abils}

func setState(state):
	id = state["id"]
	type = state["type"]
	set_position(state["pos"])
	
	for a in state["abilities"]:
		var n = abilities.find_node(a["name"])
		if (n != null):
			n.setState(a)
		else:
			print("item state included ability that was not found")