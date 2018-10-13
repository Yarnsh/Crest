extends KinematicBody2D

var lock = Mutex.new()
func lock():
	lock.lock()
func unlock():
	lock.unlock()

signal inventory_updated
signal equipment_updated
signal damage_updated
signal in_combat
signal out_combat
signal scene_switch(to_map, to_point)
signal talk_to(talk_to)

var world
onready var spatial = $Spatial
onready var model = $Spatial/Model
onready var anim_player = $Spatial/Model/AnimationPlayer
onready var skeleton = $Spatial/Model/Armature/Skeleton

var highlight_count = 0

var in_combat = false
var busy = false
var queued_ability_name = null
var queued_ability_point = Vector2(0,0)

var startup_ends = 0
var anim_cooldown_ends = 0
func startAnimCooldown(anim_cooldown):
	anim_cooldown_ends = global.clock + anim_cooldown
func isOnAnimCooldown():
	return global.clock < anim_cooldown_ends

var walk_path = null
var walk_towards = null
var walk_dest = null
var turn_dir = Vector2(0,1)
var walk_speed = 0.0

var pick_up = null
var move_through = null
var talk_to = null

var is_attacking = false
var attack_towards = null

var max_wounds = [3,2,1]
var current_wounds = [0,0,0]
var defense = [2,10,20,40]
var current_defense = defense
var is_dead = false

var playing_anim = null
var playing_anim_started = 0

var global_cooldown = 5.0
var global_cooldown_ends = 0
func startGlobalCooldown():
	global_cooldown_ends = global.clock + global_cooldown
func isOnGlobalCooldown():
	return global.clock < global_cooldown_ends

var respawn_map = "Forest1" #Temporary until we figure out how to set respawn locations
var respawn_point = Vector3(0,0,0)
func setSpawn(map, point):
	respawn_map = map
	respawn_point = point

func getState():
	return {
		"id":self.name,
		"global_cooldown_ends":global_cooldown_ends,
		"anim_cooldown_ends":anim_cooldown_ends,
		"in_combat":in_combat,
		"busy":busy,
		"is_attacking":is_attacking,
		"walk_speed":walk_speed,
		"pos":get_global_position(),
		"walk_towards":walk_towards,
		"walk_path":walk_path,
		"walk_dest":walk_dest,
		"current_wounds":current_wounds,
		"is_dead":is_dead,
		"defense":defense,
		"current_defense":current_defense,
		"queued_ability_name":queued_ability_name,
		"queued_ability_point":queued_ability_point,
		"turn_dir":turn_dir,
		"playing_anim":playing_anim,
		"playing_anim_started":playing_anim_started,
		}

func setState(state):
	setInCombat(state["in_combat"])
	setBusy(state["busy"])
	is_attacking = state["is_attacking"]
	
	global_cooldown_ends = state["global_cooldown_ends"]
	anim_cooldown_ends = state["anim_cooldown_ends"]
	
	walk_speed = state["walk_speed"]
	
	set_global_position(state["pos"])
	walk_towards = state["walk_towards"]
	walk_path = state["walk_path"]
	walk_dest = state["walk_dest"]
	
	current_wounds = state["current_wounds"]
	defense = state["defense"]
	current_defense = state["current_defense"]
	is_dead = state["is_dead"]
	emit_signal("damage_updated")
	
	queued_ability_name = state["queued_ability_name"]
	queued_ability_point = state["queued_ability_point"]
	
	_turn_towards_direction(state["turn_dir"])
	
	if (state["playing_anim"] != null):
		_anim_playing(state["playing_anim"], state["playing_anim_started"])

func reset():
	in_combat = false
	emit_signal("out_combat")
	current_wounds = [0,0,0]
	is_dead = false
	emit_signal("damage_updated")

func toggleInCombat():
	in_combat = !in_combat
	if (in_combat):
		emit_signal("in_combat")
	else:
		emit_signal("out_combat")

