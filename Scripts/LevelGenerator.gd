class_name LevelGen
extends Node

enum POINT_TYPE {
	WALL,
	WALKABLE,
	OCCUPIED,
	OCCUPIED_NO_MODEL,
	START,
	END,
}

@export var mazeWidth = 10
@export var mazeHeight = 10
@export var steediumSpawnRatio = 0.00625
@export var levelGenNode: Node3D

var thing = preload("res://Scenes/LevelGen/Structures/thing.tscn")
var borderModel = preload("res://Scenes/LevelGen/Structures/Border.tscn")
var floorModel = preload("res://Scenes/LevelGen/Structures/Floor.tscn")
var shopModel = preload("res://Scenes/LevelGen/Structures/Shop.tscn")
var boardModel = preload("res://Scenes/LevelGen/Structures/Board.tscn")
var fenceModel = preload("res://Scenes/LevelGen/Structures/Fence.tscn")
var pedestalModel = preload("res://Scenes/LevelGen/Structures/Pedestal.tscn")
var playerScene = preload("res://Scenes/LevelGen/Player.tscn")
var steediumScene = preload("res://Scenes/LevelGen/Steedium.tscn")
var steediumLimit = 0
var startMat = StandardMaterial3D.new()
var endMat = StandardMaterial3D.new()
var generatedMaze = false
var mazeData: Dictionary
var border_count = 0
var count_steps = false
var step_count = 0


func _ready() -> void:
	Global.currentLevelGen = self

	mazeWidth = SaveData.getGameSetting("maze", "width")
	mazeHeight = SaveData.getGameSetting("maze", "height")
	steediumSpawnRatio = SaveData.getGameSetting("maze", "steedium_spawn_ratio")

	randomize()

	steediumLimit = (mazeWidth * mazeHeight) * steediumSpawnRatio
	Global.currentMazeSize = Vector2(mazeWidth, mazeHeight)

	if mazeWidth % 2 == 0:
		mazeWidth -= 1
	if mazeHeight % 2 == 0:
		mazeHeight -= 1

	startMat.albedo_color = Color.AQUA
	endMat.albedo_color = Color.LIGHT_PINK

	createBounds()


func _process(delta: float) -> void:
	if !generatedMaze:
		count_steps = true
		generateMaze()
		Global.currentMazeData = mazeData
		generatedMaze = true
	if Global.currentPlayer != null:
		Global.get_node("GameUI/Control/Debug").text = "player pos = " + str(floor(Global.currentPlayer.position))
		if Global.currentHorse != null:
			Global.get_node("GameUI/Control/Debug").text += "\nhorse pos = " + str(floor(Global.currentHorse.position))


func isInBounds(pos: Vector2) -> bool:
	return pos.x > -1 and pos.y > -1 and pos.x < mazeWidth and pos.y < mazeHeight


func getPointMiddle(pos: Vector2):
	return Vector3(pos.x + 0.5, 0.0, pos.y + 0.5)


func setPointAt(pos: Vector3, pointType: POINT_TYPE):
	var node
	var node2 = levelGenNode.get_node("NavReg/Everything")

	if (pointType != POINT_TYPE.OCCUPIED_NO_MODEL):
		if (pointType == POINT_TYPE.WALL):
			node = borderModel.instantiate()
			node2 = levelGenNode.get_node("Walls")
		elif (pointType == POINT_TYPE.WALKABLE) or (pointType == POINT_TYPE.OCCUPIED):
			node = floorModel.instantiate()
		else:
			node = thing.instantiate()
			var mesh = node.get_node_or_null("Mesh") as CSGMesh3D
			if mesh:
				mesh.material = startMat if pointType == POINT_TYPE.START else endMat

		node.position = pos
		node2.add_child(node)

	if !mazeData.has(Vector2(pos.x, pos.z)) and count_steps:
		step_count += 1
	mazeData[Vector2(pos.x, pos.z)] = {
		"node": node,
		"type": pointType,
		"hasSteedium": false,
	}


