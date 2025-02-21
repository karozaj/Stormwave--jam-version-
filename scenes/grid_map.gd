extends GridMap

var parent_nav_region:NavigationRegion3D
var highlighted_block_coordinate:Vector3i

func _ready() -> void:
	if self.get_parent() is NavigationRegion3D:
		parent_nav_region=self.get_parent()
	
func destroy_block(world_coordinate)->bool:
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item(map_coordinate)==2 or get_cell_item(map_coordinate)==3:
		set_cell_item(map_coordinate,-1)
		update_navmesh()
		return true
	return false
	
func place_block(world_coordinate):
	var map_coordinate=local_to_map(world_coordinate)
	if get_cell_item_orientation(map_coordinate)==-1:
		print("place")
		print(map_coordinate)
		set_cell_item(map_coordinate,3)
		update_navmesh()

func highlight(world_coordinate):
	var map_coordinate=local_to_map(world_coordinate)
	
	if highlighted_block_coordinate!=null and map_coordinate!=highlighted_block_coordinate:
		if get_cell_item(highlighted_block_coordinate)==1:
			set_cell_item(highlighted_block_coordinate, 0)
		elif get_cell_item(highlighted_block_coordinate)==2:
			set_cell_item(highlighted_block_coordinate,3)
			
	if get_cell_item(map_coordinate)==0:
		set_cell_item(map_coordinate, 1)
	elif get_cell_item(map_coordinate)==3:
		set_cell_item(map_coordinate,2)
	
	highlighted_block_coordinate=map_coordinate

func reset_block_highlight():
	var cells=get_used_cells()
	for cell_coordinate in cells:
		if get_cell_item(cell_coordinate)==1:
			set_cell_item(cell_coordinate, 0)
		elif get_cell_item(cell_coordinate)==2:
			set_cell_item(cell_coordinate,3)

func update_navmesh():
	$Timer.start()


func _on_timer_timeout() -> void:
	if parent_nav_region.is_baking()==false:
		parent_nav_region.bake_navigation_mesh()
