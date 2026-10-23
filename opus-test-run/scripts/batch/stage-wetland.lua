-- stage-wetland v2: misty far willows, a wide pond with lily pads and glints, reed beds, cattails, a log, stepping stones, a heron, dragonflies.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 22, 1); S.cloud(c, 214, 38, 0.6); S.cloud(c, 80, 40, 0.5)
X.layer(c, "far")
S.ridge(c, "#acc47d", 62, { { 3, 29, 1 } }); S.ridge(c, "#a4b86a", 70, { { 2, 19, 2 } })
for i = 0, 10 do local x = 8 + i * 22; c:fill(c:ellipse(x, 66 + (i % 3), 9, 7), "#7ab55c"); c:fill(c:rect(x, 66, x, 80), "#7ab55c") end    -- far willow crowns
for i = 0, 22 do local x = 4 + i * 10; c:fill(c:rect(x, 70 + (i % 3) * 2, x, 80), "#4f9a45") end                                            -- far reeds
c:fill(c:rect(0, 80, 239, 91), "#3f8fb0"); c:fill(c:rect(0, 80, 239, 83), "#a9d6ea")                                                       -- pond with a pale reflected-sky band
for _, r in ipairs({ { 14, 87, 12 }, { 60, 90, 9 }, { 110, 86, 14 }, { 170, 89, 10 }, { 208, 86, 12 } }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#c8ecdc") end
X.layer(c, "ground"); S.ground(c, { walkTop = 92, walk = "#6a9a3a", near = "#4f9a45", tuft = "#2f6a3a", tuftNear = "#2f5a2a", seed = 5, bank = "#7a4a1f", bankDeep = "#3d2a1c" })
X.layer(c, "objects")
for _, a in ipairs({ { 94, 24 }, { 99, 30 }, { 104, 22 }, { 142, 26 }, { 148, 32 }, { 153, 23 }, { 18, 18 }, { 24, 22 }, { 212, 20 }, { 218, 24 } }) do
  local x, h = a[1], a[2]
  c:fill(c:rect(x, 92 - h, x, 92), "#4f9a45"); c:fill(c:rect(x + 1, 92 - h * 0.5, x + 3, 92 - h * 0.5), "#4f9a45")
  c:part(c:rrect(x - 1, 92 - h - 6, x + 1, 92 - h, 1), H.WOOD, { gloss = false, flat = true })
end
for _, p in ipairs({ { 116, 87, 6 }, { 128, 85, 5 }, { 80, 88, 5 }, { 164, 89, 5 }, { 56, 86, 4 } }) do c:part(c:ellipse(p[1], p[2], p[3], 2), H.LEAF, { gloss = false, cres = 1, deep = 0 }) end
c:part(c:ellipse(124, 83, 3, 2), X.ramp("petal", { shade = "#b8452f", deep = "#b8452f", bounce = "#b8452f", gloss = "#e46a9b", dot = "#e46a9b" }), { gloss = false, cres = 1, deep = 0 })
c:build{ { "log", c:rrect(102, 92, 138, 98, 2), H.WOOD, { gloss = false, cres = 2 } }, { "stone1", c:ellipse(152, 94, 5, 3), H.STONE, { gloss = false, cres = 2, deep = 0 } }, { "stone2", c:ellipse(162, 96, 4, 2), H.STONE, { gloss = false, cres = 2, deep = 0 } } }
-- heron: a pale grey bird standing in the shallows, 12 px tall
c:fill(c:ellipse(190, 84, 4, 3), "#c9c5bc"); c:fill(c:rect(194, 74, 195, 82), "#c9c5bc"); c:fill(c:rect(195, 73, 198, 73), "#e8a317"); c:fill(c:rect(189, 87, 189, 90), "#8b8f96"); c:fill(c:rect(191, 87, 191, 90), "#8b8f96")
X.layer(c, "detail")
S.flowers(c, { { 60, 102, "p" }, { 170, 104, "g" }, { 40, 120, "g" }, { 200, 122, "p" }, { 112, 120, "p" } })
for _, d in ipairs({ { 70, 62 }, { 180, 58 } }) do c:fill(c:rect(d[1], d[2], d[1] + 5, d[2]), "#a9d6ea"); c:fill(c:rect(d[1] + 2, d[2] + 1, d[1] + 5, d[2] + 1), "#3f8fb0") end   -- dragonflies
H.birds(c, { { 40, 36 } })
X.save(c, "stage-wetland", "scenes", { w = 480, h = 270, cap = 32 })
