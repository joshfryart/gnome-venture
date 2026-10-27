-- stage-desert-up: cavern-desert stage. Depth: glow orb + mist, hazy far mesas, striped near mesas with shaded right faces, rock arch framing
-- the centre, two dune ridges with lee shadows, walk strip. Props are kept to the side thirds (party stands in x 80..160); centre gets only
-- a low, far arch and faint ripples.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S; S.theme = "desert"
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky"); S.sky(c); S.sun(c, 30, 26); S.cloud(c, 168, 30, 0.7); S.cloud(c, 96, 40, 0.5); S.cloud(c, 214, 42, 0.4)
X.layer(c, "far")
-- hazy distant mesas (single pale tone, no stripes) for an extra depth layer
for _, m in ipairs({ { 14, 66, 14 }, { 86, 70, 18 }, { 150, 68, 12 }, { 222, 64, 16 } }) do
  c:fill(c:poly({ { m[1] - m[3] - 3, 84 }, { m[1] - m[3], m[2] }, { m[1] + m[3], m[2] }, { m[1] + m[3] + 3, 84 } }), "#d9a660")
  c:fill(c:rect(m[1] - m[3], m[2], m[1] + m[3], m[2]), "#f2e4c0")
end
S.ridge(c, "#f2e4c0", 82, { { 2, 17, 0.5 } })
-- near mesas: strata stripes, lit top edge, shaded right face, talus at the foot
local function mesa(cx, top, w, hgt)
  c:fill(c:poly({ { cx - w, 90 }, { cx - w + 3, top }, { cx + w - 3, top }, { cx + w, 90 } }), "#a8582f")
  for i = 0, 3 do local y = top + 1 + i * (hgt / 4); c:fill(c:rect(cx - w + 3 - i, y, cx + w - 3 + i, y + hgt / 8), ({ "#e0501f", "#d6322b", "#e0501f", "#a8582f" })[i + 1]) end
  c:fill(c:poly({ { cx + w - 9, top + 1 }, { cx + w - 3, top + 1 }, { cx + w, 90 }, { cx + w - 6, 90 } }), "#8a4f2a")   -- shadow face
  c:fill(c:rect(cx - w + 3, top, cx + w - 3, top + 1), "#f08a24")
  c:fill(c:poly({ { cx - w - 5, 90 }, { cx - w + 2, 82 }, { cx - w + 6, 90 } }), "#9a6b3f")                      -- talus
  for k = cx - w + 6, cx + w - 10, 7 do c:fill(c:rect(k, top + 3, k, top + hgt * 0.7), "#a8582f") end           -- erosion grooves
end
mesa(40, 50, 26, 40); mesa(196, 44, 30, 46)
-- low far arch in the centre (small, muted so the stage stays calm)
c:fill(c:rect(110, 70, 115, 86), "#a8582f"); c:fill(c:rect(127, 70, 132, 86), "#8a4f2a")
c:fill(c:rect(110, 66, 132, 72), "#d6322b"); c:fill(c:rect(110, 66, 132, 66), "#f08a24")
S.ridge(c, "#f5cf6a", 84, { { 3, 29, 0 }, { 1, 9, 1 } })
S.ridge(c, "#d9a660", 88, { { 2, 21, 2 } })
for _, dx in ipairs({ 14, 58, 176, 222 }) do c:fill(c:poly({ { dx, 86 }, { dx + 16, 91 }, { dx + 3, 92 } }), "#c9a96e") end
X.layer(c, "ground"); S.ground(c, { walk = "#e8a317", near = "#c9a96e", tuft = "#d0862a", tuftNear = "#9a6b3f", seed = 9, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
-- sun-side light streaks on the walk strip and wind ripples
for _, r in ipairs({ { 6, 96, 30 }, { 92, 100, 20 }, { 170, 97, 26 }, { 40, 106, 18 }, { 200, 105, 22 } }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#f5cf6a") end
for _, r in ipairs({ { 20, 116 }, { 110, 119 }, { 184, 115 } }) do c:fill(c:rect(r[1], r[2], r[1] + 12, r[2]), "#9a6b3f") end
X.layer(c, "objects")
local function saguaro(x, y, h)
  local g = H.LEAF
  c:part(c:rrect(x - 3, y - h, x + 3, y, 2), g, { gloss = false, cres = 2, deep = 0 })
  c:part(c:rrect(x - 11, y - h * 0.62 - 9, x - 7, y - h * 0.62, 1), g, { gloss = false, flat = true }); c:part(c:rrect(x - 11, y - h * 0.62, x - 3, y - h * 0.62 + 3, 1), g, { gloss = false, flat = true })
  c:part(c:rrect(x + 7, y - h * 0.5 - 11, x + 11, y - h * 0.5, 1), g, { gloss = false, flat = true }); c:part(c:rrect(x + 3, y - h * 0.5, x + 11, y - h * 0.5 + 3, 1), g, { gloss = false, flat = true })
  c:fill(c:rect(x, y - h + 1, x, y - 2), "#4f9a45")
  c:fill(c:rect(x - 1, y - h - 1, x + 1, y - h), "#e46a9b")
  c:fill(c:ellipse(x + 3, y + 1, 7, 1), "#c9a96e")            -- cast shadow
end
saguaro(22, 96, 40); saguaro(218, 95, 30); saguaro(66, 92, 18)
c:part(c:ellipse(178, 92, 6, 5), H.LEAF, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(177, 86, 179, 86), "#e46a9b")
c:part(c:ellipse(44, 94, 4, 3), H.LEAF, { gloss = false, cres = 2, deep = 0 })
H.rock(c, 194, 98, 8, 4); H.rock(c, 204, 99, 4, 3); H.rock(c, 6, 101, 5, 3)
-- bleached skull and a half-buried bone (side third)
c:paint({ ".ooooo.", "olllllo", "ol.l.lo", "olllllo", ".olllo." }, 228, 104, { o = "#7a4a1f", l = "#f2e4c0" })
c:paint({ "o..o", "lllll", "o..o" }, 52, 108, { o = "#7a4a1f", l = "#f2e4c0" })
c:fill(c:ellipse(160, 101, 4, 4), "#9a6b3f"); c:fill(c:ellipse(160, 101, 2, 2), "#c9a96e")   -- tumbleweed
X.layer(c, "detail")
c:paint({ "x.x.x", ".x.x." }, 60, 122, { x = "#7a4a1f" }); c:paint({ "x.x.x", ".x.x." }, 190, 120, { x = "#7a4a1f" })
for _, h in ipairs({ { 30, 79 }, { 104, 77 }, { 200, 80 } }) do c:fill(c:rect(h[1], h[2], h[1] + 8, h[2]), "#fff3c8") end
S.bird(c, 186, 34); S.bird(c, 60, 46)
X.save(c, "stage-desert-up", "scenes", { w = 480, h = 270, cap = 32 })
