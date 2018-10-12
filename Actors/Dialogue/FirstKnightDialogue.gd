extends "res://Actors/Dialogue/BaseDialogue.gd"

func get(other_id):
	var r
	if not state.has(other_id):
		state[other_id] = {}
		r = {"title":"A", "content":"WHAT SAY YE?", "responses":["A", "B", "C"]}
	else:
		r = {"title":"A", "content":"Ye sayith " + state[other_id]["resp"] + " last", "responses":["A", "B", "C"]}
	r
	return r

func respond_get(other_id, response):
	state[other_id]["resp"] = response