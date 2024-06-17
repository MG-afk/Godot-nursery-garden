extends Node2D

@export var sadzonka: PackedScene
@export var goldText: RichTextLabel
@export var seedButton: Button
@export var axeButton: Button

enum Tool { NONE, SEED, AXE }

var tool: Tool = Tool.NONE
var nursery_garden_system: NurseryGardenSystem = NurseryGardenSystem.new()
var resources_manager: ResourcesManager = ResourcesManager.new()

func _ready():
	update_gold_text()
	seedButton.pressed.connect(self._seed_pressed)
	axeButton.pressed.connect(self._axe_pressed)
	
	seedButton.	add_to_group("ui")
	axeButton.	add_to_group("ui")
	
	nursery_garden_system.initialize(resources_manager)
	resources_manager.goldChanged.connect(update_gold_text)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var new_position = get_global_mouse_position()
		var clicked_control = find_control_under_mouse(new_position)
		if clicked_control:
			return
			
		if Input.is_action_pressed("left_button"):
				match tool:
					Tool.AXE:
						var clicked_tree = nursery_garden_system.find_clicked_tree(self, new_position)
						if clicked_tree:
							clicked_tree.cut_down_tree(resources_manager)
					Tool.SEED:
						if(resources_manager.try_spend_gold(1)):
							nursery_garden_system.try_to_place_tree(self, new_position)

func find_control_under_mouse(position):
	var ui_nodes = get_tree().get_nodes_in_group("ui")
	for node in ui_nodes:
		if node is Control:
			if node.get_global_rect().has_point(position):
				return node
	return null

func update_gold_text():
	goldText.text = "{gold}".format({"gold": resources_manager.gold})

func _axe_pressed():
	tool = Tool.AXE

func _seed_pressed():
	tool = Tool.SEED
