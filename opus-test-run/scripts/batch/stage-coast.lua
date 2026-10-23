-- stage-coast: sea to the horizon, grassy headland with a red-and-cream lighthouse, shingle shore, gulls.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 20, 1); S.cloud(c, 90, 34, 0.7)
X.layer(c, "far")
c:fill(c:rect(0, 56, 239, 91), "#25637d"); c:fill(c:rect(0, 56, 239, 66), "#3f8fb0"); 
for y = 76, 90, 7 do for x = (y % 14 == 0) and 6 or 18, 239, 26 do c:fill(c:rect(x, y, x + 6, y), "#a9d6ea") end end
S.ridge(c, "#7ab55c", 80, { {5, 41, 3}, {1.5, 9, 0} })          -- headland
X.layer(c, "ground"); S.ground(c, { walk = "#c9c5bc", near = "#8b8f96", tuft = "#8b8f96", tuftNear = "#5b6470", seed = 17, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
c:fill(c:rect(0, 92, 239, 93), "#eef8f2")                       -- surf line along the shore
X.layer(c, "objects")
-- lighthouse on the far headland (small, off the party/foe slots)
c:part(c:poly({ {190, 80}, {200, 80}, {198, 52}, {192, 52} }), "cream", { gloss = false, cres = 2 })
c:fill(c:poly({ {192, 66}, {199, 66}, {198.5, 59}, {192.5, 59} }), "#d6322b")
c:part(c:rect(191, 46, 199, 52), X.ramp("#e8a317"), { gloss = false, flat = true })
c:part(c:poly({ {190, 46}, {195, 40}, {200, 46} }), "red", { gloss = false, cres = 2 })
c:build{ { "rock1", c:ellipse(100, 92, 8, 4), "stone", { cres = 3, deep = 1 } }, { "rock2", c:ellipse(110, 90, 5, 4), "stone", { cres = 2, deep = 1 } },
  { "buoy", c:ellipse(148, 90, 3, 3), "stone", { gloss = false, cres = 1, deep = 0 } } }
X.layer(c, "detail"); S.bird(c, 60, 38); S.bird(c, 72, 32); S.bird(c, 120, 44)
X.save(c, "stage-coast", "scenes", { w = 480, h = 270, cap = 32 })
