-- ph/guide-mena: round sand/terracotta medallion, date palm, crescent + star, stitched gold rim
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cx, cy = 31.5, 31.5
local rim  = c:ellipse(cx, cy, 21)
local face = c:ellipse(cx, cy, 17)
local dune = c:ellipse(31.5, 53, 22, 10):clip(face:copy())

-- palm trunk: gentle curve leaning right at the base
local trunk = c:line({ {35, 47}, {35, 42}, {34, 37}, {32, 32}, {29, 27} }, 3)
-- fronds radiating from the crown (~28,25)
local fr = c:mask()
fr:add(c:line({ {28, 25}, {23, 22}, {18, 24}, {16, 28} }, 3))   -- left drooping
fr:add(c:line({ {28, 24}, {24, 19}, {20, 18} }, 3))             -- up-left
fr:add(c:line({ {28, 24}, {31, 19}, {34, 18} }, 3))             -- up-right
fr:add(c:line({ {29, 25}, {35, 23}, {40, 25}, {42, 29} }, 3))   -- right drooping
fr:add(c:ellipse(28, 25, 3, 2.5))                               -- crown
fr:clip(face:copy())

-- crescent moon top-right, star beside it
local moon = c:ellipse(41, 21, 5):cut(c:ellipse(44, 19, 4.5))
local star = c:ascii({
  "..x..",
  ".xxx.",
  "xxxxx",
  ".xxx.",
  "..x..",
}, 34, 13)

local p = c:build{
  { "rim",   rim,   "gold" },
  { "face",  face,  GV.ramp("#d4a165") },
  { "dune",  dune,  GV.ramp("#c8643a"), { gloss = false } },
  { "trunk", trunk, "wood", { gloss = false } },
  { "frond", fr,    "moss", { gloss = { 21, 20 } } },
  { "moon",  moon,  GV.ramp("#fbeab0"), { flat = true } },
  { "star",  star,  "gold", { flat = true } },
}

-- trunk ring notches
for _, q in ipairs({ {34, 44}, {34, 40}, {33, 36}, {31, 32} }) do
  c:px(q[1], q[2], GV.R.wood.deep)
end

-- hanging dates under the crown
local dateBase, dateDark, dateHi = "#a8402a", "#6b1b2c", "#e07a4a"
for _, q in ipairs({ {24, 28}, {26, 29}, {25, 31}, {31, 28}, {33, 29}, {32, 31} }) do
  local x, y = q[1], q[2]
  c:px(x, y, dateBase); c:px(x + 1, y, dateDark)
  c:px(x, y + 1, dateDark); c:px(x + 1, y + 1, dateDark)
  c:px(x, y, dateHi)
end

-- stitched gold rim: thread dashes running round the gold band, on the sand edge
local pts = {}
for i = 0, 72 do
  local a = i / 72 * 2 * math.pi
  pts[#pts + 1] = { math.floor(cx + 15 * math.cos(a) + 0.5), math.floor(cy + 15 * math.sin(a) + 0.5) }
end
c:seam(pts, { on = 2, off = 1 })

local t = c:save(O .. "aseprite/ph/guide-mena.aseprite", O .. "png/ph/guide-mena.png")
print(GV.report(t))
