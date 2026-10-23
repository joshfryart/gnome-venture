-- stage-rainforest v2: layered canopy with hanging vines and light shafts, mist trees, buttress-root trunks, monstera leaves, bromeliads, parrots, ferns, mushrooms.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S; S.theme = "rainforest"
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#8fcbd8", "#a9d6ea", "#c8ecdc", "#c8ecdc" }
X.layer(c, "sky"); S.sky(c)
X.layer(c, "far")
S.ridge(c, "#a4b86a", 50, { { 5, 17, 0 }, { 3, 7, 1 } }); S.ridge(c, "#7ab55c", 60, { { 4, 13, 2 }, { 2, 5, 0 } }); S.ridge(c, "#6a9a3a", 70, { { 3, 11, 1 } })
for i = 0, 8 do c:fill(c:rect(14 + i * 28, 60, 15 + i * 28, 92), "#6a9a3a") end
-- light shafts from the upper left: stepped diagonal bands of pale green
for _, b in ipairs({ 40, 120, 190 }) do for y = 14, 90 do c:fill(c:rect(b + y // 3, y, b + y // 3 + 6, y), (y % 2 == 0) and "#c8ecdc" or "#a4b86a") end end
X.layer(c, "ground"); S.ground(c, { walk = "#4f9a45", near = "#2f6a3a", tuft = "#2f5a2a", tuftNear = "#2f5a2a", seed = 21, bank = "#7a4a1f", bankDeep = "#3d2a1c" })
X.layer(c, "objects")
local DL = H.flat("#2f6a3a", "#2f5a2a", "#4f9a45")
-- trunks with buttress roots at the foot
for _, t in ipairs({ { 66, 10 }, { 168, 10 } }) do
  c:part(c:poly({ { t[1] - 8, 94 }, { t[1] - 2, 80 }, { t[1] - 2, 0 }, { t[1] + t[2], 0 }, { t[1] + t[2], 80 }, { t[1] + t[2] + 7, 94 } }), H.WOOD, { gloss = false, cres = 3, deep = 0 })
  for y = 14, 76, 12 do c:fill(c:rect(t[1] - 1, y, t[1] + t[2] - 2, y), "#8a4f2a") end
end
-- canopy across the top with vines
local can = c:mask(); for x = 0, 239 do can:rect(x, 0, x, 13 + math.floor(5 * math.sin(x / 9) + 4 * math.sin(x / 4)) + ((x // 40) % 2) * 3) end
c:part(can, DL, { gloss = false, cres = 3, deep = 0 })
for _, v in ipairs({ { 30, 8 }, { 54, 12 }, { 100, 16 }, { 128, 14 }, { 152, 18 }, { 214, 10 } }) do c:fill(c:rect(v[1], v[2], v[1], v[2] + 14 + (v[1] % 11)), "#4f9a45"); c:fill(c:ellipse(v[1], v[2] + 15 + (v[1] % 11), 2, 2), "#7ab55c") end
-- monstera leaf, bromeliads, fern fronds near the centre
local function leaf(x, y, d) c:part(c:poly({ { x, y }, { x + d * 0.5, y - 14 }, { x + d, y - 6 }, { x + d * 0.7, y } }), H.LEAF, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(x + d * 0.45, y - 12, x + d * 0.5, y - 2), "#2f6a3a") end
leaf(96, 93, 22); leaf(146, 93, -22); leaf(118, 93, 14)
c:part(c:ellipse(124, 78, 4, 4), X.ramp("#dd3a2a", { shade = "#ae2a2a", deep = "#ae2a2a", bounce = "#ae2a2a", gloss = "#dd3a2a", dot = "#dd3a2a" }), { gloss = false, cres = 1, deep = 0 }); c:fill(c:rect(124, 82, 124, 92), "#2f6a3a")
X.layer(c, "detail")
S.flowers(c, { { 60, 102, "p" }, { 196, 104, "g" }, { 40, 120, "g" }, { 212, 124, "p" }, { 112, 120, "p" }, { 138, 100, "g" } })
for _, p in ipairs({ { 186, 52, "#dd3a2a" }, { 52, 62, "#f5cf6a" }, { 84, 44, "#3f8fb0" } }) do c:fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), p[3]); c:px(p[1] + 3, p[2], "#f5cf6a") end   -- parrots
c:fill(c:rect(214, 92, 215, 95), "#f2e4c0"); c:fill(c:ellipse(214, 91, 3, 2), "#dd3a2a")                                  -- toadstool
X.save(c, "stage-rainforest", "scenes", { w = 480, h = 270, cap = 32 })
