extends Node2D

@export var sadzonka: PackedScene
@export var goldText: RichTextLabel
@export var seedButton: Button
@export var axeButton: Button
@export var stageOfTree: Array[Texture2D]
@export var min_distance: float = 50.0

signal goldCollected
var gold = 10
var planted_positions: Array[Vector2] = []
enum Tool { NONE, SEED, AXE }

var tool: Tool = Tool.NONE

func _ready():
	goldText.text = "Gold: {gold}".format({"gold": gold})
	seedButton.pressed.connect(self._seed_pressed)
	axeButton.pressed.connect(self._axe_pressed)
	
	seedButton.	add_to_group("ui")
	axeButton.	add_to_group("ui")
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var new_position = get_global_mouse_position()
		var clicked_control = find_control_under_mouse(new_position)
		if clicked_control:
			return
			
		if Input.is_action_pressed("left_button"):
				match tool:
					Tool.AXE:
						var clicked_tree = find_clicked_tree(new_position)
						if clicked_tree:
							clicked_tree.cut_down_tree()
					Tool.SEED:
						try_to_place_tree(new_position)

func find_control_under_mouse(position):
	var ui_nodes = get_tree().get_nodes_in_group("ui")
	for node in ui_nodes:
		if node is Control:
			if node.get_global_rect().has_point(position):
				return node
	return null

func increase_gold():
	gold += 1
	goldText.text = "Gold: {gold}".format({"gold": gold})
	print("Gold: ", gold)
	goldCollected.emit()

func is_position_too_close(new_position: Vector2) -> bool:
	for pos in planted_positions:
		var distance = pos.distance_to(new_position)
		print("Comparing with: ", pos, " Distance: ", distance)
		if distance < min_distance:
			print("Position too close: ", pos)
			return true
	return false

func try_to_place_tree(new_position: Vector2) -> bool:
	if is_position_too_close(new_position):
		return false
	
	var newSeed = sadzonka.instantiate()
	newSeed.position = new_position
			
	add_child(newSeed)
	newSeed.init(stageOfTree)
	newSeed.start_growth_timer()
	newSeed.growed.connect(increase_gold)
			
	planted_positions.append(new_position)
	return true

func find_clicked_tree(mouse_position: Vector2) -> Node2D:
	for tree in get_tree().get_nodes_in_group("trees"):
		if tree is Node2D and tree.has_method("get_collision_shape"):
			var collision_shape = tree.get_collision_shape()
			if collision_shape and collision_shape.shape:
				var local_mouse_position = tree.to_local(mouse_position)
				if collision_shape.shape.get_rect().has_point(local_mouse_position):
					return tree
	return null

func _axe_pressed():
	tool = Tool.AXE

func _seed_pressed():
	tool = Tool.SEED
