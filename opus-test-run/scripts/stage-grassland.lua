-- stage-grassland: stage backdrop, 240x135 grid -> 480x270 (2x nearest). Part E: opaque, no border, cap 32.
-- Families: water (sky), gold (sun), cream (clouds), moss + leaf (land, tree), wood (trunk), soil (bank), petal (flowers).
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky")
S.sky(c)
S.sun(c, 34, 19)
S.cloud(c, 72, 27, 1.0); S.cloud(c, 176, 18, 0.8); S.cloud(c, 214, 40, 0.55)

X.layer(c, "far")
S.ridge(c, "#bdd292", 63, { {5, 23, 0}, {3, 9, 1} })      -- farthest hills: palest, least saturated
S.ridge(c, "#acc47d", 73, { {4, 31, 2}, {2, 13, 0} })
for _, t in ipairs({ {14, 74}, {22, 73}, {200, 72}, {209, 74}, {226, 73} }) do S.farTree(c, t[1], t[2], "#a4b86a") end
S.ridge(c, "#a4b86a", 83, { {1.5, 19, 1} })                -- back meadow

X.layer(c, "ground")
S.ground(c, { walk = "#7ab55c", near = "#4f9a45", tuft = "#2f6a3a", tuftNear = "#2f5a2a" })

X.layer(c, "objects")
-- the centre oak (centre third, behind the stage line)
local trunk = c:poly({ {116, 62}, {124, 62}, {125, 84}, {129, 91}, {111, 91}, {115, 84} })
local canopy = c:ellipse(120, 51, 23, 12):add(c:ellipse(101, 57, 11, 8)):add(c:ellipse(139, 57, 11, 8))
  :add(c:ellipse(110, 39, 12, 10)):add(c:ellipse(131, 41, 11, 9)):add(c:ellipse(121, 30, 9, 7))
local leaf = X.ramp("leaf", { dot = "#c8d77a" })
c:build{
  { "bushL", c:ellipse(96, 89, 6, 4):add(c:ellipse(102, 87, 5, 5)):add(c:ellipse(90, 90, 4, 3)), leaf, { cres = 3, deep = 1 } },
  { "bushR", c:ellipse(143, 89, 5, 4):add(c:ellipse(148, 90, 4, 3)), leaf, { cres = 3, deep = 1 } },
  { "trunk", trunk, "wood", { gloss = false } },
  { "canopy", canopy, leaf },
}

X.layer(c, "detail")
-- wildflowers: denser in the centre, sparse in the calm side thirds
S.flowers(c, { {92, 96, "p"}, {104, 101, "g"}, {131, 97, "p"}, {150, 103, "g"}, {113, 118, "p"}, {127, 122, "g"},
  {86, 116, "g"}, {158, 117, "p"}, {140, 126, "p"}, {98, 127, "p"}, {30, 121, "g"}, {214, 125, "p"}, {60, 129, "p"} })
S.bird(c, 186, 37); S.bird(c, 195, 33)

X.save(c, "stage-grassland", "scenes", { w = 480, h = 270, cap = 32 })
