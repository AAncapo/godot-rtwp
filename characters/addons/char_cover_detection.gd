extends Node3D

func search_cover(target_pos):
	var cover_structs = []
	var bodies = $Area3D.get_overlapping_bodies()
	if !bodies:
		print('no cover struct found')
	else:
		for b in bodies:
			if b.is_in_group('cover'):
				cover_structs.append(b)
		
		if cover_structs:
			print(cover_structs.size(),' cover structures founded')
			var nearest_cover_struct = cover_structs[0]
			for struct in cover_structs:
				if (global_position - struct.global_position).length() < (global_position - nearest_cover_struct.global_position).length():
					nearest_cover_struct = struct
			
			var cover_spots = nearest_cover_struct.get_cover_spots()
			for spot in cover_spots:
				var ray: RayCast3D = spot
				
				ray.exclude_parent = false
				var target_dir = (spot.global_position - target_pos).normalized()
				ray.cast_to = target_dir * -(spot.global_position - target_pos).length()
				
				var collided = ray.get_collider()
				if collided:
					print('cover spot founded')
					return spot.global_position
