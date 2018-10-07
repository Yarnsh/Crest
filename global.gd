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
	
	"Armor/Head":preload("res://Items/Armor/Assets/head.png"),
	"Armor/Chest":preload("res://Items/Armor/Assets/chest.png"),
	"Armor/Arms":preload("res://Items/Armor/Assets/arms.png"),
	"Armor/Legs":preload("res://Items/Armor/Assets/legs.png"),
	
	"Armor/KnightHelm":preload("res://Items/Armor/Assets/knighthelm.png"),
	"Armor/KnightChest":preload("res://Items/Armor/Assets/knightchest.png"),
	"Armor/KnightGauntlets":preload("res://Items/Armor/Assets/knightgauntlets.png"),
	"Armor/KnightGreaves":preload("res://Items/Armor/Assets/knightgreaves.png"),
	
	"Armor/HunterHelm":preload("res://Items/Armor/Assets/knighthelm.png"),
	"Armor/HunterChest":preload("res://Items/Armor/Assets/knightchest.png"),
	"Armor/HunterGauntlets":preload("res://Items/Armor/Assets/knightgauntlets.png"),
	"Armor/HunterGreaves":preload("res://Items/Armor/Assets/knightgreaves.png"),
	}

func xzPlaneIntersect(pos, dir):
	if (dir.y == 0):
		return Vector3(0,0,0) #no value makes sense here but whatever
	return pos + ((-pos.y / dir.y) * dir)

func to2D(vec):
	return Vector2(vec.x * 100.0, vec.z * 100.0)
func to3D(vec):
	return Vector3(vec.x / 100.0, 0, vec.y / 100.0)

func randomPointInRadius(rad):
	var vec = Vector2(0, randf() * rad)
	return vec.rotated(randf() * 2 * PI)

func _process(delta):
	clock += delta