func removePointAt(pos: Vector2):
	if mazeData.has(pos):
		if (mazeData[pos])["node"]:
			(mazeData[pos])["node"].queue_free()
		mazeData.erase(pos)
		if count_steps:
			step_count -= 1
	else:
		print("tried to delete non-existent tile")


func replacePointWith(pos: Vector2, pointType: POINT_TYPE):
	removePointAt(pos)
	setPointAt(Vector3(pos.x, 0, pos.y), pointType)


func createBounds():
	for x in range(mazeWidth + 2):
		setPointAt(Vector3(x - 1, 0, -1), POINT_TYPE.WALL)
		setPointAt(Vector3(x - 1, 0, mazeHeight), POINT_TYPE.WALL)
	for z in range(mazeHeight + 2):
		setPointAt(Vector3(-1, 0, z - 1), POINT_TYPE.WALL)
		setPointAt(Vector3(mazeWidth, 0, z - 1), POINT_TYPE.WALL)


func findNearestWalkablePos(from_pos: Vector2) -> Vector2:
	var visited := { }
	var queue = [from_pos]

	while queue.size() > 0:
		var current = queue.pop_front()

		if visited.has(current):
			continue
		visited[current] = true

		if mazeData.has(current):
			var pointType = mazeData[current].type
			if pointType == POINT_TYPE.WALKABLE or pointType == POINT_TYPE.START or pointType == POINT_TYPE.END:
				return current

		for offset in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var neighbor = current + offset
			if isInBounds(neighbor) and !visited.has(neighbor):
				queue.append(neighbor)

	return from_pos


func checkFreeSpaces(pos: Vector2):
	var freeSpaces = []

	if !mazeData.has(Vector2(pos.x + 1, pos.y)):
		freeSpaces.append(Vector2(pos.x + 1, pos.y))
	if !mazeData.has(Vector2(pos.x - 1, pos.y)):
		freeSpaces.append(Vector2(pos.x - 1, pos.y))
	if !mazeData.has(Vector2(pos.x, pos.y + 1)):
		freeSpaces.append(Vector2(pos.x, pos.y + 1))
	if !mazeData.has(Vector2(pos.x, pos.y - 1)):
		freeSpaces.append(Vector2(pos.x, pos.y - 1))

	return freeSpaces


func placeSteedium():
	var steediumCount = 0

	for i in range(2):
		for x in range(mazeWidth):
			for y in range(mazeHeight):
				var pos = Vector2(x, y)
				var rand = randi_range(0, 45)

				if rand == 45:
					if mazeData.has(pos):
						if mazeData[pos].type == POINT_TYPE.WALL or mazeData[pos].type == POINT_TYPE.OCCUPIED or mazeData[pos].type == POINT_TYPE.OCCUPIED_NO_MODEL:
							continue
						if !mazeData[pos].hasSteedium:
							mazeData[pos].hasSteedium = true
						else:
							break

						var steedium = steediumScene.instantiate()
						steedium.position = Vector3(pos.x + 0.5, 6.0, pos.y + 0.5)
						levelGenNode.get_node("Steedium").add_child(steedium)

						steediumCount += 1
		if steediumCount >= steediumLimit:
			break


