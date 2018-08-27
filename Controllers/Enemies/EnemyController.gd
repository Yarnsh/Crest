extends "res://Controllers/BaseController.gd"

var spawnPos = Vector2(0,0)

var dead_end = 0
var dead_cooldown = 10.0
var dead_confirmed = false
func startDeadCooldown():
	dead_end = global.clock + dead_cooldown
func isOnDeadCooldown():
	return global.clock < dead_end

func setSpawnPosition(pos):
	spawnPos = global.to2D(pos)

func _distanceTo(thing):
	return getPosition().distance_to(thing.getPosition())

func getState():
	#TODO: add AI state to gets, grab it from sets
	if (typeof(actor) != TYPE_NIL):
		return actor.getState()
	else:
		print("FAILED TO GET STATE " + self.name)
		return null
func setState(state):
	if (typeof(actor) != TYPE_NIL):
		actor.setState(state)
	else:
		print("FAILED TO SET STATE " + self.name)