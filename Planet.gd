@tool
extends Node3D

var surfaceTool : SurfaceTool = SurfaceTool.new() 

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var waterMesh: MeshInstance3D = $Water
@onready var treeMultiMesh: MultiMeshInstance3D = $TreeMultiMesh
@onready var gridMap: GridMap = $GridMap
@onready var camera : Camera3D = $Camera3D
@onready var collisionShape: CollisionShape3D = $CollisionShape3D

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var size: int = 20
@export var rimSize: int = 4 
@export var generate: bool = false :
	set(value):
		generate_terrain_gridmap(size)
		generate = value
@export var clean: bool = false :
	set(value):
		cleanUp()
		clean = value

func _ready():
	camera.position = Vector3(size/2, camera.position.y, size/2)
	generate_terrain_gridmap(size)

func cleanUp():
	gridMap.clear()
	waterMesh.mesh = null
	treeMultiMesh.multimesh.instance_count = 0
	
func generate_terrain_gridmap(size: int):
	gridMap.clear()
	self.position = Vector3(self.position.x, self.position.y, -size/2)
	treeMultiMesh.multimesh.instance_count = 2000
	
	var waterBox = BoxMesh.new()
	waterBox.size = Vector3(size+1, 3, size+1)
	waterMesh.mesh = waterBox
	waterMesh.position = Vector3(size/2, 1, size/2)
	var i = 0
	var noSpawn = true
	
	for y in range(size):
		for x in range(size):
			var vector = Vector3(x, 0, y)
			var eval = self.evaluate(vector)
			
			if y <= rimSize-1 || x <= rimSize-1 || y >= size-rimSize || x >= size-rimSize :
				eval = 1
				self.gridMap.set_cell_item(vector + Vector3.UP, -1)
				self.gridMap.set_cell_item(vector + 2 * Vector3.UP, -1)
				self.gridMap.set_cell_item(vector + 3 * Vector3.UP, -1)
			
			vector.y = eval

			if treeMultiMesh:
				if i < treeMultiMesh.multimesh.instance_count && eval == 2 && noise.get_noise_3dv(vector) > 0.15:
					treeMultiMesh.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, 
						vector + Vector3.RIGHT/2  + Vector3.BACK/2+ Vector3.UP))
					i = i+1
					
			self.gridMap.set_cell_item(vector, eval)
	
	if treeMultiMesh:
		treeMultiMesh.multimesh.visible_instance_count = i
	
func evaluate(positon: Vector3) -> float:
	var eval : float = noise.get_noise_2d(positon.x, positon.z)
	var disceteEval : float = 1
	
	if eval >= 0.4:
		disceteEval = 4
	elif eval >= 0.25:
		disceteEval = 3
	elif eval >= 0.0:
		disceteEval = 2
	elif eval <= -0.2:
		disceteEval = 0
	
	return disceteEval
