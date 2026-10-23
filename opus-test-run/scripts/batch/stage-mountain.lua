-- stage-mountain: stone + dusk-blue peaks with cream snow caps, alpine meadow ground, pine and cairn in the centre.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 160, 22, 0.9); S.cloud(c, 88, 34, 0.6)
X.layer(c, "far")
local function peak(cx, top, w, col, snow)
  local h = 92 - top
  c:fill(c:poly({ {cx - w, 92}, {cx, top}, {cx + w, 92} }), col)
  if snow then c:fill(c:poly({ {cx - w * 0.3, top + h * 0.3}, {cx, top}, {cx + w * 0.3, top + h * 0.3}, {cx + w * 0.1, top + h * 0.2}, {cx - w * 0.05, top + h * 0.34}, {cx - w * 0.15, top + h * 0.2} }), "#f2e4c0") end
end
peak(40, 36, 46, "#c3b2ea", true); peak(116, 24, 60, "#c3b2ea", true); peak(196, 40, 50, "#c3b2ea", true)
peak(78, 52, 40, "#8b8f96", true); peak(158, 50, 44, "#8b8f96", true); peak(232, 56, 34, "#8b8f96", false)
S.ridge(c, "#a4b86a", 84, { {2, 17, 0}, {1.5, 7, 1} })
X.layer(c, "ground"); S.ground(c, { walk = "#a4b86a", near = "#7ab55c", tuft = "#4f9a45", tuftNear = "#2f6a3a", seed = 11 })
X.layer(c, "objects")
local pine = X.ramp("#2f5a2a")
local function fir(x, y, s)
  c:part(c:rect(x - 1, y - 6, x + 1, y), "wood", { gloss = false, flat = true })
  c:part(c:poly({ {x - 9 * s, y - 6}, {x, y - 24 * s}, {x + 9 * s, y - 6} }), pine, { gloss = false, cres = 3 })
  c:part(c:poly({ {x - 6 * s, y - 15 * s}, {x, y - 31 * s}, {x + 6 * s, y - 15 * s} }), pine, { gloss = false, cres = 3 })
end
fir(122, 91, 1); fir(138, 90, 0.8)
c:build{ { "r1", c:ellipse(98, 91, 7, 4), "stone", { cres = 3, deep = 1 } }, { "r2", c:ellipse(104, 88, 5, 4), "stone", { cres = 3, deep = 1 } } }
X.layer(c, "detail"); S.flowers(c, { {90, 100, "g"}, {132, 98, "g"}, {112, 118, "g"}, {30, 122, "g"} }); S.bird(c, 70, 40)
X.save(c, "stage-mountain", "scenes", { w = 480, h = 270, cap = 32 })
