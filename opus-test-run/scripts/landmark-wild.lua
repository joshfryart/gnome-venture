-- landmark-wild: hoop map landmark, 16x16. A tiny red pennant on a wooden pole, a cream skull stitched on
-- it (cosy, not scary), planted in a little soil mound. Sprite: 1 px black border. Held to 16 colours.
-- Families: red (flag), wood (pole), soil (mound), cream (skull), umber.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local c = X.canvas{ w = 16, h = 16, mode = "icon", ol = 1, olx = 1, cres = 2, deep = 1 }
local RED = X.ramp("red", { bounce = "#ae2a2a", deep = "#ae2a2a" })

X.layer(c, "objects")
c:part(c:ellipse(3.5, 12, 2.6, 1.2), "soil", { gloss = false, cres = 1, deep = 0, bounce = false })
c:part(c:rect(2, 2, 3, 11), "wood", { flat = true })
-- swallow-tail pennant flying right
c:part(c:poly({ { 4, 2 }, { 14, 2 }, { 11, 5.5 }, { 14, 9 }, { 4, 9 } }), RED, { gloss = false, cres = 2, deep = 1, contour = false })

X.layer(c, "detail")
-- cream skull: round cranium, two umber eyes, little jaw
c:paint({ ".ccc.", "cecec", "ccccc", ".c.c." }, 5, 3, { c = "#f2e4c0", e = "#2a1a10" })
c:px(2, 1, "#f5cf6a"); c:px(3, 1, "#e8a317") -- gold finial on the pole

X.save(c, "landmark-wild", "map", { w = 16, h = 16, cap = 16 })
