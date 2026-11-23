extends RigidBody3D

@onready var mesh_instance_node = $MeshInstance3D
@export var itemData: Resource

func _ready() -> void:
	name = itemData.ItemName
	spawn_item_with_collision(itemData.meshScene)
func interact():
	if Inventory.add_item(itemData):
		call_deferred("queue_free")
	else:
		print("inventory full")


func find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_first_mesh_instance(child)
		if result:
			return result
	return null
	
func spawn_item_with_collision(scene) -> Node3D:
	var inst = scene.instantiate()
	add_child(inst)

	var mesh_instance = find_first_mesh_instance(inst)
	if mesh_instance and mesh_instance.mesh:
		var col_shape = CollisionShape3D.new()
		col_shape.shape = mesh_instance.mesh.create_convex_shape()
		# match the mesh's offset/rotation inside the item scene
		col_shape.transform = global_transform.affine_inverse() * mesh_instance.global_transform
		add_child(col_shape)
	else:
		push_warning("%s: no MeshInstance3D found in meshScene, no collision created" % name)
	return inst
