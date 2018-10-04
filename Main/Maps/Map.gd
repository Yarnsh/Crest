extends Navigation

onready var Players = $Players
onready var NPCs = $NPCs
onready var Items = $Items

func _load_item(state):
	var item = load("res://Items/" + state["type"] + ".tscn").instance()
	Items.add_child(item)
	item.setState(state)
	item.set_name(item.id)
	return item

func _remove_item(id):
	var i = Items.get_node(String(id))
	if (i != null):
		Items.remove_child(i)
		i.free()

func getState():
	var state = {}
	state["Items"] = {}
	for item in Items.get_children():
		state["Items"][item.name] = item.getState()
	return state
func setState(state):
	var items = state["Items"]
	for i in Items.get_children():
		var id = i.name
		if (items.has(id)):
			if (items[id] != null):
				pass
				i.setState(items[id])
		else:
			pass
			_remove_item(id)
		items.erase(id)
	for key in items:
		_load_item(items[key])