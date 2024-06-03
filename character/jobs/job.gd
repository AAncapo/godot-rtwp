class_name Job extends Node

var path:Array[Vector3]
var current_index:int = 0


func _init(_path = []):
	path = []
	for point in _path:
		path.append(point.global_position)


func work():
	pass

func get_initial_pos():
	return path[0]

# return the next vector for the actor to move towards
func get_next_pos():
	current_index += 1
	if current_index > path.size() - 1:
		path.reverse()
		current_index = 1
	
	return path[current_index]

# return last position before leaving work or the initial if hasnt started
func get_last_pos():
	if path:
		return path[current_index]
