"""Sketches for tools/build_maplewold_bendy.py (see its docstring). One entry per route, one dict per section."""
SPECS = {}

SPECS[313] = [
 dict(road="E4 N3 E6 S3 E6 N3 E6 S4 E5 N1 E2",
      ops=[("W",13,1,14,16), ("W",15,1,22,5), ("W",17,13,24,16), ("r",26,14,4), ("r",24,12,2)],
      F=[(5,15),(20,3)], L=[(11,5),(26,14)]),
 dict(road="E5 N2 E6 S3 E5 S2 E4 S4", land=dict(wall=.38),
      ops=[("W",14,2,14,16), ("w",9,2,2), ("r",9,4,1)],
      F=[(4,15),(22,4),(24,13)], L=[(8,5),(12,14)]),
 dict(road="S4 W3 S4 E2 S3 E10",
      land=dict(wall=.30, rough=.18),
      ops=[("W",20,6,28,9), ("W",20,13,28,16), ("F",20,10,28,12), ("F",23,7,23,9), ("F",22,7,24,8), ("r",4,3,4), ("r",11,14,3)],
      F=[(5,14),(26,2)], L=[(17,11),(23,8)]),
]

SPECS[315] = [
 dict(road="E5 N2 E6 S2 E6 N2 E6 S1 E6",                       # snowy gate (wall with one gap), lamp-post lane
      ops=[("W",3,1,3,16), ("W",2,1,2,3), ("W",2,12,2,16), ("r",9,13,3), ("r",20,3,3)],
      F=[(8,14),(24,13),(14,2)], L=[(5,10),(17,9)]),
 dict(road="E6 S2 E6 N2 E6 S2 E4 N2 E4 S2 E3",                 # pine slope (diagonal ridge of pines), snow fort (ring with a gap)
      ops=[("pat",7,1,["###?????","?###????","??###???","???###??"]), ("r",10,5,2), ("r",9,3,2),
           ("pat",20,10,["#######","#.....#","#.###.#","#.....#","###.###"]),
           ("w",3,14,2), ("w",27,3,2)],
      F=[(3,12),(26,14),(16,2)], L=[(8,5),(18,13)]),
 dict(road="E5 S2 E6 N2 E6 S3 E6 N1 E6",                       # frozen stream (winding water), icicle bridge (strip over it)
      ops=[("W",13,1,14,5), ("W",14,6,15,10), ("W",12,11,13,16), ("W",13,6,13,7), ("r",14,3,0), ("w",21,14,2), ("w",5,3,2)],
      F=[(5,14),(24,3),(21,16)], L=[(9,5),(17,11)]),
 dict(road="E6 N2 E6 S2 E6 N3 E5 S1 E6",                       # giant feather (long diagonal ice patch), feather cairns (little stone heaps)
      ops=[("pat",7,1,["??????,,",".?????,,,","??????,,,,",",,,,,,,,,","??,,,,,,,,"]), ("r",8,3,3), ("r",11,4,2),
           ("w",21,12,0), ("w",24,13,0), ("w",26,11,0), ("w",22,14,0), ("w",25,15,0), ("w",19,13,0)],
      F=[(4,14),(14,15),(27,3)], L=[(10,5),(23,12)]),
 dict(road="E6 N2 E6 S2 E6 N2 E5 S1 E6",                       # owl's doormat (rough patch), den (hill around the exit corridor)
      ops=[("W",24,1,28,4), ("W",24,10,28,16), ("W",22,1,23,3), ("W",22,11,23,16), ("r",19,8,2), ("r",20,10,1), ("w",5,14,3), ("w",9,3,2)],
      F=[(3,13),(13,14),(14,2)], L=[(19,11),(21,10)]),
]