func generateMaze():
	var stack = []
	var start = Vector2(0, 0)
	stack.push_back(start)

	setPointAt(Vector3(start.x, 0, start.y), POINT_TYPE.START)
	var end = Vector2(mazeWidth - 1, mazeHeight - 1)

	while stack.size() > 0:
		var current = stack[-1]
		var neighbors = []

		for offset in [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2)]:
			var next = current + offset
			if isInBounds(next) and !mazeData.has(next):
				var between = current + offset / 2
				if !mazeData.has(between):
					neighbors.append({ "next": next, "between": between })

		if neighbors.size() > 0:
			var chosen = neighbors[randi() % neighbors.size()]
			var next_pos = chosen["next"]
			var between_pos = chosen["between"]

			setPointAt(Vector3(between_pos.x, 0, between_pos.y), POINT_TYPE.WALKABLE)
			setPointAt(Vector3(next_pos.x, 0, next_pos.y), POINT_TYPE.WALKABLE)

			stack.push_back(next_pos)
		else:
			stack.pop_back()

	for x in range(mazeWidth):
		for y in range(mazeHeight):
			var pos = Vector2(x, y)

			var rand = randi_range(0, 2)
			var rand_diamons = randi_range(0, 20)
			if rand == 2:
				if mazeData.has(pos):
					removePointAt(pos)
				setPointAt(Vector3(x, 0, y), POINT_TYPE.WALKABLE)
			if !mazeData.has(pos):
				setPointAt(Vector3(pos.x, 0, pos.y), POINT_TYPE.WALL)

	replacePointWith(Vector2(0, 1), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(1, 0), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(1, 1), POINT_TYPE.WALKABLE)

	replacePointWith(Vector2(0, end.y - 1), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(0, end.y - 2), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(end.x - 1, 0), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(end.x - 2, 0), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(end.x - 1, end.y - 1), POINT_TYPE.WALKABLE)
	replacePointWith(Vector2(end.x - 2, end.y - 2), POINT_TYPE.WALKABLE)

	replacePointWith(Vector2(start.x, start.y), POINT_TYPE.START)

	if mazeData.has(end):
		removePointAt(end)

	var startPosX = int(mazeWidth / 2) - 2
	var startPosY = int(mazeHeight / 2) - 2

	for x in range(startPosX, startPosX + 4):
		for y in range(startPosY, startPosY + 4):
			replacePointWith(Vector2(x, y), POINT_TYPE.OCCUPIED)

	var shop = shopModel.instantiate() as Node3D

	var center = Vector2(startPosX + 2, startPosY + 2)
	shop.position = getPointMiddle(center)
	shop.position.y += 0.1

	levelGenNode.get_node("NavReg/Valuable").add_child(shop)

	var _valuableItemCount = 0
	if SaveData.getGameSetting("items", "valuable_amount") != 0:
		for i in range(100):
			var pos = Vector2(randi_range(0, mazeWidth), randi_range(0, mazeHeight))
			if mazeData.has(pos):
				if mazeData[pos].type == POINT_TYPE.WALL or mazeData[pos].type == POINT_TYPE.OCCUPIED or mazeData[pos].type == POINT_TYPE.OCCUPIED_NO_MODEL:
					continue
				else:
					setPointAt(Vector3(pos.x, 0.0, pos.y), POINT_TYPE.OCCUPIED_NO_MODEL)
					var pedestal = pedestalModel.instantiate()
					print(pos)
					pedestal.position = Vector3(pos.x, 0.0, pos.y)
					pedestal.name = "Pedestal" + str(_valuableItemCount)
					levelGenNode.get_node("NavReg/Valuable").add_child(pedestal)

					pedestal._changeHorseItem(_valuableItemCount)
					_valuableItemCount += 1
					if _valuableItemCount == SaveData.getGameSetting("items", "valuable_amount"):
						break

	replacePointWith(Vector2(start.x, start.y), POINT_TYPE.OCCUPIED_NO_MODEL)

	replacePointWith(Vector2(end.x, end.y), POINT_TYPE.OCCUPIED_NO_MODEL)
	var board = boardModel.instantiate()
	board.position = Vector3(end.x, 0.0, end.y)
	levelGenNode.get_node("NavReg/Valuable").add_child(board)

	var fence = fenceModel.instantiate()
	fence.position.x = -1.0
	add_child(fence)

	placeSteedium()
	levelGenNode.get_node("NavReg").bake_navigation_mesh()

	var player = playerScene.instantiate() as Node3D
	var pos = getPointMiddle(Vector2(0, 0))
	pos.y = -5.0
	player.position = pos
	add_child(player)
	Global.currentPlayer = player
