-- pin: hoop map marker, 16x16. The Part D gold button (cut-corner disc, darker lower right, two diagonal
-- thread holes) with a cream thread stitched through it. Sprite: 1 px black border. No cap in Part E for map
-- icons; held to 16 colours (the small-sprite cap). Families: gold, cream thread, umber.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local c = X.canvas{ w = 16, h = 16, mode = "icon", ol = 1, olx = 1, cres = 2, deep = 1 }

X.layer(c, "objects")
local disc = c:ellipse(7.5, 7.5, 4.6, 4.6)
c:part(disc, "gold", { gloss = false })
c:fill(c:ellipse(7.5, 7.5, 2.4, 2.4), "#d0862a")          -- recessed centre (gold bounce)
c:px(4, 5, "#fff1c8"); c:px(5, 4, "#fff1c8"); c:px(4, 6, "#fff1c8") -- enamel comma on the lit rim

X.layer(c, "detail")
c:px(6, 6, "#8a4a1c"); c:px(9, 9, "#8a4a1c")              -- two diagonal thread holes
c:px(7, 7, "#f2e4c0"); c:px(8, 8, "#f2e4c0")              -- cream thread stitched between them

X.save(c, "pin", "map", { w = 16, h = 16, cap = 16 })
