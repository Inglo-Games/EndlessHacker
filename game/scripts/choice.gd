extends Node

# Return an integer i in [0, len(probs)-1] with probability equal to probs[i]
static func pick_int(probs:Array):
	
	var rand := randf()
	var prob_accumulate := 0.0
	for i in range(len(probs)):
		prob_accumulate += probs[i]
		if(rand <= prob_accumulate):
			return i