func setInCombat(val):
	if (in_combat != val):
		in_combat = val
		if (in_combat):
			emit_signal("in_combat")
		else:
			emit_signal("out_combat")
		walk_towards = null
		pick_up = null
		busy = false

func setBusy(b):
	busy = b

func takeHit(damage, source=null):
	var damage_tier = -1
	while (current_defense[damage_tier+1] <= damage or (damage_tier >= 0 and current_wounds[damage_tier] >= max_wounds[damage_tier])):
		damage_tier += 1
		if (damage_tier >= max_wounds.size()):
			is_dead = true
			emit_signal("damage_updated")
			return
	if (damage_tier >= 0):
		startAnimCooldown(1.0)
		_anim_playing("Damage")
		current_wounds[damage_tier] += 1
	
	if (source != null and source.get_ref() != null):
		setInCombat(true)
		source.get_ref().setInCombat(true)
	
	emit_signal("damage_updated")

func setPosition(pos):
	set_global_position(pos)
	_updateModelPosition()

func _updateModelPosition():
	var pos = get_position()
	spatial.transform.origin = global.to3D(pos)
	#TODO: make this match to the height of the navmesh at that point
	return pos

func walkTowards(dest):
	queued_ability_name = null
	if (!busy):
		_walk(dest)
		move_through = null
		pick_up = null
		talk_to = null

func pickUp(item):
	#TODO: check if item is able to be reached
	#TODO: ignore this in combat probably
	queued_ability_name = null
	move_through = null
	talk_to = null
	if (item != null and !busy):
		pick_up = weakref(item)
		_walk(pick_up.get_ref().getGlobalPosition())

func moveThrough(target):
	#TODO: ignore this in combat probably
	queued_ability_name = null
	pick_up = null
	talk_to = null
	if (target != null and !busy):
		move_through = weakref(target)
		_walk(global.to2D(target.getGlobalPosition()))

func talkTo(target):
	#TODO: ignore this in combat probably
	queued_ability_name = null
	pick_up = null
	move_through = null
	if (target != null and !busy):
		talk_to = weakref(target)
		_walk(global.to2D(target.getGlobalPosition()))

func _walk(dest):
	if (world != null):
		var close_dest = world.get_closest_point(global.to3D(dest))
		#TODO: this contains starting point I believe so remove that before doing movement
		walk_path = Array(world.get_simple_path(global.to3D(transform.origin), close_dest))
		if (!walk_path.empty()):
			var walkDest3D = walk_path.back()
			walk_dest = global.to2D(walkDest3D)
			var walk3D = walk_path.pop_front()
			walk_towards = global.to2D(walk3D)
	else:
		walk_towards = dest

func _turn_towards(point):
	var target = -point + (2 * get_global_position())
	turn_dir = (target - get_global_position()).normalized()
	if (get_global_position() != target):
		model.look_at(global.to3D(target), Vector3(0,1,0))
func _turn_towards_direction(dir):
	turn_dir = dir
	if (dir.length_squared() > 0.0):
		model.look_at(global.to3D(get_global_position() + dir), Vector3(0,1,0))

func _anim_playing(anim, start_at = null):
	if (anim_player.get_assigned_animation() != anim):
		anim_player.play(anim)
		if (start_at != null):
			anim_player.seek(global.clock - start_at)
			playing_anim_started = start_at
		else:
			playing_anim_started = global.clock
		playing_anim = anim

func setHighlight(highlight):
	#TODO: make this not stupid like it is right now
	if (highlight):
		highlight_count += 1
	else:
		highlight_count -= 1
	if (highlight_count > 0):
		model.get_child(0).get_child(0).get_child(0).get_mesh().surface_get_material(0).set_next_pass(preload("res://highlightMat.tres"))
	else:
		model.get_child(0).get_child(0).get_child(0).get_mesh().surface_get_material(0).set_next_pass(null)

func updateWorld():
	world = get_parent().get_parent().get_parent()
