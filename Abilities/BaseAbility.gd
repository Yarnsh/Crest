extends Node

const ability_art = null
const ability_name = "Nothing"
const ability_desc = "How did you get this?"

var ability_user = null

onready var collider = $Collider
onready var model = $Collider/Shape/Model

const startup = 0.0
const cooldown = 0.0
const anim_cooldown = 0.0

var startup_ends = 0.0
var cooldown_ends = 0.0

var preview = false
var shown = false
var point_towards = Vector2(0,0)


func hideArea():
	preview = false
	_hideArea()
func _hideArea():
	collider.set_monitoring(false)
	collider.hide()
	model.hide()
	
func showArea():
	preview = true
	_showArea()
func _showArea():
	collider.set_monitoring(true)
	collider.show()
	model.show()

func _beginStartup():
	startup_ends = global.clock + startup
func _onStartup():
	return global.clock < startup_ends

func _beginCooldown():
	cooldown_ends = global.clock + cooldown
func _onCooldown():
	return global.clock < cooldown_ends

func pointTowards(point):
	if (!_onStartup()):
		collider.look_at(point)
		point_towards = point

func _pointTowardsUnchecked(point):
	collider.look_at(point)
	point_towards = point

func getPointTowards():
	return point_towards

func setUser(user):
	ability_user = weakref(user)

func getState():
	return {"name":name, "startup_ends":startup_ends, "cooldown_ends":cooldown_ends, "shown":shown, "point_towards":point_towards}

func setState(state):
	name = state["name"]
	startup_ends = state["startup_ends"]
	cooldown_ends = state["cooldown_ends"]
	
	shown = state["shown"]
	if (shown or preview):
		_showArea()
	else:
		_hideArea()
	
	_pointTowardsUnchecked(state["point_towards"])