-- stage-desert: warm gold sky haze, sand dunes, red mesa, cacti. Soil + gold + ember families.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#f2e4c0", "#fff3c8" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19)
S.cloud(c, 160, 24, 0.7)
X.layer(c, "far")
-- mesas
for _, m in ipairs({ {58, 60, 22, 9}, {176, 56, 28, 8}, {226, 66, 12, 7} }) do
  c:fill(c:poly({ {m[1] - m[3], 92}, {m[1] - m[3] + 3, 92 - m[4] * 3 }, {m[1] + m[3] - 3, 92 - m[4] * 3}, {m[1] + m[3], 92} }), "#e0501f")
  c:fill(c:rect(m[1] - m[3] + 4, 92 - m[4] * 3 + 1, m[1] + m[3] - 4, 92 - m[4] * 3 + 3), "#e0501f")
end
S.ridge(c, "#f5cf6a", 76, { {4, 31, 0}, {2, 11, 1} })
S.ridge(c, "#c9a96e", 84, { {3, 23, 2} })
X.layer(c, "ground"); S.ground(c, { walk = "#e8a317", near = "#c9a96e", tuft = "#b07a10", tuftNear = "#9a6b3f", seed = 9, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
X.layer(c, "objects")
local cactus = X.ramp("#4f9a45")
local function saguaro(x, y, h)
  c:part(c:rrect(x - 3, y - h, x + 3, y, 1), cactus, { gloss = false, cres = 2 })
  c:part(c:rrect(x - 11, y - h * 0.6 - 10, x - 7, y - h * 0.6, 1), cactus, { gloss = false, flat = true })
  c:part(c:rrect(x - 11, y - h * 0.6, x - 3, y - h * 0.6 + 3, 1), cactus, { gloss = false, flat = true })
  c:part(c:rrect(x + 7, y - h * 0.5 - 12, x + 11, y - h * 0.5, 1), cactus, { gloss = false, flat = true })
  c:part(c:rrect(x + 3, y - h * 0.5, x + 11, y - h * 0.5 + 3, 1), cactus, { gloss = false, flat = true })
end
saguaro(122, 92, 38)
c:build{ { "rock", c:ellipse(150, 91, 7, 4), "stone", { cres = 3, deep = 1 } } }
X.layer(c, "detail"); c:paint({ ".c.", "ccc" }, 140, 112, { c = "#7a4a1f" }); S.bird(c, 90, 38)

X.save(c, "stage-desert", "scenes", { w = 480, h = 270, cap = 32 })
