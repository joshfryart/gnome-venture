-- stage-mountain v2: faceted snow peaks in three depths, pine foothills, a waterfall with mist, alpine meadow, boulders, signpost.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }
X.layer(c, "sky"); S.sky(c); S.sun(c, 30, 19); S.cloud(c, 80, 26, 0.9); S.cloud(c, 170, 14, 0.7); S.cloud(c, 214, 34, 0.55)
X.layer(c, "far")
local d1 = X.ramp("#c3b2ea")   -- haze violet for the farthest peaks
H.peak(c, 34, 30, 40, 92, d1.base, d1.shade, "#f2e4c0", "#c9c5bc")
H.peak(c, 118, 14, 54, 92, d1.base, d1.shade, "#f2e4c0", "#c9c5bc")
H.peak(c, 200, 26, 46, 92, d1.base, d1.shade, "#f2e4c0", "#c9c5bc")
H.peak(c, 70, 46, 36, 92, "#8b8f96", "#5b6470", "#f2e4c0", "#c9c5bc")
H.peak(c, 160, 44, 40, 92, "#8b8f96", "#5b6470", "#f2e4c0", "#c9c5bc")
H.peak(c, 236, 54, 30, 92, "#8b8f96", "#5b6470")
-- waterfall down the nearer grey peak: a white-blue ribbon with a mist puff at the foot
c:fill(c:rect(162, 58, 165, 80), "#a9d6ea"); c:fill(c:rect(163, 58, 163, 80), "#eef8f2"); c:fill(c:ellipse(163, 82, 6, 3), "#eef8f2")
H.pines(c, "#acc47d", 76, 9, 14, 3, 91); H.pines(c, "#7ab55c", 84, 11, 13, 8, 91)
X.layer(c, "ground"); S.ground(c, { walk = "#a4b86a", near = "#7ab55c", tuft = "#4f9a45", tuftNear = "#2f6a3a", seed = 11 })
X.layer(c, "objects")
local pine = H.PINE
local function fir(x, y, s)
  c:build{ { "t", c:rect(x - 1, y - 6 * s, x + 1, y), H.WOOD, { gloss = false } },
    { "a", c:poly({ { x - 11 * s, y - 5 * s }, { x, y - 26 * s }, { x + 11 * s, y - 5 * s } }), pine, { gloss = false, cres = 3, deep = 1 } },
    { "b", c:poly({ { x - 8 * s, y - 15 * s }, { x, y - 36 * s }, { x + 8 * s, y - 15 * s } }), pine, { gloss = false, cres = 3, deep = 1 } } }
end
fir(120, 91, 1); fir(138, 90, 0.7)
c:build{ { "r1", c:ellipse(92, 91, 8, 5), H.STONE, { gloss = false, cres = 3, deep = 1 } }, { "r2", c:ellipse(100, 88, 5, 4), H.STONE, { gloss = false, cres = 2, deep = 1 } } }
X.layer(c, "detail")
S.flowers(c, { { 90, 100, "g" }, { 124, 98, "p" }, { 112, 118, "g" }, { 150, 120, "p" }, { 30, 122, "g" }, { 208, 118, "p" }, { 60, 104, "p" }, { 190, 102, "g" } })
H.birds(c, { { 76, 34 }, { 86, 29 } })
X.save(c, "stage-mountain", "scenes", { w = 480, h = 270, cap = 32 })
