-- bat-down: a soft brown tuft of Echo Bat down, fanned up from a little pinched quill
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- a tuft: a soft gathered puff on a stub of quill, with downy strands splaying up and out
local strands = {
  { {28, 41}, {21, 35}, {16, 28}, {15, 22} },
  { {29, 38}, {25, 29}, {24, 21}, {26, 15} },
  { {32, 37}, {34, 27}, {37, 19}, {41, 14} },
  { {34, 39}, {41, 32}, {46, 26}, {50, 23} },
}
local brown = GV.ramp("#6e5646")
local whole = c:mask()
local parts = {}
for i, pts in ipairs(strands) do
  local m = c:line(pts, 4)
  local z = pts[#pts]
  m:add(c:ellipse(z[1], z[2], 3, 3))
  whole:add(m)
  parts[#parts + 1] = { "s" .. i, m, brown, { light = whole, gloss = false } }
end
local puff = c:ellipse(31, 43, 9, 6.5)
puff:add(c:ellipse(25, 40, 4.5, 4.5)):add(c:ellipse(37, 40, 4.5, 4.5))
whole:add(puff)
local quill = c:line({ {31, 49}, {32, 56} }, 3)
table.insert(parts, 1, { "quill", quill, GV.ramp("#4b3a2f"), { flat = true } })
parts[#parts + 1] = { "puff", puff, brown, { light = whole, gloss = { 26, 39 } } }
local p = c:build(parts)
-- gloss on the strands: one comma on the tallest
c:gloss(p.s2.m, brown, { 24, 24 })

local t = c:save(D .. "final/aseprite/ph/bat-down.aseprite", PNG .. "bat-down.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
