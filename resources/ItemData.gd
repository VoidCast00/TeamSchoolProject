extends Resource
class_name ItemData

@export var ItemName: String
@export var icon: Texture2D
@export var meshScene: PackedScene
@export var interactable_scene: PackedScene = preload("res://interactables.tscn")
@export var scale: float
