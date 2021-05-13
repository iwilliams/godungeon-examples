tool
extends "res://addons/godungeon/GodungeonSpatialTileTemplate.gd"

export(Resource) var sand_tile
export(Resource) var bridge_tile
export(Resource) var water_tile

func get_collision(am: AdjacencyMap) -> Array:
    var collision = [
        [$bridge_collision, $bridge_collision.transform],
    ]
    
    for col in $water_template.get_collision(am):
        collision.push_back(col)
    

    if am.N == sand_tile and am.S == bridge_tile:
        for step_number in range(1, 4):
            var col := get_node("step_collision_%d" % step_number) as CollisionShape
            collision.push_back([col, col.transform])
        return collision
        
    if am.N == bridge_tile and am.S == sand_tile:
        for step_number in range(1, 4):
            var col := get_node("step_collision_%d" % step_number) as CollisionShape
            collision.push_back([col, col.transform.rotated(Vector3.UP, deg2rad(180))])
        return collision
        
    if am.E == sand_tile and am.W == bridge_tile:
        for step_number in range(1, 4):
            var col := get_node("step_collision_%d" % step_number) as CollisionShape
            collision.push_back([col, col.transform.rotated(Vector3.UP, deg2rad(-90))])
        return collision
        
    if am.W == sand_tile and am.E == bridge_tile:
        for step_number in range(1, 4):
            var col := get_node("step_collision_%d" % step_number) as CollisionShape
            collision.push_back([col, col.transform.rotated(Vector3.UP, deg2rad(90))])
        return collision

    return collision


func get_meshes(am: AdjacencyMap) -> Array:
    var meshes = [
        [$bridge.mesh, $bridge.transform],
    ]
    
    for mesh in $water_template.get_meshes(am):
        meshes.push_back(mesh)
        
#    if am.N == bridge_tile or am.N == sand_tile:
    if am.NE != bridge_tile and am.E != bridge_tile:
        meshes.push_back([$pole.mesh, $pole.transform])
    if am.NW != bridge_tile:
        meshes.push_back([$pole.mesh, $pole.transform.rotated(Vector3.UP, deg2rad(90))])

    if am.SE != bridge_tile and am.S != bridge_tile:
        meshes.push_back([$pole.mesh, $pole.transform.rotated(Vector3.UP, deg2rad(-90))])
    if am.SW != bridge_tile and am.S != bridge_tile and am.W != bridge_tile:
        meshes.push_back([$pole.mesh, $pole.transform.rotated(Vector3.UP, deg2rad(180))])
    
    if am.S == water_tile:
        if am.SW == bridge_tile:
            meshes.push_back([$pole.mesh, $pole.transform.rotated(Vector3.UP, deg2rad(180))])
        if am.SE == bridge_tile:
            meshes.push_back([$pole.mesh, $pole.transform.rotated(Vector3.UP, deg2rad(-90))])
            
    if am.N == bridge_tile and am.NE == water_tile and am.E == bridge_tile:
        meshes.push_back([$pole.mesh, $pole.transform])
    
    if am.N == sand_tile and am.S == bridge_tile:
        meshes.push_back([$steps.mesh, $steps.transform])
        return meshes 
    
    if am.N == bridge_tile and am.S == sand_tile:
        meshes.push_back([$steps.mesh, $steps.transform.rotated(Vector3.UP, deg2rad(180))])
        return meshes
        
    if am.E == sand_tile and am.W == bridge_tile:
        meshes.push_back([$steps.mesh, $steps.transform.rotated(Vector3.UP, deg2rad(-90))])
        return meshes
        
    if am.W == sand_tile and am.E == bridge_tile:
        meshes.push_back([$steps.mesh, $steps.transform.rotated(Vector3.UP, deg2rad(90))])
        return meshes 
    
    return meshes
