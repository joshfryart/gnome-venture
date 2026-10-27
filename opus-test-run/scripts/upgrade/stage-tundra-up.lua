-- stage-tundra-up v3: adds a pale back range, side boulders/ice crystals/spruces, signpost, footprints, falling snow. v2 was: pale blue sky, faceted ice peaks, rolling snow hills with shaded slopes, a frozen pond, spruces, a small igloo, drifts with grass tufts, sparkles.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S; S.theme = "tundra"
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#c8ecdc", "#f1ece0" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 140, 24, 1.1); S.cloud(c, 204, 44, 0.6); S.cloud(c, 90, 38, 0.6)
X.layer(c, "far")
-- back range: pale distant peaks behind the main three (depth layer)
for _, pk in ipairs({ { 8, 52, 30 }, { 76, 50, 30 }, { 152, 48, 32 }, { 232, 54, 28 } }) do H.peak(c, pk[1], pk[2], pk[3], 84, "#c8ecdc", "#a9d6ea", "#eef8f2") end
H.peak(c, 40, 42, 36, 84, "#a9d6ea", "#8fcbd8", "#f1ece0", "#c8ecdc"); H.peak(c, 110, 34, 46, 84, "#a9d6ea", "#8fcbd8", "#f1ece0", "#c8ecdc"); H.peak(c, 196, 40, 42, 84, "#a9d6ea", "#8fcbd8", "#f1ece0", "#c8ecdc")
S.ridge(c, "#c8ecdc", 70, { { 4, 33, 2 }, { 2, 13, 0 } }); S.ridge(c, "#f1ece0", 80, { { 3, 25, 1 } })
-- shaded slopes (right side of each hill): hard-edged teal-white wedges
for _, hx in ipairs({ 50, 130, 210 }) do c:fill(c:poly({ { hx, 79 }, { hx + 22, 79 }, { hx + 30, 92 }, { hx + 6, 92 } }), "#c8ecdc") end
-- small igloo far left (calm side, low contrast, no outline)
c:fill(c:ellipse(30, 86, 11, 8):cut(c:rect(15, 87, 50, 95)), "#eef8f2"); c:fill(c:ellipse(30, 86, 4, 4):cut(c:rect(22, 87, 38, 95)), "#8fcbd8")
X.layer(c, "ground"); S.ground(c, { walk = "#f1ece0", near = "#c8ecdc", tuft = "#a9d6ea", tuftNear = "#8fcbd8", seed = 3, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
X.layer(c, "objects")
-- frozen pond: pale ice with a crack and a lit rim, in the centre mid ground
c:fill(c:ellipse(120, 99, 26, 5), "#a9d6ea"); c:fill(c:ellipse(120, 98, 24, 3), "#c8ecdc"); c:fill(c:rect(110, 99, 122, 99), "#eef8f2"); c:fill(c:rect(121, 100, 128, 100), "#eef8f2")
local function spruce(x, y, s)
  c:part(c:rect(x - 1, y - 6 * s, x + 1, y), H.WOOD, { gloss = false, flat = true })
  for i = 0, 2 do
    local w, ty = (11 - i * 2.5) * s, y - 5 * s - i * 10 * s
    c:part(c:poly({ { x - w, ty }, { x, ty - 14 * s }, { x + w, ty } }), H.PINE, { gloss = false, cres = 2, deep = 0 })
    c:fill(c:poly({ { x - w * 0.55, ty - 5 * s }, { x, ty - 14 * s }, { x + w * 0.55, ty - 5 * s } }), "#f1ece0")
  end
end
spruce(98, 93, 1); spruce(146, 92, 0.85); spruce(160, 94, 0.6)
c:part(c:poly({ { 82, 94 }, { 86, 84 }, { 94, 80 }, { 100, 86 }, { 101, 94 } }), H.flat("#a9d6ea", "#8fcbd8", "#eef8f2"), { gloss = false, cres = 3, deep = 0 })
-- side-third props: snow-capped boulders and ice crystals (centre kept clear)
H.rock(c, 22, 112, 9, 5); c:fill(c:ellipse(21, 108, 7, 2), "#f1ece0")
H.rock(c, 222, 114, 10, 6); c:fill(c:ellipse(221, 109, 8, 2), "#f1ece0")
local ICE = H.flat("#a9d6ea", "#8fcbd8", "#eef8f2")
c:part(c:poly({ { 196, 112 }, { 199, 96 }, { 203, 112 } }), ICE, { gloss = false, cres = 2, deep = 0 })
c:part(c:poly({ { 202, 112 }, { 206, 101 }, { 210, 112 } }), ICE, { gloss = false, cres = 2, deep = 0 })
c:part(c:poly({ { 40, 116 }, { 43, 104 }, { 46, 116 } }), ICE, { gloss = false, cres = 2, deep = 0 })
spruce(12, 96, 0.7); spruce(232, 97, 0.75); spruce(62, 92, 0.5)
-- sign post on the right edge pointing onward
c:part(c:rect(178, 102, 179, 114), H.WOOD, { gloss = false, flat = true })
c:part(c:poly({ { 172, 101 }, { 185, 101 }, { 188, 104 }, { 185, 107 }, { 172, 107 } }), H.WOOD, { gloss = false, flat = true })
c:fill(c:rect(173, 100, 185, 100), "#f1ece0")
X.layer(c, "detail")
-- footprints in the snow leading to the igloo
for i = 0, 4 do c:px(34 + i * 5, 101 + (i % 2), "#8fcbd8") end
-- light falling snow, denser at the sides
local r = H.rng(11)
for i = 1, 60 do local x = r(240); local y = 20 + r(80); if x < 80 or x > 160 or i % 3 == 0 then c:px(x, y, "#eef8f2") end end
for _, p in ipairs({ { 30, 120 }, { 60, 125 }, { 200, 118 }, { 170, 124 }, { 110, 122 }, { 14, 104 }, { 226, 106 } }) do c:paint({ "x...x", ".xxx." }, p[1], p[2], { x = "#8fcbd8" }) end
for _, t in ipairs({ { 44, 99 }, { 190, 98 }, { 76, 108 }, { 214, 112 } }) do c:paint({ "x.x", ".x." }, t[1], t[2], { x = "#c9a96e" }) end   -- dry grass poking through the snow
for _, sp in ipairs({ { 70, 50 }, { 180, 60 }, { 120, 70 }, { 20, 76 }, { 226, 78 } }) do H.sparkle(c, sp[1], sp[2], "#eef8f2") end
H.birds(c, { { 150, 36 } })
X.save(c, "stage-tundra-up", "scenes", { w = 480, h = 270, cap = 32 })
