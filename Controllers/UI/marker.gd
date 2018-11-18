extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("AnimationPlayer").get_animation("default").set_loop(true)
	get_node("AnimationPlayer").play("default")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
