tool
extends "res://addons/godungeon/GodungeonSpatialTileTemplate.gd"

export(Resource) var sand_tile: Resource

func get_collision(am: AdjacencyMap) -> Array:
    return [
        [$CollisionShape, $CollisionShape.transform]   
    ]

func get_meshes(am: AdjacencyMap) -> Array:
    var meshes = [
        [$wall.mesh, $wall.transform]
    ]
    
    if am.E == sand_tile and am.S == sand_tile:
        meshes.push_back([$outter_corner.mesh, $outter_corner.transform])
        return meshes
        
    if am.W == sand_tile and am.S == sand_tile:
        meshes.push_back([$outter_corner.mesh, $outter_corner.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))])
        return meshes
        
    if am.W == sand_tile and am.N == sand_tile:
        meshes.push_back([$outter_corner.mesh, $outter_corner.transform.rotated(Vector3(0, 1, 0), deg2rad(180))])
        return meshes
        
    if am.E == sand_tile and am.N == sand_tile:
        meshes.push_back([$outter_corner.mesh, $outter_corner.transform.rotated(Vector3(0, 1, 0), deg2rad(90))])
        return meshes

    if am.N == sand_tile:
        meshes.push_back([$outter_top.mesh, $outter_top.transform.rotated(Vector3(0, 1, 0), deg2rad(180))])
        return meshes
        
    if am.E == sand_tile:
        meshes.push_back([$outter_top.mesh, $outter_top.transform.rotated(Vector3(0, 1, 0), deg2rad(90))])
        return meshes
        
    if am.S == sand_tile:
        meshes.push_back([$outter_top.mesh, $outter_top.transform])
        return meshes
            
    if am.W == sand_tile:
        meshes.push_back([$outter_top.mesh, $outter_top.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))])
        return meshes
        
    meshes.push_back([$ceiling.mesh, $ceiling.transform])
        
    return meshes
