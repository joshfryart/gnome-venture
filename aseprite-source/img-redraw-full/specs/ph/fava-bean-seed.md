# ph/fava-bean-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a rough burlap sack tied shut with twine, a big brown fava bean resting on its front. Rustic and lumpy.
- must-read-at-16px: lumpy sack silhouette, narrower tied neck with a twine knot.
- distinct: tied-with-twine neck with two frayed tufts above, and a large dark bean drawn on the sack front.
- parts:
  1. sack body: ellipse cx32 cy40 rx19 ry16, base #c9a96e (soil tan)
  2. neck: trapezoid (25,24),(39,24),(42,30),(22,30), #c9a96e
  3. top tufts: two 3px-wide frayed spikes at (27,18) and (37,18), #9a6b3f
  4. twine wrap: 2px band y27 x22..42 plus 4x4 knot at (30,27), #8a4f2a
  5. fava bean: bean shape x22..44, y33..49, base #8c4a1a, 2px seam #44281c, three 3px dots (28,40),(33,38),(38,36) #44281c
  6. burlap weave: 4 short 1px ticks #9a6b3f on the sack
- joins: none (twine is the tie).
- face: none.
- notes: bean must be the darkest mass on the light sack. Min part 2px.
