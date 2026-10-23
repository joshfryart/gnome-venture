-- stage-island: bright water sea band, sand beach ground, a leaning palm, foam stitches, small far isle.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#8fcbd8", "#a9d6ea", "#c8ecdc", "#eef8f2" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 22, 1); S.cloud(c, 214, 36, 0.6)
X.layer(c, "far")
c:fill(c:rect(0, 62, 239, 91), "#3f8fb0"); 
for y = 70, 90, 6 do for x = (y % 12 == 0) and 4 or 14, 239, 22 do c:fill(c:rect(x, y, x + 5, y), "#a9d6ea") end end   -- wave glints
c:fill(c:ellipse(190, 62, 16, 4), "#7ab55c");    -- far isle + tiny palm
for x = 0, 239 do if x % 3 < 2 then c:px(x, 92, "#eef8f2") end end                                                                      -- foam stitch
X.layer(c, "ground"); S.ground(c, { walkTop = 93, walk = "#f5cf6a", near = "#c9a96e", tuft = "#c9a96e", tuftNear = "#9a6b3f", seed = 13, bank = "#c9a96e", bankDeep = "#9a6b3f" })
X.layer(c, "objects")
local palm = X.ramp("#4f9a45")
local function frond(x, y, dx, dy) c:part(c:poly({ {x, y}, {x + dx, y + dy - 3}, {x + dx * 1.6, y + dy}, {x + dx * 0.8, y + 2} }), palm, { gloss = false, cres = 2 }) end
c:part(c:poly({ {118, 92}, {121, 92}, {128, 70}, {132, 52}, {128, 52}, {122, 70} }), "wood", { gloss = false, cres = 2 })
frond(130, 52, -18, 6); frond(130, 52, 18, 6); frond(130, 52, -10, -8); frond(130, 52, 10, -8); frond(130, 52, 0, -12)
c:part(c:ellipse(130, 55, 2, 2), "wood", { gloss = false, flat = true })
c:build{ { "rock", c:ellipse(150, 93, 6, 3), "stone", { cres = 2, deep = 1 } } }
X.layer(c, "detail"); S.bird(c, 66, 36)
X.save(c, "stage-island", "scenes", { w = 480, h = 270, cap = 32 })
