extends Node

var actor = null

func isInCombat():
	return actor.in_combat

func getPosition():
	return actor.global_transform.origin
func setPosition(pos):
	actor.global_transform.origin = pos

func _checkIsController(a):
	return a.has_method("getPosition") and a.has_method("isInCombat")

func isDead():
	return actor.is_dead

func updateWorld():
	actor.updateWorld()