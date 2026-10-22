-- ph/creature-crystal-weaver : slate spider in a pale crystal web
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local web = GV.ramp("#d8d0f5")

-- 1. web threads (pale lilac, flat), pulled in so the halo keeps its margin
local w = c:mask()
for _, s in ipairs({
  { {29,31}, {12,13} }, { {34,31}, {51,13} }, { {31,26}, {31,9} },
  { {28,33}, {11,28} }, { {35,33}, {52,28} },
}) do w:add(c:line(s, 2)) end
-- one cross strand linking the spokes (the woven ring)
w:add(c:line({ {16,22}, {22,17}, {31,15}, {41,17}, {47,22} }, 2))
c:part(w, web, { flat = true, contact = false })

-- 2. legs: bent 2 px lavender, mirrored about x=31.5
local legs = {
  { {25,35}, {17,28}, {11,34} },
  { {25,39}, {15,39}, {9,48} },
  { {26,43}, {19,50}, {16,55} },
  { {27,31}, {20,23}, {14,24} },
}
for _, l in ipairs(legs) do
  c:limb(l)
  local m = {}
  for i, p in ipairs(l) do m[i] = { 63 - p[1] - 1, p[2] } end
  c:limb(m)
end

-- 3. abdomen, 5. head
local p = c:build{
  { "abd",  c:ellipse(31.5, 39, 8.5, 10), "#4a5160" },
  { "head", c:ellipse(31.5, 27.5, 6.5, 5.5), "#6e7685" },
}

-- 4. marks: lavender V and a crystal bead
c:paint({
  "v......v",
  ".v....v.",
  "..v..v..",
  "...vv...",
}, 28, 37, { v = "#8f7fc9" })
c:spot(c:ellipse(31.5, 46, 1.5, 1.5), "#d8d0f5", "#fff3c8")

-- eyes: small locked (head < 20 px)
c:eye(28, 26, true); c:eye(33, 26, true)

local t = c:save(D .. "test100/aseprite/ph/creature-crystal-weaver.aseprite",
                 D .. "test100/png/ph/creature-crystal-weaver.png")
print(GV.report(t))
