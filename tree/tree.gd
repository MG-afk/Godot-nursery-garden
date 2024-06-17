class_name Wood
extends Node2D

var treeIsCut: bool = false
var growth_time = 10.0
var timer = 0.0
var growing = false
var stagesOfTree: Array[Texture2D] = []
var stage = -1

signal growed
signal cut_down(tree: Wood)

func _ready():
	add_to_group("trees")

func init(newStagesOfTree: Array[Texture2D]):
	stagesOfTree = newStagesOfTree
	$Sprite2D.z_index = int(global_position.y) + 1000
	$Slider.value = 0 

func start_growth_timer():
	timer = 0.0
	growing = true
	treeIsCut = false
	$Slider.max_value = growth_time

func _process(delta):
	if growing:
		timer += delta
		$Slider.value = timer
		if timer >= growth_time:
			grow()
			
func grow():
	stage += 1
	if stage < stagesOfTree.size():
		var sprite = $Sprite2D
		sprite.texture = stagesOfTree[stage]
		adjust_size(sprite)
		growth_time *= 1.5
		growed.emit()
		timer = 0.0
		$Slider.value = 0
		$Slider.max_value = growth_time
	else:
		growing = false
		$Slider.queue_free()

func adjust_size(sprite: Sprite2D):
	sprite.position.y = -sprite.texture.get_height() / 2
	get_collision_shape().shape.extents = Vector2(sprite.texture.get_width(), sprite.texture.get_height()) 

func cut_down_tree(resources_manager: ResourcesManager):
	if not treeIsCut:
		remove_from_group("trees")
		treeIsCut = true
		growing = false
		resources_manager.increase_gold(5 * (stage + 1))
		cut_down.emit(self)
		queue_free()
		
func get_collision_shape() -> CollisionShape2D:
	return $"Area2D/CollisionShape2D"

