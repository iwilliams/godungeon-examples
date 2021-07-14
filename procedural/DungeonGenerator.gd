tool
extends Node

const WALL_TILE = preload("res://tiles/terrain/wall/wall_tile.tres")
const DIRT_TILE = preload("res://tiles/terrain/dirt/dirt_tile.tres")
const SAND_TILE = preload("res://tiles/terrain/sand/sand_tile.tres")
const WATER_TILE = preload("res://tiles/terrain/water/water_tile.tres")
const BRIDGE_TILE = preload("res://tiles/terrain/bridge/bridge_tile.tres")

export(bool) var editor_generate = false setget _set_editor_generate
func _set_editor_generate(value: bool):
    if editor_generate != value:
        generate()
    editor_generate = value


export(Resource) var terrain_tiles

export(int) var max_rooms = 10
export(int) var generator_seed = 0
export(int) var island_x_space = 5
export(int) var island_y_space = 10

        
class Cave extends GodungeonTiles:
    var rooms = []
    
    func _init():
        rooms = []
        return ._init()
        
        
    func offset(offset_amount) -> Vector2:
        var result = .offset(offset_amount)
        var new_rooms = []
        for room in rooms:
            new_rooms.push_back(Rect2(room.position + offset_amount, room.size))
        rooms = new_rooms
        return result
        
        
    func get_rooms_rect():
        if rooms.size() == 0:
            return null
            
        var rect := Rect2(rooms[0].position, rooms[0].size)
        for room in rooms:
            rect = rect.merge(room)
        
        return rect


func _get_rect_index(rect: Rect2, coord: Vector2):
    var index_coord = coord + (rect.position * -1)
    var index = (index_coord.y * rect.size.x) + index_coord.x
    return index


func generate():
    if generator_seed != 0:
        print("Using seed %d" % generator_seed)
        seed(generator_seed)
    else:
        randomize()

    print("Generate")
    
    if not is_instance_valid(terrain_tiles):
        return
        
    print("generating...")
    terrain_tiles.lock()
    terrain_tiles.clear_tiles()
    
    var rooms_1: Cave = _make_rooms()
    var rooms_2: Cave = _make_rooms()
    
    # Make sand
    var sand_radius = 0
    
    for room in rooms_1.rooms:
        rooms_1.fill_tiles_in_circle(room.position + (room.size * .5).floor(), max(room.size.x, room.size.y) + sand_radius, SAND_TILE, [null])
                
    for room in rooms_2.rooms:
        rooms_2.fill_tiles_in_circle(room.position + (room.size * .5).floor(), max(room.size.x, room.size.y) + sand_radius, SAND_TILE, [null])
        
    rooms_1.center()
    rooms_2.center()

    var h_space = island_x_space
    var v_space = island_y_space
    
    rooms_1.offset(Vector2((rooms_1.get_rect().size.x * -.5) - h_space, -v_space).round())
    terrain_tiles.copy_from(rooms_1)
    
    rooms_2.offset(Vector2((rooms_2.get_rect().size.x * .5) + h_space, v_space).round())
    terrain_tiles.copy_from(rooms_2)
    
    var center_offset = terrain_tiles.center()
    rooms_1.offset(center_offset)
    rooms_2.offset(center_offset)
    
    terrain_tiles.fill_tiles_in_rect(terrain_tiles.get_rect().grow(10), WATER_TILE, [null])
    
    var rooms_1_rect = rooms_1.get_rooms_rect()
    var rooms_1_center = rooms_1_rect.position + (rooms_1_rect.size * .5).floor()
    
    var rooms_2_rect = rooms_2.get_rooms_rect()
    var rooms_2_center = rooms_2_rect.position + (rooms_2_rect.size * .5).floor()
    
    var bridge_rect := Rect2(rooms_1_center.linear_interpolate(rooms_2_center, .5).round(), Vector2.ONE).expand(rooms_2_center).expand(rooms_1_center).grow(5)
    var bridge_tiles = terrain_tiles.get_tiles_in_rect(bridge_rect)

    var a_star := AStar2D.new()

    for coord in bridge_tiles.get_used_coords():
        a_star.add_point(_get_rect_index(bridge_rect, coord), coord)
        
    for coord in bridge_tiles.get_used_coords():
        var am: AdjacencyMap = bridge_tiles.get_adjacency_map(coord)
        var index = _get_rect_index(bridge_rect, coord)
        
        if am.M == WATER_TILE:
            if am.N == SAND_TILE or am.S == SAND_TILE or am.E == SAND_TILE or am.W == SAND_TILE:
                a_star.set_point_weight_scale(index, 100)
            else:
                a_star.set_point_weight_scale(index, lerp(1, 50, randf()))
        elif am.M == SAND_TILE:
            var weight = 1
            for a_type in am.adjacent.values():
                if a_type == WATER_TILE:
                    weight += 100
            a_star.set_point_weight_scale(index, weight)
        
        
        if am.N != null:
            a_star.connect_points(index, _get_rect_index(bridge_rect, am.COORD_N))
        if am.E != null:
            a_star.connect_points(index, _get_rect_index(bridge_rect, am.COORD_E))
        if am.S != null:
            a_star.connect_points(index, _get_rect_index(bridge_rect, am.COORD_S))
        if am.W != null:
            a_star.connect_points(index, _get_rect_index(bridge_rect, am.COORD_W))

    for point in a_star.get_point_path(_get_rect_index(bridge_rect, rooms_1_center), _get_rect_index(bridge_rect, rooms_2_center)):
        if terrain_tiles.get_tile(point) == WATER_TILE:
            terrain_tiles.set_tile(point, BRIDGE_TILE)
            
            
    if randf() > .5:
        if randf() > .5:
            terrain_tiles.rotate_left()
        else:
            terrain_tiles.rotate_right()

    if randf() > .5:
       terrain_tiles.flip_x()
    
    if randf() > .5:
       terrain_tiles.flip_y()
    
    terrain_tiles.unlock()
    
    
