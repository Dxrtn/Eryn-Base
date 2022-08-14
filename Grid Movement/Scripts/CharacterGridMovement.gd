extends KinematicBody2D

export var move_speed = 64 # in pixel per seconds
var path : PoolVector2Array = []
var navigator : Navigation2D = null
var map : TileMap = null
var _dir := Vector2()
var _end_position := Vector2()
var _tile_size : int 
var _movement_delay : float 

func set_navigator(node : Navigation2D):
	navigator = node
	map = navigator.get_child(0)
	_tile_size = map.tile_set.autotile_get_size(0)[0]
	_movement_delay = _tile_size / float(move_speed)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.is_action("ui_right"):
				find_path(global_position + Vector2.RIGHT * _tile_size)
			elif event.is_action("ui_left"):
				find_path(global_position + Vector2.LEFT * _tile_size)
			elif event.is_action("ui_down"):
				find_path(global_position + Vector2.DOWN * _tile_size)
			elif event.is_action("ui_up"):
				find_path(global_position + Vector2.UP * _tile_size)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			var pos = get_global_mouse_position()
			find_path(pos)

func _process(delta):
	if path.size() > 0:
		_dir = path[0] - global_position
		if abs(_dir.x) >= abs(_dir.y):
			_dir.y = 0
		else:
			_dir.x = 0
		_dir = _dir.normalized()
		_dir = move(_dir * _tile_size, _movement_delay)
		if global_position == path[0]:
			path.remove(0)
	animate(_dir)

func move(distance : Vector2, time : float):
	if not $MovementTween.is_active():
		$MovementTween.interpolate_property(
			self, "global_position",
			global_position, global_position + distance, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$MovementTween.start()
		_end_position = global_position + distance
		return distance.normalized()
	return Vector2.ZERO

func find_path(end_route : Vector2):
	if $MovementTween.is_active():
		path = [ _end_position ]
	path += navigator.get_simple_path(global_position, map.world_to_map(end_route) * 32, true)
	get_parent().get_node("Line2D").points = path

func animate(dir : Vector2):
	$AnimationTree['parameters/conditions/walk'] = $MovementTween.is_active()
	$AnimationTree['parameters/conditions/notWalk'] = not $MovementTween.is_active()
	if dir != Vector2.ZERO:
		$AnimationTree['parameters/IDLE/blend_position'] = dir
		$AnimationTree['parameters/WALK/blend_position'] = dir
