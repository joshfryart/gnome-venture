-- stage-tundra: pale water-blue sky and ice ridges, snow-covered ground, a snowy spruce and an ice boulder.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#c8ecdc", "#f1ece0" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 140, 26, 1.1); S.cloud(c, 200, 44, 0.6)
X.layer(c, "far")
S.ridge(c, "#c8ecdc", 62, { {6, 27, 0}, {3, 11, 1} }); S.ridge(c, "#a9d6ea", 74, { {4, 33, 2}, {2, 13, 0} })
S.ridge(c, "#f1ece0", 83, { {2, 21, 1} })
X.layer(c, "ground"); S.ground(c, { walk = "#f1ece0", near = "#c8ecdc", tuft = "#a9d6ea", tuftNear = "#8fcbd8", seed = 3, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
X.layer(c, "objects")
local pine = X.ramp("#2f5a2a")
local function spruce(x, y, s)
  c:part(c:rect(x - 1, y - 6, x + 1, y), "wood", { gloss = false, flat = true })
  for i = 0, 2 do
    local w = (10 - i * 2) * s; local ty = y - 6 - i * 10 * s
    c:part(c:poly({ {x - w, ty}, {x, ty - 14 * s}, {x + w, ty} }), pine, { gloss = false, cres = 3 })
    c:fill(c:poly({ {x - w * 0.6, ty - 4 * s}, {x, ty - 14 * s}, {x + w * 0.6, ty - 4 * s} }), "#f1ece0")   -- snow cap
  end
end
spruce(120, 91, 1); spruce(146, 90, 0.7)
c:build{ { "ice", c:poly({ {86, 91}, {90, 80}, {98, 76}, {106, 82}, {108, 91} }), X.ramp("#a9d6ea"), { cres = 3, deep = 1 } } }
c:fill(c:rect(92, 80, 94, 83), "#f1ece0")
X.layer(c, "detail")
for _, p in ipairs({ {30, 120}, {60, 125}, {200, 118}, {170, 124}, {110, 122} }) do c:paint({ "x...x", ".xxx." }, p[1], p[2], { x = "#a9d6ea" }) end
S.bird(c, 70, 40)
X.save(c, "stage-tundra", "scenes", { w = 480, h = 270, cap = 32 })
