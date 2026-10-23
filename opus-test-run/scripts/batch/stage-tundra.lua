-- stage-tundra v2: pale blue sky, faceted ice peaks, rolling snow hills with shaded slopes, a frozen pond, spruces, a small igloo, drifts with grass tufts, sparkles.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#a9d6ea", "#c8ecdc", "#c8ecdc", "#f1ece0" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 140, 24, 1.1); S.cloud(c, 204, 44, 0.6); S.cloud(c, 90, 38, 0.6)
X.layer(c, "far")
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
X.layer(c, "detail")
for _, p in ipairs({ { 30, 120 }, { 60, 125 }, { 200, 118 }, { 170, 124 }, { 110, 122 }, { 14, 104 }, { 226, 106 } }) do c:paint({ "x...x", ".xxx." }, p[1], p[2], { x = "#8fcbd8" }) end
for _, t in ipairs({ { 44, 99 }, { 190, 98 }, { 76, 108 }, { 214, 112 } }) do c:paint({ "x.x", ".x." }, t[1], t[2], { x = "#c9a96e" }) end   -- dry grass poking through the snow
for _, sp in ipairs({ { 70, 50 }, { 180, 60 }, { 120, 70 }, { 20, 76 }, { 226, 78 } }) do H.sparkle(c, sp[1], sp[2], "#eef8f2") end
H.birds(c, { { 150, 36 } })
X.save(c, "stage-tundra", "scenes", { w = 480, h = 270, cap = 32 })
