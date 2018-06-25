extends Node

var clock = 0.0

var connectLock = Mutex.new()
var CONNECTED = false
var SERVER_PORT = 27015
var SERVER_IP = "127.0.0.1"

#World init parameters
var WORLD_MULTI = false
var WORLD_HOST = false
var WORLD_LOAD = false

#is this even how I should do this
var itemInventoryIcons = {
	"FistItem":preload("res://Items/Assets/Fist.png"),
	"PotionItem":preload("res://Items/Assets/Potion.png"),
	"SwordItem":preload("res://Items/Assets/Sword.png"),
	
	"Armor/Chest":preload("res://Items/Armor/Assets/chest.png"),
	"Armor/KnightChest":preload("res://Items/Armor/Assets/knightchest.png"),
	}

func xzPlaneIntersect(pos, dir):
	if (dir.y == 0):
		return Vector3(0,0,0) #no value makes sense here but whatever
	return pos + ((-pos.y / dir.y) * dir)

func _process(delta):
	clock += delta