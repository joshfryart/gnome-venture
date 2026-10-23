-- stage-wetland: water + leaf; a reed-edged pond across the mid layer, lily pads, cattails, misty teal haze.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#c8ecdc", "#eef8f2" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 24, 1); S.cloud(c, 210, 40, 0.6)
X.layer(c, "far")
S.ridge(c, "#acc47d", 66, { {3, 29, 1} }); S.ridge(c, "#a4b86a", 74, { {2, 19, 2} })
for i = 0, 11 do S.farTree(c, 10 + i * 21, 76 + (i % 3), "#7ab55c") end
c:fill(c:rect(0, 80, 239, 91), "#3f8fb0")                                   -- far pond water
for _, r in ipairs({ {20, 84, 12}, {70, 87, 9}, {128, 83, 14}, {190, 86, 10} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#a9d6ea") end  -- glints
X.layer(c, "ground"); S.ground(c, { walkTop = 92, walk = "#6a9a3a", near = "#4f9a45", tuft = "#2f6a3a", tuftNear = "#2f5a2a", seed = 5, bank = "#7a4a1f", bankDeep = "#3d2a1c" })
X.layer(c, "objects")
local reed = X.ramp("#7ab55c")
local function cattail(x, h)
  c:fill(c:rect(x, 92 - h, x, 92), "#4f9a45")
  c:part(c:rrect(x - 1, 92 - h - 6, x + 1, 92 - h, 1), "wood", { gloss = false, flat = true })
  c:fill(c:rect(x - 3, 92 - h * 0.5, x - 1, 92 - h * 0.5 + 1), "#4f9a45")
end
for _, a in ipairs({ {94, 22}, {99, 28}, {104, 20}, {140, 24}, {146, 30}, {151, 21} }) do cattail(a[1], a[2]) end
for _, p in ipairs({ {118, 87}, {128, 85}, {80, 86}, {164, 88} }) do c:part(c:ellipse(p[1], p[2], 5, 2), reed, { gloss = false, cres = 1, deep = 0 }) end
c:part(c:ellipse(124, 84, 2, 1), X.ramp("petal"), { gloss = false, flat = true })   -- one lily flower
c:build{ { "log", c:rrect(100, 92, 134, 97, 2), "wood", { gloss = false, cres = 2 } } }
X.layer(c, "detail"); S.flowers(c, { {60, 100, "p"}, {170, 102, "g"}, {40, 120, "g"}, {200, 122, "p"} }); S.bird(c, 70, 38)
X.save(c, "stage-wetland", "scenes", { w = 480, h = 270, cap = 32 })
