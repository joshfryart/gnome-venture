"""Sketches for tools/build_maplewold_bendy.py (see its docstring). One entry per route, one dict per section."""
SPECS = {}

SPECS[313] = [
 dict(land=dict(wall=.28), road="E4 N3 E6 S3 E6 N3 E6 S4 E5 N1 E2",
      ops=[("W",13,1,14,16), ("W",15,1,22,5), ("W",17,13,24,16), ("r",26,14,4), ("r",24,12,2)],
      F=[(5,15),(20,3)], L=[(11,5),(26,14)]),
 dict(road="E5 N2 E6 S3 E5 S2 E4 S4",
      ops=[("W",14,2,14,16), ("w",9,2,2), ("r",9,4,1)],
      F=[(4,15),(22,4),(24,13)], L=[(8,5),(12,14)]),
 dict(road="S4 W3 S4 E2 S3 E10",
      land=dict(rough=.18),
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

MAZE = ["##.##.##", "##.##.##", "........", "##.##.##", "##.##.##", "........", "##.##.##"]
SPECS[228] = [
 dict(road="S5 W3 S6 E3 S6", ops=[("drift",25,14,3,2), ("fence",21,2,28,2), ("pat",6,2,MAZE), ("r",24,8,3), ("w",26,3,1), ("w",3,14,2)],       # hay-bale maze west, scarecrow field east
      F=[(3,14),(26,13),(25,2)], L=[(12,6),(22,8)]),
 dict(road="S5 W3 S6 W3 S6", ops=[("marsh",24,14,3), ("grove",4,3,3), ("fence",20,3,26,3), ("W",1,8,13,9), ("W",19,8,28,9), ("R",14,8,18,9), ("w",5,14,3), ("r",5,14,1)],   # ford between two banks, pond and mill
      F=[(24,13),(4,3),(25,3)], L=[(11,6),(10,13)]),
 dict(road="S6 E3 S5 W1 S6", ops=[("orchard",3,3,8,7,2), ("pond",25,15,2), ("W",3,9,11,9), ("W",19,9,27,9), ("W",3,13,10,13), ("W",20,13,27,13), ("w",9,4,1), ("w",24,4,2)],  # apple tree, hedge-row lane
      F=[(4,4),(26,15),(5,16)], L=[(10,4),(21,7)]),
]
BERRY = ["#.#.#", "?????", "#.#.#"]
SPECS[232] = [
 dict(road="E5 N2 E6 S2 E6 N3 E6 S2 E6", ops=[("hedgefield",2,12,9,16,5), ("grove",26,2,2), ("r",8,10,3), ("r",24,13,2), ("pat",19,11,BERRY), ("pat",22,13,BERRY)],     # beehive meadow, berry patch
      F=[(3,14),(14,2),(26,2)], L=[(8,9),(20,9)]),
 dict(road="E5 S1 E6 S1 E6 N2 E6 S2 E6", ops=[("pond",5,14,2), ("orchard",22,2,27,4,2), ("W",11,1,12,5), ("W",12,6,13,10), ("W",13,11,14,16), ("w",25,13,2)],  # hollow log bridge over a stream, old well
      F=[(5,14),(21,2),(27,14)], L=[(10,11),(21,10)]),
 dict(road="E5 N2 E5 S1 E5 N1 E5 S1 E5 N1 E4", ops=[("marsh",5,14,3), ("hedgefield",21,14,28,16,24), ("R",11,2,12,15), ("R",3,12,10,12), ("R",17,3,27,3), ("r",23,12,3), ("r",23,12,1)],  # crossroads, picnic rise
      F=[(4,15),(8,3),(27,15)], L=[(14,11),(22,10)]),
]
SPECS[236] = [
 dict(land=dict(wall=.2), road="E6 N2 E6 S2 E6 S2 E6 N2 E5", ops=[("grove",4,3,2), ("fence",21,15,27,15), ("r",9,13,3), ("r",20,13,3), ("r",24,3,3), ("r",5,3,2)],        # wildflower slope, dandelion drift
      F=[(3,14),(14,2),(27,15)], L=[(9,9),(21,5)]),
 dict(road="E5 N2 E6 S1 E6 N2 E6 N1 E6", ops=[("pond",5,15,2), ("grove",25,3,2), ("W",13,1,14,6), ("W",14,7,15,12), ("W",15,13,16,16), ("pat",20,11,["#.#.#.#.", "........", "#.#.#.#."])],  # little stone bridge, beanpole garden
      F=[(5,14),(25,3),(8,3)], L=[(13,11),(22,12)]),
 dict(road="E5 S3 E6 S2 E6 S2 E6 S2 E6", ops=[("hedgefield",3,12,10,16,6), ("marsh",25,5,2), ("r",13,6,2), ("W",21,9,22,9), ("w",4,13,2), ("w",26,5,2)],      # windmill on a rise, hay wagon
      F=[(3,3),(24,3),(8,15)], L=[(13,7),(20,10)]),
]
SPECS[304] = [
 dict(road="W5 N2 W5 S1 W5 N2 W5 N1 W5 N1 W4", ops=[("W",17,5,21,5), ("W",17,6,18,9), ("W",20,6,21,8), ("F",19,5,19,8), ("w",8,12,2)],   # oak-root arch, hollow trunk
      F=[(27,15),(4,14),(14,2)], L=[(19,7),(8,11)]),
 dict(road="W5 S3 W5 N1 W5 S2 W5 N2 W5 S2 W4", ops=[("r",22,13,2), ("w",12,3,2)],                             # acorn drop, owl-hole oak
      F=[(27,14),(5,2),(16,15)], L=[(23,12),(12,6)]),
]
SPECS[305] = [
 dict(road="S5 E2 S6 W1 S6", ops=[("W",13,1,14,10), ("W",20,1,21,10), ("pat",10,14,["#.#.#.#.#.#.#.#.#"])],    # white-bark tunnel, birch curtain
      F=[(4,4),(26,4),(4,15)], L=[(14,11),(20,14)]),
 dict(road="S5 W3 S6 W4 S6", ops=[("r",18,9,3), ("f",6,13,3), ("r",6,13,1)],                         # fern hollow, sunbeam clearing
      F=[(25,3),(26,14),(3,3)], L=[(13,3),(7,13)]),
]
SPECS[306] = [
 dict(land=dict(wall=.30), road="W5 S2 W6 N1 W6 S1 W6 N1 W6", ops=[("W",17,14,23,14), ("w",10,4,2), ("w",9,6,1)],              # mossy log, drip-stone grotto
      F=[(27,15),(4,15),(14,3)], L=[(22,9),(10,9)]),
 dict(road="W6 S2 W6 S1 W6 S3", ops=[("W",20,1,20,12), ("W",20,14,20,16), ("r",14,9,1), ("r",16,11,1), ("r",12,8,1)],  # mossy gate, toadstool steps
      F=[(26,3),(3,4),(26,15)], L=[(19,10),(8,12)]),
]
SPECS[307] = [
 dict(road="E5 S2 E6 N1 E6 S2 E6 S1 E6", ops=[("W",1,15,28,16), ("R",1,13,28,14), ("w",20,3,1), ("w",23,4,1), ("w",8,3,1), ("w",26,2,1)],   # long tideline, barnacle rocks
      F=[(4,11),(25,12),(14,2)], L=[(14,11),(20,5)]),
 dict(road="E5 N2 E6 S1 E6 N2 E6 S1 E6", ops=[("W",1,15,28,16), ("W",1,1,28,2), ("pat",5,10,["?###?","#...#","#...#"]), ("w",22,12,2), ("r",21,12,1)],   # shell hollow, sandcastle shallows
      F=[(3,13),(26,13),(14,13)], L=[(8,12),(21,11)]),
]
SPECS[308] = [
 dict(road="W5 N2 W5 N1 W5 S1 W5 N2 W5 N1 W4", ops=[("W",1,14,28,16), ("R",12,12,27,12), ("R",8,10,20,10), ("r",12,13,0)],   # pebble bar, kelp line
      F=[(5,13),(25,13),(14,2)], L=[(21,9),(11,9)]),
 dict(road="W6 S2 W6 S2 W6 W4 N6 W3 N1", ops=[("w",20,13,3), ("r",20,10,1), ("W",1,14,28,16)],             # rock pool, tide-pool steps (placeholder, fixed below)
      F=[(3,12),(26,13),(25,2)], L=[(19,9),(10,10)]),
]

SPECS[309] = [
 dict(land=dict(wall=.18), road="E6 N2 E6 S2 E6 S2 E6 N2 E5", ops=[("r",9,14,4), ("r",9,14,2)] + [("w",x,3,0) for x in (19,21,23,25,27)] + [("w",x,12,0) for x in (21,24,27)],   # frozen pond, snowman gallery
      F=[(3,14),(15,2),(27,14)], L=[(9,9),(21,5)]),
 dict(road="E6 S2 E6 N2 E6 S2 E6 N2 E5", ops=[("W",15,1,16,5), ("W",15,9,16,16), ("F",15,6,16,8), ("W",20,13,27,14), ("w",4,3,2)],         # icicle cave mouth (gap in a wall), aurora-glass ledge
      F=[(3,14),(10,3),(25,3)], L=[(13,5),(22,11)]),
]
SPECS[310] = [
 dict(road="W5 N2 W5 S1 W5 N1 W5 N2 W5 S1 W4", ops=[("W",12,1,16,5), ("W",12,10,16,16), ("R",3,12,12,12), ("R",12,13,25,13), ("R",3,15,12,15)],  # drift pass between two drifts, sled track
      F=[(3,14),(26,14),(26,2)], L=[(17,5),(21,11)]),
 dict(road="W6 S2 W6 N3 W6 W4 N5", ops=[("W",19,12,27,13), ("pat",18,14,["#.#.#.#.#.#"]), ("pat",9,1,["#.#.#.#"]), ("w",24,2,2)],     # snow-comb ridge, icicle curtain
      F=[(3,12),(26,16),(25,3)], L=[(20,10),(10,3)]),
]
SPECS[311] = [
 dict(road="W5 S1 W5 S1 W5 N1 W5 S2 W5 N1 W4", ops=[("pond",5,4,2), ("grove",26,15,2)] + [("w",x,8,0) for x in (10,13,16,19,22,25)] + [("w",x,16,0) for x in (20,22)] + [("w",12,15,1)],   # maple tap row, bucket stacks
      F=[(26,14),(5,4),(14,3)], L=[(22,8),(11,14)]),
 dict(road="W6 N1 W6 S2 W10 S2 W3 S2", ops=[("orchard",22,2,27,4,2), ("marsh",14,15,2), ("r",20,6,3), ("w",24,2,1), ("w",2,2,1)],                     # Sugar Shack yard, pancake lane
      F=[(27,15),(3,3),(14,15)], L=[(20,8),(9,10)]),
]
SPECS[312] = [
 dict(road="W5 N2 W5 S2 W5 N1 W5 S1 W5 N1 W4", ops=[("W",17,12,25,12), ("w",12,3,2)],                   # ring-count log, woodpecker tree
      F=[(27,14),(4,14),(6,2)], L=[(21,10),(12,3)]),
 dict(land=dict(wall=.28), road="W5 S2 W5 N1 W5 S2 W5 S1 W5 N1 W4", ops=[("W",2,5,13,7), ("W",2,12,13,16), ("pat",20,10,["?,,,?", ",...,", ",.#.,", ",...,", "?,,,?"])],   # toadstool ring, bramble corridor
      F=[(26,14),(16,15),(24,2)], L=[(22,11),(11,11)]),
 dict(road="W5 N1 W5 S2 W5 N2 W5 S1 W5 N2 W4", ops=[("r",16,13,3), ("w",7,4,1), ("w",5,4,1)],               # great stump, squirrel's larder
      F=[(27,14),(25,3),(3,14)], L=[(16,13),(7,5)]),
]
SPECS[314] = [
 dict(road="E5 N2 E5 N1 E5 S1 E5 N2 E5 N1 E4", ops=[("W",8,1,28,2), ("w",7,12,0), ("r",6,10,1), ("r",18,10,2)],     # driftwood beach, shell pile
      F=[(3,14),(25,14),(12,3)], L=[(7,10),(18,10)]),
 dict(land=dict(wall=.03, rough=.2), road="E6 S2 E6 N1 E6 N5", ops=[("W",1,12,28,16), ("W",7,1,14,3), ("r",22,8,2)],                                         # stepping rocks, tidal causeway (strip over sea)
      F=[(3,2),(24,6),(26,2)], L=[(3,9),(14,9)]),
 dict(road="N6 E3 N6 E8", ops=[("w",27,8,1), ("w",25,10,1), ("w",3,3,2), ("W",1,14,10,16), ("w",13,10,0)],    # lantern rocks, gull parliament
      F=[(3,12),(26,14),(10,2)], L=[(25,8),(14,9)]),
]
SPECS[316] = [
 dict(road="W6 N2 W6 S2 W6 S2 W6 N2 W5", ops=[("w",20,3,3), ("r",20,3,1)] + [("w",x,y,0) for x,y in ((7,6),(9,4),(12,7),(14,4),(6,9),(10,5))],     # sky-watch hill, star-chart stones
      F=[(3,15),(26,15),(26,3)], L=[(20,7),(10,8)]),
 dict(road="W6 N2 W6 S1 W6 N2 W6 N1 W5", ops=[("f",14,5,3), ("r",14,5,1), ("w",21,13,2), ("w",20,12,1), ("w",3,14,3)],   # aurora camp, kettle tree
      F=[(3,13),(26,15),(26,3)], L=[(14,6),(19,12)]),
]
