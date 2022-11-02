extends Camera3D

var planet : Node 
var paintMode : bool = false

func _ready():
	planet = get_parent() 

func _process(delta):
	if Input.is_action_just_released("wheel_up"):
		position += Vector3(0,-1,0) * delta * 40 
	if Input.is_action_just_released("wheel_down"):
		position += Vector3(0,1,0) * delta * 40 
	
	if Input.is_action_pressed("input_left"):
		position += Vector3(0,0,1) * delta * 40 
	if Input.is_action_pressed("input_right"):
		position += Vector3(0,0,-1) * delta * 40 
	if Input.is_action_pressed("input_up"):
		position += Vector3(-1,0,0) * delta * 40 
	if Input.is_action_pressed("input_down"):
		position += Vector3(1,0,0) * delta * 40 
		
	if Input.is_action_just_released("left_click"):
		var result = handleRaycast()
		
	if Input.is_action_just_released("right_click"):
		var result = handleRaycast()

func handleRaycast():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = self.project_ray_origin(mouse_pos)
	var ray_to = ray_from + self.project_ray_normal(mouse_pos) * 1000
	var help = PhysicsRayQueryParameters3D.new()
	help.from = ray_from
	help.to = ray_to
	
	return space_state.intersect_ray(help)
