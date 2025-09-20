class_name mortar

extends Enemy


# state are:
# 0 -> to load
# 1 -> aiming
# 2 -> shoot
var state = 0

func do_action(target):
	
	if state == 0:
		pass
	elif state == 1:
		pass
	elif state == 2:

		return

	state+=1 
	state = state %3
