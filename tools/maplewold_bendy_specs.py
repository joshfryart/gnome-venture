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
