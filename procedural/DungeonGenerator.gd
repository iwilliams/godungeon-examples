tool
extends Node

const WALL_TILE = preload("res://tiles/terrain/wall/wall_tile.tres")
const DIRT_TILE = preload("res://tiles/terrain/dirt/dirt_tile.tres")
const SAND_TILE = preload("res://tiles/terrain/sand/sand_tile.tres")
const WATER_TILE = preload("res://tiles/terrain/water/water_tile.tres")

export(bool) var editor_generate = false setget _set_editor_generate
func _set_editor_generate(value: bool):
    if editor_generate != value:
        generate()
    editor_generate = value


export(Resource) var terrain_tiles

export(int) var max_rooms = 10

func generate():
    print("Generate")
    
    if not is_instance_valid(terrain_tiles):
        return
        
    print("generating...")
    
    var terrain = GodungeonTiles.new()
    
    var room_rect := Rect2(Vector2.ZERO, Vector2(5, 5))

    terrain.copy_from(make_room(room_rect))
    var made_rooms = 0
    var rooms_to_make = max_rooms
    while made_rooms < rooms_to_make:
        var possible_passage = find_possible_passage(terrain)
        if possible_passage != null:
            var wall_coord = possible_passage[0]
            var wall_side = possible_passage[1]
            var new_room_rect := random_rect(wall_coord, 5, 5, 10, 10) # Rect2(wall_coord, Vector2(5, 5))
            if wall_side == AdjacencyMap.SIDE_N:
                new_room_rect.position.y -= new_room_rect.size.y - 1
                new_room_rect.position.x -= 1
            elif wall_side == AdjacencyMap.SIDE_S:
                new_room_rect.position.x -= 1
    #            new_room_rect.position.y += 1
                pass
            elif wall_side == AdjacencyMap.SIDE_E:
    #            new_room_rect.position.x += 1
                new_room_rect.position.y -= 1
                pass
            elif wall_side == AdjacencyMap.SIDE_W:
                new_room_rect.position.x -= new_room_rect.size.x - 1
                new_room_rect.position.y -= 1
            
            var possible_room_tiles = terrain.get_tiles_in_rect(new_room_rect)
            var can_make_room = true
            for coord in possible_room_tiles.get_used_coords():
                can_make_room = can_make_room and possible_room_tiles.get_tile(coord) == WALL_TILE
            
            if can_make_room:
                terrain.copy_from(make_room(new_room_rect))
                terrain.set_tile(wall_coord, DIRT_TILE)
                made_rooms += 1
    
    terrain_tiles.clear_tiles()
    terrain_tiles.copy_from(terrain)
    terrain_tiles.center()


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
    print("make room size: ", tiles.tiles.size())
    tiles.fill_tiles_in_rect(room_rect, WALL_TILE)
    tiles.fill_tiles_in_rect(room_rect.grow(-1), DIRT_TILE)
    return tiles
