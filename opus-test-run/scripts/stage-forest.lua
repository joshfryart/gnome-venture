-- stage-forest: stage backdrop, 240x135 grid -> 480x270 (2x nearest). Part E: opaque, no border, cap 32.
-- Same sky bands, horizon heights, ground strip and soil bank as stage-grassland (shared.lua) so the lands match.
-- Families: water (sky), moss + leaf (pines, canopy, floor), soil (back trunks, bank), wood (stump), red + cream (toadstools).
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }
local floor, sin = math.floor, math.sin

X.layer(c, "sky")
S.sky(c)

X.layer(c, "far")
-- two rows of pine silhouettes, farther = paler
local function pines(col, base, step, h, off)
  local m = c:rect(0, base, c.W - 1, c.H - 1)
  local x, i = off, 0
  while x < c.W + step do
    local hh = h + ((i * 7) % 3) * 3
    m:poly({ { x - step * 0.6, base + 1 }, { x, base - hh }, { x + step * 0.6 + 1, base + 1 } })
    x, i = x + step, i + 1
  end
  c:fill(m, col)
end
pines("#bdd292", 66, 11, 18, 3)
pines("#acc47d", 76, 13, 16, 9)
-- back trunks: flat soil, no outline (far layer), lit left edge (soil 500 ramp rim #bea761)
X.ramp("#9a6b3f")
for _, t in ipairs({ { 6, 6 }, { 44, 4 }, { 70, 5 }, { 168, 5 }, { 196, 4 }, { 228, 7 } }) do
  c:fill(c:rect(t[1], 0, t[1] + t[2] - 1, 90), "#9a6b3f")
  c:fill(c:rect(t[1], 0, t[1], 90), "#bea761")
end
S.ridge(c, "#a4b86a", 84, { { 1.5, 17, 2 } })

X.layer(c, "ground")
S.ground(c, { walk = "#7ab55c", near = "#4f9a45", tuft = "#2f6a3a", tuftNear = "#2f5a2a", seed = 21 })

X.layer(c, "objects")
-- canopy along the top edge: leaf, outlined, crescent lower right
local can = c:mask()
for x = -4, c.W + 4 do
  local d = 13 + 4 * sin(x / 9) + 3 * sin(x / 4.3 + 1)
  if x > 84 and x < 156 then d = d - 5 + 3 * sin(x / 6) end -- a clearing over the centre
  can:rect(x, -4, x, floor(d))
end
for _, b in ipairs({ { 12, 20, 9, 6 }, { 58, 21, 10, 6 }, { 182, 20, 10, 6 }, { 214, 17, 9, 5 } }) do can:add(c:ellipse(b[1], b[2], b[3], b[4])) end
local leaf = X.ramp("leaf", { dot = "#c8d77a" })
-- centre: an old stump with a moss cap, two toadstools beside it
local stump = c:poly({ { 109, 74 }, { 129, 74 }, { 130, 86 }, { 135, 92 }, { 103, 92 }, { 108, 86 } })
local moss = c:ellipse(119, 74, 11, 3)
c:build{
  { "canopy", can, leaf, { cres = 5, deep = 2 } },
  { "stump", stump, "wood", { gloss = false } },
  { "moss", moss, leaf, { cres = 2, deep = 1, gloss = false } },
  { "stem1", c:rrect(140, 82, 144, 92, 1), "cream", { gloss = false, bounce = false, rim = false, cres = 2, deep = 0 } },
  { "cap1", c:ellipse(142, 80, 8, 5):cut(c:rect(130, 82, 160, 90)), X.ramp("red", { bounce = "#ae2a2a" }), { cres = 3, deep = 1 } },
  { "stem2", c:rrect(152, 87, 154, 92, 1), "cream", { gloss = false, bounce = false, rim = false, cres = 2, deep = 0 } },
  { "cap2", c:ellipse(153, 86, 5, 3):cut(c:rect(140, 87, 170, 95)), X.ramp("red", { bounce = "#ae2a2a" }), { gloss = false, cres = 2, deep = 1 } },
}

X.layer(c, "detail")
-- stump rings and toadstool spots
c:paint({ "..xxxxxxxxxx..", ".x..........x." }, 112, 75, { x = "#8a4f2a" })
for _, p in ipairs({ { 138, 77 }, { 145, 76 }, { 141, 79 }, { 151, 84 } }) do c:paint({ "xx", "xx" }, p[1], p[2], { x = "#f1ece0" }) end
c:px(155, 85, "#f1ece0")
-- fallen leaves (red ramp rim + shade) on the floor, sparse in the side thirds
for _, p in ipairs({ { 96, 98 }, { 118, 104 }, { 160, 100 }, { 132, 116 }, { 104, 121 }, { 30, 118 }, { 205, 121 }, { 150, 125 } }) do
  c:paint({ "ll.", "lbb", ".b." }, p[1], p[2], { l = "#f2793a", b = "#ae2a2a" })
end
X.save(c, "stage-forest", "scenes", { w = 480, h = 270, cap = 32 })
