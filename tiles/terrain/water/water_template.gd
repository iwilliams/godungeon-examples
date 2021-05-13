tool
extends "res://addons/godungeon/GodungeonSpatialTileTemplate.gd"

export(Resource) var sand_tile: Resource

func get_collision(am: AdjacencyMap) -> Array:
    var collision = []
    
    if am.N == sand_tile or am.S == sand_tile or am.W == sand_tile or am.E == sand_tile:
        collision.push_back([$flat_collision, $flat_collision.transform])
        return collision
        
    if am.NW == sand_tile:
        collision.push_back([$corner_floor_collision, $corner_floor_collision.transform])
        return collision
        
    if am.NE == sand_tile:
        collision.push_back([$corner_floor_collision, $corner_floor_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))])
        return collision
        
    if am.SE == sand_tile:
        collision.push_back([$corner_floor_collision, $corner_floor_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-180))])
        return collision
        
    if am.SW == sand_tile:
        collision.push_back([$corner_floor_collision, $corner_floor_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(90))])
        return collision
    
    return collision

func get_meshes(am: AdjacencyMap) -> Array:
    var meshes = [
        [$MeshInstance.mesh, $MeshInstance.transform]
    ]
    
    if am.N == sand_tile or am.S == sand_tile or am.W == sand_tile or am.E == sand_tile:
        meshes.push_back([$MeshInstance2.mesh, $MeshInstance2.transform])
        return meshes
        
    if am.NW == sand_tile:
        meshes.push_back([$corner_floor.mesh, $corner_floor.transform])
        return meshes
        
    if am.NE == sand_tile:
        meshes.push_back([$corner_floor.mesh, $corner_floor.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))])
        return meshes
        
    if am.SE == sand_tile:
        meshes.push_back([$corner_floor.mesh, $corner_floor.transform.rotated(Vector3(0, 1, 0), deg2rad(-180))])
        return meshes
        
    if am.SW == sand_tile:
        meshes.push_back([$corner_floor.mesh, $corner_floor.transform.rotated(Vector3(0, 1, 0), deg2rad(90))])
        return meshes
    
    return meshes
