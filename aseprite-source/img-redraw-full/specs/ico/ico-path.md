# ico/ico-path
- canvas: 64x64, mode icon, 1x.
- subject: A winding dirt trail curving through a green square field, a map-style path icon; calm and inviting.
- must-read-at-16px: a pale S-shaped trail on a green rounded square.
- distinct: S-curve path running from the bottom left to the top centre over a tile-like green square, with a dotted footprint trail.
- parts (back to front):
  1. field tile: rrect x 12..52, y 10..51 (r9), #58a03e (moss #6a9a3a)
  2. path: 8 px curve (23,52)->(24,42)->(40,40)->(39,32)->(28,24)->(29,12), #dcb06a (wood #d9a660), round ends clipped by the tile
  3. path edge shade: lower-right 2 px edge #b07a45
  4. footprint dots: dashed 2 px line along the path centre, #f1dfae, 1 on / 3 off
  5. grass tufts: 3 px each at (16,18) and (46,44), #4a8a3e
- joins: edge stitch around the field tile (thread gold ring 2 px inside).
- face: none.
- notes: path width at least 6 px everywhere; the trail runs off the top and bottom of the tile edges slightly.
