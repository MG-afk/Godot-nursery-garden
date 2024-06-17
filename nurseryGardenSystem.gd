class_name NurseryGardenSystem

var babyTree: PackedScene
var min_distance: float = 50.0
var planted_positions: Array[Vector2] = []
var stageOfTree: Array[Texture2D]
var resourcesManager: ResourcesManager

func initialize(resourcesManager: ResourcesManager):
	self.resourcesManager = resourcesManager

	for i in range(1, 4):
		stageOfTree.append(load("res://tree/tree%d.png" % i))
		
	babyTree = load("res://tree/tree.tscn")

func try_to_place_tree(parent: Node2D, new_position: Vector2) -> bool:
	if is_position_too_close(new_position):
		return false
	
	var newTree = babyTree.instantiate()
	newTree.position = new_position
			
	parent.add_child(newTree)
	newTree.init(stageOfTree)
	newTree.start_growth_timer()
	newTree.growed.connect(get_gold_by_growing)
	newTree.cut_down.connect(_cut_tree)
			
	planted_positions.append(new_position)
	return true
	
func _cut_tree(tree: Wood):
	planted_positions.erase(tree.position)
	
func get_gold_by_growing():
	resourcesManager.increase_gold(1)
	
func is_position_too_close(new_position: Vector2) -> bool:
	for pos in planted_positions:
		var distance = pos.distance_to(new_position)
		print("Comparing with: ", pos, " Distance: ", distance)
		if distance < min_distance:
			print("Position too close: ", pos)
			return true
	return false
	
func find_clicked_tree(parent: Node2D, mouse_position: Vector2) -> Node2D:
	for tree in parent.get_tree().get_nodes_in_group("trees"):
		if tree is Node2D and tree.has_method("get_collision_shape"):
			var collision_shape = tree.get_collision_shape()
			if collision_shape and collision_shape.shape:
				var local_mouse_position = tree.to_local(mouse_position)
				if collision_shape.shape.get_rect().has_point(local_mouse_position):
					return tree
	return null
