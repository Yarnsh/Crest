extends "res://Actors/Dialogue/BaseDialogue.gd"

func get(other_id):
	var r
	if not state.has(other_id):
		state[other_id] = {"x":0}
		r = {"title":"Example Knight", "content":"This is an example of multi screen dialogue", "responses":["Lets talk about swords", "Lets talk about armor", "Close"]}
	else:
		var content = ""
		var responses = ["Any other tips?", "Lets talk about something else", "Close"]
		if (state[other_id]["x"] == 0):
			content = "Sure, what about?"
			responses = ["Lets talk about swords", "Lets talk about armor", "Close"]
		else: if (state[other_id]["branch"] == "Lets talk about swords"):
			if (state[other_id]["x"] == 1):
				content = "Bigger swords have bigger damage, but don't underestimate the techniques that are possible with a smaller blade and a free hand."
			if (state[other_id]["x"] == 2):
				content = "Spears are basically swords on sticks, and arrows are basically small spears. Bows are bullshit is what I'm saying."
			if (state[other_id]["x"] >= 3):
				content = "Nothing more here friend."
				responses = ["Lets talk about something else", "Close"]
		else: if (state[other_id]["branch"] == "Lets talk about armor"):
			if (state[other_id]["x"] == 1):
				content = "The armor I have is quite heavy, but you don't have to get out of the way if they can't hurt you."
			if (state[other_id]["x"] == 2):
				content = "This armor is also very hot inside so I am basically dying right now."
			if (state[other_id]["x"] >= 3):
				content = "Egh. No."
				responses = ["Lets talk about something else", "Close"]
		r = {"title":"Example Knight", "content":content, "responses":responses}
	return r

func respond_get(other_id, response):
	if (state[other_id]["x"] == 0):
		state[other_id]["branch"] = response
	if (response == "Lets talk about something else"):
		state[other_id]["x"] = -1
	if (response != "Close"):
		state[other_id]["x"] += 1
		return get(other_id)