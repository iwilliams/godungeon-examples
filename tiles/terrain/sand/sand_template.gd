tool
extends "res://addons/godungeon/GodungeonSpatialTileTemplate.gd"

export(Resource) var water_tile: Resource           
export(Resource) var bridge_tile: Resource           


func is_water_or_bridge(tile: Resource):
    return tile == water_tile or tile == bridge_tile


func get_collision(am: AdjacencyMap) -> Array:   
    if is_water_or_bridge(am.E) and is_water_or_bridge(am.S):
        return [
            [$corner_outer_collision, $corner_outer_collision.transform],
        ]

    if is_water_or_bridge(am.W) and is_water_or_bridge(am.S):
        var t = $corner_outer_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))
        return [
            [$corner_outer_collision, t]
        ]
            
    if is_water_or_bridge(am.N) and is_water_or_bridge(am.W):
        var t = $corner_outer_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-180))
        return [
            [$corner_outer_collision, t]
        ]

    if is_water_or_bridge(am.N) and is_water_or_bridge(am.E):
        var t = $corner_outer_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$corner_outer_collision, t]
        ]

    if is_water_or_bridge(am.N):
        var t = $edge_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(180))
        return [
            [$edge_collision, t]
        ]

    if is_water_or_bridge(am.S):
        return [
            [$edge_collision, $edge_collision.transform]
        ]

    if is_water_or_bridge(am.E):
        var t = $edge_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$edge_collision, t]
        ]

    if is_water_or_bridge(am.W):
        var t = $edge_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))
        return [
            [$edge_collision, t]
        ]
        
    if is_water_or_bridge(am.SE):
        var t = $corner_inner_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(0))
        return [
            [$corner_inner_collision, t]
        ]
        
    if is_water_or_bridge(am.SW):
        var t = $corner_inner_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))
        return [
            [$corner_inner_collision, t]
        ]
    
    if is_water_or_bridge(am.NE):
        var t = $corner_inner_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$corner_inner_collision, t]
        ]

    if is_water_or_bridge(am.NW):
        var t = $corner_inner_collision.transform.rotated(Vector3(0, 1, 0), deg2rad(180))
        return [
            [$corner_inner_collision, t]
        ]
        
    return [
        [$flat_collision, $flat_collision.transform]
    ]


func get_meshes(am: AdjacencyMap) -> Array:
    if is_water_or_bridge(am.E) and is_water_or_bridge(am.S):
        return [
            [$corner_outer.mesh, $corner_outer.transform],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.W) and is_water_or_bridge(am.S):
        var t = $corner_outer.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))
        return [
            [$corner_outer.mesh, t],
            [$water.mesh, $water.transform]
        ]
            
    if is_water_or_bridge(am.N) and is_water_or_bridge(am.W):
        var t = $corner_outer.transform.rotated(Vector3(0, 1, 0), deg2rad(-180))
        return [
            [$corner_outer.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.N) and is_water_or_bridge(am.E):
        var t = $corner_outer.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$corner_outer.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.N):
        var t = $edge.transform.rotated(Vector3(0, 1, 0), deg2rad(180))
        return [
            [$edge.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.S):
        var t = $edge.transform
        return [
            [$edge.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.E):
        var t = $edge.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$edge.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.W):
        var t = $edge.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))       
        return [
            [$edge.mesh, t],
            [$water.mesh, $water.transform]
        ]
        
    if is_water_or_bridge(am.SE):
        var t = $corner_inner.transform.rotated(Vector3(0, 1, 0), deg2rad(0))
        return [
            [$corner_inner.mesh, t],
            [$water.mesh, $water.transform]
        ]
        
    if is_water_or_bridge(am.SW):
        var t = $corner_inner.transform.rotated(Vector3(0, 1, 0), deg2rad(-90))
        return [
            [$corner_inner.mesh, t],
            [$water.mesh, $water.transform]
        ]
    
    if is_water_or_bridge(am.NE):
        var t = $corner_inner.transform.rotated(Vector3(0, 1, 0), deg2rad(90))
        return [
            [$corner_inner.mesh, t],
            [$water.mesh, $water.transform]
        ]

    if is_water_or_bridge(am.NW):
        var t = $corner_inner.transform.rotated(Vector3(0, 1, 0), deg2rad(180))
        return [
            [$corner_inner.mesh, t],
            [$water.mesh, $water.transform]
        ]
        
    return [
        [$flat.mesh, $flat.transform]   
    ]
