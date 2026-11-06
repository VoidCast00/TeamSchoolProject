extends Node

@export var MAZE_SIZE:Vector3i = Vector3i(50,2,50)
@onready var maze: GridMap = $".."
var startingCell:= Vector2i.ZERO
var steps:Array[Vector2i] = []

const SUR_CELLS =[
	Vector2i(0,2),
	Vector2i(2,0),
	Vector2i(-2,0),
	Vector2i(0,-2),
]

func _ready() -> void:
	resetMaze(MAZE_SIZE)
	generateMaze()


func _process(delta: float) -> void:
	pass

func generateMaze() -> void:
	var currentCell = startingCell;
	carve(startingCell)
	steps.append(startingCell)
	
	while (steps.size() > 0):
		var surroundingCells:= getSurroundingCells(currentCell);
		
		if not surroundingCells.size() == 0:
			var nextCell: Vector2i = surroundingCells.pick_random()
			var middle : Vector2i= currentCell + (nextCell - currentCell) / 2

			carve(middle)   
			carve(nextCell)   

			currentCell = nextCell
			steps.append(currentCell)
		else:
			steps.pop_back()
			if steps.size() > 0:
				currentCell = steps.back()
			
		



func getSurroundingCells(cell:Vector2i) -> Array[Vector2i]:
	var arr : Array[Vector2i] = []
	for i in SUR_CELLS:
		var pos :Vector2i = cell + i
		if pos.x < MAZE_SIZE.x*0.5 and pos.y < MAZE_SIZE.z*0.5 and pos.x >= MAZE_SIZE.x*-0.5 and pos.y >= MAZE_SIZE.z*-0.5:
			if maze.get_cell_item(Vector3i(pos.x, 0, pos.y)) != -1 :
				arr.append(cell + i)
	return arr
		 

func resetMaze(size : Vector3i) -> void:
	maze.clear()
	for x in range(-size.x*0.5, size.x*0.5 + 1, 1):
		for z in range(-size.z*0.5, size.z*0.5 + 1, 1):
			for y in range(-1, MAZE_SIZE.y - 1, 1):
				var pos := Vector3i(x,y,z)
				if (pos.y == -1):
					maze.set_cell_item(pos, 1)
				else:
					maze.set_cell_item(pos, 0)
					
					
func carve(cell: Vector2i) -> void:
	for i in range (0, MAZE_SIZE.y, 1):
		maze.set_cell_item(Vector3i(cell.x, i, cell.y), -1)
