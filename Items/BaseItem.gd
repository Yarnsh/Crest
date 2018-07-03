extends StaticBody

var id
var on_ground = true
const type = "BaseItem"
const slot = "None"
#TODO: have a lock for item interactions

onready var abilities = $Abilities

func __ITEM():
	pass #I hate this, not sure how else to tell it what type things are

func _ready():
	pass

func _init():
	#initialize a fresh base item
	id = uuid.v4()
	name = id

func getState():
	return {"id":id, "on_ground":on_ground, "type":type, "pos":global_transform.origin}
func setState(state):
	id = state["id"]
	type = state["type"]
	global_transform.origin = state["pos"]
	if (state["on_ground"]):
		on_ground = true
		input_ray_pickable = true
		show()
	else:
		on_ground = false
		input_ray_pickable = false
		hide()

func setGlobalPosition(pos):
	global_transform.origin = Vector3(pos.x, 0, pos.y)
func getGlobalPosition():
	return Vector2(global_transform.origin.x, global_transform.origin.z)

func pickUp():
	hide()
	on_ground = false
	input_ray_pickable = false
	transform.origin = Vector3(0,0,0)
func drop(pos):
	show()
	on_ground = true
	input_ray_pickable = true
	setGlobalPosition(pos)

func _process(delta):
	var pos = global_transform.origin
	if (abilities != null):
		abilities.set_global_position(Vector2(pos.x, pos.z))