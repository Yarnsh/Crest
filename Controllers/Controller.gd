extends Node

func getState():
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


onready var cam = $Actor/Camera2D
onready var cam3D = $Actor/Spatial/Camera
onready var clickCast = $ClickCast
onready var mouseCast = $MouseCast
onready var inventoryUI = $CanvasLayer/Inventory
onready var abilityUI = $CanvasLayer/Abilities
onready var HUD = $CanvasLayer/HUD
onready var damageUI = $CanvasLayer/Damage
onready var WalkDest = $WalkDest
onready var WalkMarker = $WalkMarker

var actor

var attacking = false 

var ability_list = [null,null,null,null,null,null,null,null,null,null] #Hold weak_refs to abilities of the actor
var selected_ability = -1
func _checkAbilityByIndex(index):
	return (ability_list[index] != null and ability_list[index].get_ref() != null)
func _hideAllAbilities():
	for a in ability_list:
		if (a != null and a.get_ref() != null and a.get_ref().has_method("hideArea")):
			a.get_ref().hideArea()
func _selectAbility(id):
	if (!actor.busy):
		_hideAllAbilities()
		selected_ability = -1
		if (_checkAbilityByIndex(id)):
			ability_list[id].get_ref().setUser(actor) #This should be either on weapon equip or ability selection. Or make the attack start use it
			ability_list[id].get_ref().showArea()
			selected_ability = id

func _ready():
	actor = $Actor
	inventoryUI.init(self)
	abilityUI.init(self)
	HUD.init(self)
	damageUI.init(self)
	
	inventoryUI.updateItems(actor.inventory)
	abilityUI.updateAbilities()
	_checkAbilityHotslots()
	HUD.updateAbilityBar()
	damageUI.updateDamage()

func _checkAbilityHotslots():
	var i = 0
	for a in ability_list:
		if (actor.equipped_weapon != null and !actor.equipped_weapon.containsAbility(a)): #TODO: expand this to all equipment slots
			ability_list[i] = null
		i += 1

func setAbilityHotslot(slotnum, ability):
	ability_list[slotnum] = weakref(ability)
	HUD.updateAbilityBar()

func _get_item_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam3D.project_ray_origin(mouse_pos)
	var to = cam3D.project_ray_normal(mouse_pos) * 1000.0
	
	mouseCast.transform.origin = from
	mouseCast.cast_to = to
	mouseCast.force_raycast_update()
	
	if (mouseCast.is_colliding()):
		return mouseCast.get_collider()

func _get_pos_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam3D.project_ray_origin(mouse_pos)
	var to = cam3D.project_ray_normal(mouse_pos) * 1000.0
	
	mouseCast.transform.origin = from
	mouseCast.cast_to = to
	mouseCast.force_raycast_update()
	
	if (mouseCast.is_colliding()):
		return mouseCast.get_collision_point()

func _toggle_inventory():
	inventoryUI.toggle()
func _toggle_abilities():
	abilityUI.toggle()

func _on_Actor_inventory_updated():
	inventoryUI.updateItems(actor.inventory)

func _on_Actor_equipment_updated():
	inventoryUI.updateEquipment(actor.equipped_weapon, actor.equipped_head, actor.equipped_chest, actor.equipped_arms, actor.equipped_legs)
	abilityUI.updateAbilities()
	_checkAbilityHotslots()
	HUD.updateAbilityBar()

func _on_Actor_damage_updated():
	damageUI.updateDamage()

func _process(delta):
	if (actor.walk_towards == null):
		WalkDest.hide()
		WalkMarker.hide()
	else:
		if (actor.walk_dest != null):
			WalkDest.set_global_position(actor.walk_dest)
			WalkDest.show()
			WalkMarker.transform.origin = Vector3(actor.walk_dest.x, 0 , actor.walk_dest.y)
			WalkMarker.show()
	
	if (selected_ability >= 0 and _checkAbilityByIndex(selected_ability)):
		var mouse_pos = get_viewport().get_mouse_position()
		var clickpos = global.xzPlaneIntersect(cam3D.project_ray_origin(mouse_pos), cam3D.project_ray_normal(mouse_pos))
		if (clickpos != null):
			var clickpos2D = Vector2(clickpos.x, clickpos.z)
			ability_list[selected_ability].get_ref().pointTowards(clickpos2D)
	
	HUD.setMaxGlobalCooldown(actor.global_cooldown)
	HUD.setCurrentCooldown(actor.global_cooldown_ends - global.clock)

func isInCombat():
	return actor.in_combat