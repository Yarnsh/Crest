extends PanelContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var ButtonMain = $Button
onready var EquipButton = $Button/HBoxContainer/Equip
onready var DropButton = $Button/HBoxContainer/Drop
onready var Selectbox = $CSelect
var selected = false;
var equipped = false;

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass 

func _update():
	if (equipped == true):
		EquipButton.text = "Unequip";
	else:
		EquipButton.text = "Equip";
#	if (selected == true):
#		#Selectbox.hide()
#	else:
#		#Selectbox.show()


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

	

