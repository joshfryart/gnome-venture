local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- clay tones borrowed from the soil family
local light = GV.ramp("#c9ae90")
local dark  = GV.ramp("#7a5442")
local headR = GV.ramp("#6e4c3c")
local legR  = "#5a3626"

local segs = {
  { 15.5, 37, light },
  { 24.5, 33, dark },
  { 33.5, 33, light },
  { 42,   36, dark },
}
local parts = {}
-- legs (behind everything): a V under each segment
for i, s in ipairs(segs) do
  local x, y = math.floor(s[1]), math.floor(s[2] + 4)
  local v = c:line({ {x, y}, {x - 3, y + 7} }, 2):add(c:line({ {x, y}, {x + 3, y + 7} }, 2))
  parts[#parts + 1] = { "leg" .. i, v, legR, { flat = true, contact = false } }
end
-- feelers with clubs
local f1 = c:line({ {50, 20}, {53, 14} }, 2):add(c:rrect(52, 11, 55, 14, 1))
local f2 = c:line({ {45, 20}, {44, 14} }, 2):add(c:rrect(42, 11, 45, 14, 1))
parts[#parts + 1] = { "feel1", f2, legR, { flat = true } }
parts[#parts + 1] = { "feel2", f1, legR, { flat = true } }
for i, s in ipairs(segs) do
  parts[#parts + 1] = { "seg" .. i, c:ellipse(s[1], s[2], 6, 7.5), s[3], {} }
end
parts[#parts + 1] = { "head", c:ellipse(48, 25.5, 5.5, 5.5), headR }
local p = c:build(parts)
c:eye(49, 23, true)
c:ground(29, 47, 20, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/creature-claybound-millipede.aseprite",
                 D .. "img-redraw-full/png/ph/creature-claybound-millipede.png")
print(GV.report(t))