func _make_rooms() -> Cave:
    var terrain = Cave.new()
        
    var room_rect := random_rect(Vector2.ZERO, 5, 5, 10, 10)
    terrain.copy_from(make_room(room_rect))

    terrain.rooms = [room_rect]
    var made_rooms = 1
    var rooms_to_make = max_rooms
    while made_rooms < rooms_to_make:
        var possible_passage = find_possible_passage(terrain)
        if possible_passage != null:
            var wall_coord = possible_passage[0]
            var wall_side = possible_passage[1]
            var new_room_rect := random_rect(wall_coord, 5, 5, 10, 10)
            if wall_side == AdjacencyMap.SIDE_N:
                new_room_rect.position.y -= new_room_rect.size.y - 1
                new_room_rect.position.x -= round(lerp(1, new_room_rect.size.x - 3, randf()))
            elif wall_side == AdjacencyMap.SIDE_S:
                new_room_rect.position.x -= round(lerp(1, new_room_rect.size.x - 3, randf()))
            elif wall_side == AdjacencyMap.SIDE_E:
                new_room_rect.position.y -= round(lerp(1, new_room_rect.size.y - 3, randf()))
            elif wall_side == AdjacencyMap.SIDE_W:
                new_room_rect.position.x -= new_room_rect.size.x - 1
                new_room_rect.position.y -= round(lerp(1, new_room_rect.size.y - 3, randf()))
            
            var possible_room_tiles = terrain.get_tiles_in_rect(new_room_rect)
            var can_make_room = true
            for coord in possible_room_tiles.get_used_coords():
                can_make_room = can_make_room and possible_room_tiles.get_tile(coord) == WALL_TILE
            
            if can_make_room:
                terrain.copy_from(make_room(new_room_rect))
                terrain.set_tile(wall_coord, DIRT_TILE)
                made_rooms += 1
                terrain.rooms.push_back(new_room_rect)
    
    # Fill in "center" of dungeon to avoid stranded sand
    terrain.fill_tiles_in_rect(terrain.get_rect(), WATER_TILE, [null])
    var bucket_fill_tmp = terrain.get_rect().grow(1)
    terrain.bucket_fill_tiles(bucket_fill_tmp.position, null, [WATER_TILE, null], bucket_fill_tmp)
    terrain.fill_tiles_in_rect(terrain.get_rect(), WALL_TILE, [WATER_TILE])
    
    return terrain



func find_possible_passage(tiles: GodungeonTiles):
    var all_wall_coords := tiles.get_tile_type_coords(WALL_TILE)
    if all_wall_coords.size() == 0:
        return null
        
    all_wall_coords.shuffle()
        
    var possible_passage = null
    
    while all_wall_coords.size() > 0 and possible_passage == null:
        var random_wall_coord := all_wall_coords.pop_front() as Vector2
        var random_am := tiles.get_adjacency_map(random_wall_coord)
        
        if random_am.side_is_exactly(AdjacencyMap.SIDE_N, null) and random_am.side_is_exactly(AdjacencyMap.SIDE_S, DIRT_TILE):
            possible_passage = [random_wall_coord, AdjacencyMap.SIDE_N]
        elif random_am.side_is_exactly(AdjacencyMap.SIDE_S, null) and random_am.side_is_exactly(AdjacencyMap.SIDE_N, DIRT_TILE):
            possible_passage = [random_wall_coord, AdjacencyMap.SIDE_S]
        elif random_am.side_is_exactly(AdjacencyMap.SIDE_E, null) and random_am.side_is_exactly(AdjacencyMap.SIDE_W, DIRT_TILE):
            possible_passage = [random_wall_coord, AdjacencyMap.SIDE_E]
        elif random_am.side_is_exactly(AdjacencyMap.SIDE_W, null) and random_am.side_is_exactly(AdjacencyMap.SIDE_E, DIRT_TILE):
            possible_passage = [random_wall_coord, AdjacencyMap.SIDE_W]
        
    return possible_passage
        
        
func random_rect(position, min_width, min_height, max_width, max_height) -> Rect2:
    var possible_width = range(min_width, max_width)
    possible_width.shuffle()
    var possible_height = range(min_height, max_height)
    possible_height.shuffle()
    return Rect2(position, Vector2(possible_width.pop_front(), possible_height.pop_front()))


func make_room(room_rect):
    var tiles = GodungeonTiles.new()
    tiles.fill_tiles_in_rect(room_rect, WALL_TILE)
    tiles.fill_tiles_in_rect(room_rect.grow(-1), DIRT_TILE)
    return tiles
