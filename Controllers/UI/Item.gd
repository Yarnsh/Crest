extends PanelContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var EquipButton = $Button/HBoxContainer/Equip
onready var DropButton = $Button/HBoxContainer/Drop

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _selected_display():
	EquipButton.show();
	DropButton.show();

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed():
	_selected_display();
