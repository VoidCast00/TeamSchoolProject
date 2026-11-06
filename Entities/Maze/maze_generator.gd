extends Node

@export var MAZE_SIZE:Vector3i = Vector3i(100,100,2)
@onready var maze: GridMap = $".."
var startingCell: Vector2i ;
var lastSteps:Array[Vector2i] = []

const SUR_CELLS =[
	Vector2i(0,1),
	Vector2i(1,0),
	Vector2i(-1,0),
	Vector2i(0,11),
]

func _ready() -> void:
	
	resetMaze(MAZE_SIZE)


func _process(delta: float) -> void:
	pass

func generateMaze() -> void:
	resetMaze(MAZE_SIZE)
	var currentCell = startingCell;
	while (true):
		var nCells:= getSurroundingCells(currentCell);
		


func getSurroundingCells(cell:Vector2i) -> Array[Vector2i]:
	var arr : Array[Vector2i] = []
	for i in SUR_CELLS:
		var pos :Vector2i = cell + i
		if maze.get_cell_item(Vector3i(pos.x, 0, pos.y)) != -1:
			arr.append(cell + i)
	return arr
		 

func resetMaze(size : Vector3i) -> void:
	maze.clear()
	for x in range(size.x):
		for z in range(size.y):
			for y in range(-1, MAZE_SIZE.y - 1, 1):
				var pos := Vector3i(x,y,z)
				maze.set_cell_item(pos, 0)
			
