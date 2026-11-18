extends Node

@export var MAZE_SIZE: Vector3i = Vector3i(100, 10, 100)
@export var WALL_HEIGHT: int = 3
@onready var maze: GridMap = $".."
var startingCell := Vector2i.ZERO
var steps: Array[Vector2i] = []
var TILES_PER_DOOR := 6
const WALL_ITEM := 0
const FLOOR_Y := 0

const SUR_CELLS = [
	Vector2i(0, 2),
	Vector2i(2, 0),
	Vector2i(-2, 0),
	Vector2i(0, -2),
]

func _ready() -> void:
	resetMaze(MAZE_SIZE, true)
	MazeRecursiveDivision()


func generateMaze() -> void:
	var currentCell := startingCell
	carve(startingCell)
	steps.append(startingCell)

	while steps.size() > 0:
		var surroundingCells := getSurroundingCells(currentCell)

		if surroundingCells.size() != 0:
			var nextCell: Vector2i = surroundingCells.pick_random()
			var middle: Vector2i = currentCell + (nextCell - currentCell) / 2

			carve(middle)
			carve(nextCell)

			currentCell = nextCell
			steps.append(currentCell)
		else:
			steps.pop_back()
			if steps.size() > 0:
				currentCell = steps.back()


func getSurroundingCells(cell: Vector2i) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	var x_min := int(-MAZE_SIZE.x * 0.5)
	var x_max := int(MAZE_SIZE.x * 0.5)
	var z_min := int(-MAZE_SIZE.z * 0.5)
	var z_max := int(MAZE_SIZE.z * 0.5)
	for i in SUR_CELLS:
		var pos: Vector2i = cell + i
		if pos.x < x_max and pos.y < z_max and pos.x >= x_min and pos.y >= z_min:
			if maze.get_cell_item(Vector3i(pos.x, 0, pos.y)) != -1:
				arr.append(pos)
	return arr


func resetMaze(size: Vector3i, hollow: bool = false) -> void:
	maze.clear()
	var x_min := int(-size.x * 0.5)
	var x_max := int(size.x * 0.5)
	var z_min := int(-size.z * 0.5)
	var z_max := int(size.z * 0.5)
	for x in range(x_min, x_max + 1):
		for z in range(z_min, z_max + 1):
			for y in range(-1, MAZE_SIZE.y - 1):
				var pos := Vector3i(x, y, z)
				if pos.y == -1:
					maze.set_cell_item(pos, 1)
				elif hollow:
					if x == x_min or x == x_max or z == z_min or z == z_max:
						maze.set_cell_item(pos, 0)
				else:
					maze.set_cell_item(pos, 0)


func carve(cell: Vector2i) -> void:
	for i in range(0, MAZE_SIZE.y):
		maze.set_cell_item(Vector3i(cell.x, i, cell.y), -1)


func MazeRecursiveDivision() -> void:
	var maxRoomCount := 400
	var rooms: Array[Rect2i] = []
	var x_min := int(-MAZE_SIZE.x * 0.5) + 1
	var z_min := int(-MAZE_SIZE.z * 0.5) + 1
	var w := MAZE_SIZE.x - 2
	var h := MAZE_SIZE.z - 2
	rooms.append_array(divideRoom(Rect2i(x_min, z_min, w, h)))

	while rooms.size() < maxRoomCount:
		var newRooms: Array[Rect2i] = []
		var deleteRooms: Array[Rect2i] = []
		var dividedAny := false
		for room in rooms:
			if randf() < 0.010 and rooms.size() > 20:
				continue
			var produced := divideRoom(room)
			if produced.is_empty():
				continue
			dividedAny = true
			newRooms.append_array(produced)
			deleteRooms.append(room)
		if not dividedAny:
			break
		for delRoom in deleteRooms:
			rooms.erase(delRoom)
		rooms.append_array(newRooms)


func divideRoom(room: Rect2i) -> Array[Rect2i]:
	var newRooms: Array[Rect2i] = []
	var horizontal: bool

	if room.size.x <= randi_range(1, 5) or room.size.y <= randi_range(1, 5):
		return []

	if room.size.x > room.size.y:
		horizontal = true
	elif room.size.x < room.size.y:
		horizontal = false
	else:
		horizontal = randf() > 0.5

	if horizontal:
		if room.end.x - 2 < room.position.x + 1:
			return []
		var x := random_middle_even(room.position.x + 1, room.end.x - 2)
		var doorsCount: int = max(1, int(room.size.y / TILES_PER_DOOR))
		var doorY: Array[int] = []
		for i in range(doorsCount):
			doorY.append(random_odd(room.position.y, room.end.y - 1))

		for y in range(room.position.y, room.end.y):
			if doorY.has(y):
				continue
			for h_y in range(WALL_HEIGHT):
				maze.set_cell_item(Vector3i(x, FLOOR_Y + h_y, y), WALL_ITEM)
		newRooms.append_array([
			Rect2i(room.position, Vector2i(x - room.position.x, room.size.y)),
			Rect2i(Vector2i(x + 1, room.position.y), Vector2i(room.end.x - x - 1, room.size.y))
		])
	else:
		if room.end.y - 2 < room.position.y + 1:
			return []
		var doorsCount: int = max(1, int(room.size.x / TILES_PER_DOOR))
		var y := random_middle_even(room.position.y + 1, room.end.y - 2)
		var doorX: Array[int] = []
		for i in range(doorsCount):
			doorX.append(random_odd(room.position.x, room.end.x - 1))
		for x in range(room.position.x, room.end.x):
			if doorX.has(x):
				continue
			for h_y in range(WALL_HEIGHT):
				maze.set_cell_item(Vector3i(x, FLOOR_Y + h_y, y), WALL_ITEM)
		newRooms.append_array([
			Rect2i(room.position, Vector2i(room.size.x, y - room.position.y)),
			Rect2i(Vector2i(room.position.x, y + 1), Vector2i(room.size.x, room.end.y - y - 1))
		])
	return newRooms


func random_middle_even(a: int, b: int, strength: int = 2) -> int:
	var lo := ceili(a / 2.0)
	var hi := floori(b / 2.0)
	if lo > hi:
		lo = hi
	var total := 0
	for i in strength:
		total += randi_range(lo, hi)
	return 2 * roundi(float(total) / strength)


func random_odd(a: int, b: int) -> int:
	var lo := ceili((a - 1) / 2.0)
	var hi := floori((b - 1) / 2.0)
	if lo > hi:
		lo = hi
	return 2 * randi_range(lo, hi) + 1
