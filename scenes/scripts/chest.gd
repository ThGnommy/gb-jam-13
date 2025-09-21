extends AnObject


func die():
	super.die()
	spawn_item()


func spawn_item():
	if (BulletFactory.not_spawned_pickups.size() == 0):
		return

	# Spawn random projectile pickup if not already spawned
	var pickup_type = BulletFactory.not_spawned_pickups[randi() % BulletFactory.not_spawned_pickups.size()]
	var pickup = BulletFactory.create_bullet_pickup(pickup_type)
	pickup.global_position = global_position
	
	# Add it to the scene
	get_tree().get_root().add_child(pickup)
