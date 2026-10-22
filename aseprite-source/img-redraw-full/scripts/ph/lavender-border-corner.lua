local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }

-- leafy L bed: top arm runs off the right edge, side arm runs off the bottom
local bed = c:rect(22, 34, 63, 46):add(c:rect(20, 34, 40, 63))
for _, p in ipairs{ {28, 33}, {37, 31}, {46, 32}, {55, 31}, {63, 32} } do
  bed:add(c:ellipse(p[1], p[2], 7, 6))
end
for _, p in ipairs{ {26, 43}, {24, 52}, {25, 61} } do
  bed:add(c:ellipse(p[1], p[2], 6, 6))
end
local leaf = GV.ramp("#58a03e", { rim = "#a4b86a", deep = "#2f5a2a" })
c:build{ { "bed", bed, leaf, { gloss = { 25, 31 } } } }

-- lavender spikes: violet beans with pale lilac florets
local violet = GV.ramp("#7a5cc0")
local spike = { ".vv.", "vvvv", "vvvv", "vvvv", "vvvv", "vvvv", ".vv." }
local tops = { {24, 18}, {33, 16}, {42, 17}, {51, 16}, {60, 17} }
local side = { {12, 34}, {11, 44}, {12, 54} }
local all = {}
for _, p in ipairs(tops) do all[#all + 1] = p end
for _, p in ipairs(side) do all[#all + 1] = p end
local sm = c:mask()
for _, p in ipairs(all) do sm:add(c:ascii(spike, p[1], p[2])) end
c:part(sm, violet, { flat = true, contour = false })
for i, p in ipairs(all) do
  local x, y = p[1], p[2]
  local o = (i % 2 == 0) and 0 or 1
  c:px(x + 1 + o, y + 1, "#c3b2ea")
  c:px(x + 1, y + 3 - o, "#c3b2ea"); c:px(x + 2, y + 3 - o, "#c3b2ea")
  c:px(x + 2 - o, y + 5, "#c3b2ea")
  c:px(x + 3, y + 4, violet.shade); c:px(x + 3, y + 5, violet.shade); c:px(x + 2, y + 6, violet.shade)
end
-- stems tucking the spikes into the bed
for _, p in ipairs(tops) do c:px(p[1] + 1, p[2] + 7, "#4a8a3e"); c:px(p[1] + 2, p[2] + 7, "#4a8a3e") end
for _, p in ipairs(side) do c:px(p[1] + 4, p[2] + 3, "#4a8a3e"); c:px(p[1] + 4, p[2] + 4, "#4a8a3e") end

-- a few blossoms resting on the bed surface
for _, p in ipairs{ {31, 38}, {44, 39}, {56, 38}, {30, 50}, {32, 58} } do
  c:paint({ ".v.", "vlv", ".v." }, p[1], p[2], { v = "#7a5cc0", l = "#c3b2ea" })
end

local t = c:save(D .. "img-redraw-full/aseprite/ph/lavender-border-corner.aseprite",
                 D .. "img-redraw-full/png/ph/lavender-border-corner.png")
print(GV.report(t))
