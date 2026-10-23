-- stage-rainforest: dense layered canopy, hanging vines, big leaves, bright flowers; humid green haze, deepest moss ground.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#8fcbd8", "#a9d6ea", "#c8ecdc", "#c8ecdc" }
X.layer(c, "sky"); S.sky(c)
X.layer(c, "far")
S.ridge(c, "#a4b86a", 50, { {5, 17, 0}, {3, 7, 1} }); S.ridge(c, "#7ab55c", 60, { {4, 13, 2}, {2, 5, 0} }); S.ridge(c, "#6a9a3a", 70, { {3, 11, 1} })
for i = 0, 8 do c:fill(c:rect(14 + i * 28, 60, 15 + i * 28, 92), "#6a9a3a") end   -- far trunks
X.layer(c, "ground"); S.ground(c, { walk = "#4f9a45", near = "#2f6a3a", tuft = "#2f5a2a", tuftNear = "#2f5a2a", seed = 21, bank = "#7a4a1f", bankDeep = "#3d2a1c" })
X.layer(c, "objects")
local leaf = X.ramp("#4f9a45")
c:build{
  { "trunkL", c:rect(70, 0, 79, 94), "wood", { gloss = false, cres = 3 } },
  { "trunkR", c:rect(164, 0, 173, 94), "wood", { gloss = false, cres = 3 } },
}
local canopy = c:mask(); for x = 0, 239 do canopy:rect(x, 0, x, 14 + math.floor(5 * math.sin(x / 9) + 4 * math.sin(x / 4)) ) end
c:build{ { "canopy", canopy, X.ramp("#2f6a3a"), { gloss = false, cres = 3 } } }
for _, v in ipairs({ {40, 8}, {88, 16}, {120, 14}, {150, 18}, {200, 12} }) do c:fill(c:rect(v[1], v[2], v[1], v[2] + 14 + (v[1] % 9)), "#4f9a45"); c:fill(c:ellipse(v[1], v[2] + 15 + (v[1] % 9), 2, 2), "#7ab55c") end
-- big leaves and ferns around the stage edges only low in the frame
local function bigleaf(x, y, dx) c:part(c:poly({ {x, y}, {x + dx * 0.5, y - 12}, {x + dx, y - 4}, {x + dx * 0.7, y} }), leaf, { gloss = false, cres = 3, deep = 1 }) end
bigleaf(100, 92, 20); bigleaf(146, 92, -20); bigleaf(120, 92, 14)
c:build{ { "orchid", c:ellipse(124, 80, 3, 3), X.ramp("#e46a9b"), { gloss = false, cres = 1, deep = 0 } } }
c:fill(c:rect(124, 83, 124, 92), "#2f6a3a")
X.layer(c, "detail"); S.flowers(c, { {60, 102, "p"}, {196, 104, "g"}, {40, 120, "g"}, {212, 124, "p"}, {112, 120, "p"}, {138, 100, "g"} })
c:paint({ "r.r", ".r." }, 186, 52, { r = "#f5cf6a" })
X.save(c, "stage-rainforest", "scenes", { w = 480, h = 270, cap = 32 })
