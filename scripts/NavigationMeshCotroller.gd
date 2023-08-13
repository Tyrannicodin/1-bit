extends NavigationRegion3D


func rebake():
	# Rebakes the navigation mesh, we'll use this after an object moves
	bake_navigation_mesh()
