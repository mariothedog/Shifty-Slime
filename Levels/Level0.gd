extends Node2D

var grass_blade_scene = preload("res://Grass/Grass Blade.tscn")

func _ready():
	for cell in $TileMap.get_used_cells():
		var tile_type = $TileMap.get_cellv(cell)
		if tile_type == 0: # Grass tile
			var pos = $TileMap.map_to_world(cell)
			for i in range(-1, 2):
				var offset = Vector2(32 + 16*i, 8)
				var grass_blade = grass_blade_scene.instance()
				grass_blade.position = pos + offset
				
				var random_scale = rand_range(0.15, 0.5)
				grass_blade.scale.y = random_scale
				
				grass_blade.material = grass_blade.material.duplicate()
				var default_sway_amount = grass_blade.material.get_shader_param("sway_amount")
				grass_blade.material.set_shader_param("sway_amount", default_sway_amount * random_scale * 4)
				
				var default_speed = grass_blade.material.get_shader_param("speed")
				grass_blade.material.set_shader_param("speed", default_speed * random_scale * 2)
				
				if randf() < 0.5:
					grass_blade.material.set_shader_param("dir", -1.0)
				
				grass_blade.material.set_shader_param("colour_multi", rand_range(0.9, 1.1))
				
				$"Grass Blades".add_child(grass_blade)
