-- stage-desert v2: warm haze sky with a pale sun, striped red mesas, rock arch, layered shaded dunes, saguaros and barrel cacti, tumbleweed,
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#f2e4c0", "#fff3c8" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 160, 22, 0.7); S.cloud(c, 100, 36, 0.5)
c:fill(c:ellipse(34, 19, 13, 13), "#f2e4c0"); S.sun(c, 34, 19)
X.layer(c, "far")
-- mesas with strata stripes (ember family) and a lit left edge
local function mesa(cx, top, w, hgt)
  c:fill(c:poly({ { cx - w, 90 }, { cx - w + 3, top }, { cx + w - 3, top }, { cx + w, 90 } }), "#a8582f")
  for i = 0, 3 do local y = top + 1 + i * (hgt / 4); c:fill(c:rect(cx - w + 3 - i, y, cx + w - 3 + i, y + hgt / 8), ({ "#e0501f", "#d6322b", "#e0501f", "#a8582f" })[i + 1]) end
  c:fill(c:rect(cx - w + 3, top, cx + w - 3, top + 1), "#f08a24")
end
mesa(48, 52, 24, 38); mesa(190, 46, 30, 44); mesa(236, 62, 12, 28)
-- rock arch in the middle distance
c:fill(c:rect(108, 64, 116, 84), "#a8582f"); c:fill(c:rect(130, 64, 138, 84), "#a8582f"); c:fill(c:rect(108, 58, 138, 66), "#d6322b"); c:fill(c:rect(116, 66, 130, 84), "#f2e4c0")
S.ridge(c, "#f5cf6a", 80, { { 4, 31, 0 }, { 2, 11, 1 } })
S.ridge(c, "#d9a660", 87, { { 3, 23, 2 } })
-- shaded lee sides of the dunes
for _, dx in ipairs({ 20, 90, 160, 220 }) do c:fill(c:poly({ { dx, 82 }, { dx + 18, 90 }, { dx + 4, 92 } }), "#c9a96e") end
X.layer(c, "ground"); S.ground(c, { walk = "#e8a317", near = "#c9a96e", tuft = "#d0862a", tuftNear = "#9a6b3f", seed = 9, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
X.layer(c, "objects")
local function saguaro(x, y, h)
  local g = H.LEAF
  c:part(c:rrect(x - 3, y - h, x + 3, y, 2), g, { gloss = false, cres = 2, deep = 0 })
  c:part(c:rrect(x - 11, y - h * 0.62 - 9, x - 7, y - h * 0.62, 1), g, { gloss = false, flat = true }); c:part(c:rrect(x - 11, y - h * 0.62, x - 3, y - h * 0.62 + 3, 1), g, { gloss = false, flat = true })
  c:part(c:rrect(x + 7, y - h * 0.5 - 11, x + 11, y - h * 0.5, 1), g, { gloss = false, flat = true }); c:part(c:rrect(x + 3, y - h * 0.5, x + 11, y - h * 0.5 + 3, 1), g, { gloss = false, flat = true })
  c:fill(c:rect(x, y - h + 1, x, y - 2), "#4f9a45")
  c:fill(c:rect(x - 1, y - h - 1, x + 1, y - h), "#e46a9b")                                  -- a bloom on top
end
saguaro(120, 93, 36); saguaro(160, 92, 24)
c:part(c:ellipse(92, 91, 6, 5), H.LEAF, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(91, 86, 93, 86), "#e46a9b")   -- barrel cactus
c:build{ { "rock", c:ellipse(142, 92, 7, 4), H.STONE, { gloss = false, cres = 2, deep = 0 } } }
c:fill(c:ellipse(76, 93, 4, 4), "#9a6b3f"); c:fill(c:ellipse(76, 93, 2, 2), "#c9a96e")  -- tumbleweed
X.layer(c, "detail")
c:paint({ "x.x.x", ".x.x." }, 60, 120, { x = "#9a6b3f" }); c:paint({ "x.x.x", ".x.x." }, 150, 118, { x = "#9a6b3f" }); c:paint({ "x.x", ".x." }, 200, 122, { x = "#9a6b3f" })
for _, h in ipairs({ { 40, 78 }, { 140, 74 }, { 210, 80 } }) do c:fill(c:rect(h[1], h[2], h[1] + 10, h[2]), "#fff3c8") end   -- heat shimmer
S.bird(c, 186, 30)
X.save(c, "stage-desert", "scenes", { w = 480, h = 270, cap = 32 })
