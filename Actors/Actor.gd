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

var is_attacking = false
var startup_ends = 0
var anim_cooldown_ends = 0
var attack_towards = null
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

var max_wounds = [3,2,1]
var current_wounds = [0,0,0]
var defense = [2,10,20,40]
var is_dead = false

var playing_anim = null
var playing_anim_started = 0

var global_cooldown = 5.0
var global_cooldown_ends = 0
func startGlobalCooldown():
	global_cooldown_ends = global.clock + global_cooldown
func isOnGlobalCooldown():
	return global.clock < global_cooldown_ends

func getState():
	pass
func setState():
	pass

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
	while (defense[damage_tier+1] <= damage or (damage_tier >= 0 and current_wounds[damage_tier] >= max_wounds[damage_tier])):
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
	spatial.transform.origin = Vector3(pos.x, 0, pos.y)
	#TODO: make this match to the height of the navmesh at that point
	return pos

func walkTowards(dest):
	queued_ability_name = null
	if (!busy):
		_walk(dest)
		pick_up = null

func _walk(dest):
	if (world != null):
		var close_dest = world.get_closest_point(Vector3(dest.x, 0, dest.y))
		#TODO: this contains starting point I believe so remove that before doing movement
		walk_path = Array(world.get_simple_path(Vector3(transform.origin.x, 0, transform.origin.y), close_dest))
		var walk3D = walk_path.pop_front()
		walk_towards = Vector2(walk3D.x, walk3D.z)
		var walkDest3D = walk_path.back()
		walk_dest = Vector2(walkDest3D.x, walkDest3D.z)
	else:
		walk_towards = dest

func _turn_towards(point):
	var target = -point + (2 * get_global_position())
	turn_dir = (target - get_global_position()).normalized()
	if (get_global_position() != target):
		model.look_at(Vector3(target.x, 0.0 ,target.y), Vector3(0,1,0))
func _turn_towards_direction(dir):
	turn_dir = dir
	if (dir.length_squared() > 0.0):
		model.look_at(Vector3(get_global_position().x + dir.x, 0.0 ,get_global_position().y + dir.y), Vector3(0,1,0))

func _anim_playing(anim, start_at = null):
	if (anim_player.get_current_animation() != anim):
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