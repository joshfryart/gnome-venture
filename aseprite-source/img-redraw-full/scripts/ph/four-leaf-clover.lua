local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stemR = GV.ramp("#58a03e")
local stemL = GV.ramp("#7ab55c")
local brown = GV.ramp("#8c4a1a")

local mound = c:ellipse(31.5, 52, 15, 3.5)
local paths = {
  { {30, 50}, {24, 40}, {16, 28}, {12, 20}, {10, 16} },
  { {31, 50}, {27, 38}, {22, 26}, {19, 17} },
  { {31, 50}, {31, 30}, {31, 17} },
  { {32, 50}, {36, 38}, {41, 26}, {44, 17} },
  { {33, 50}, {39, 40}, {47, 28}, {51, 20}, {53, 16} },
}
local leaves = { {9, 12}, {19, 12}, nil, {44, 12}, {54, 12} }

local list = { { "mound", mound, brown } }
for i, p in ipairs(paths) do
  if i ~= 3 then
    local l = leaves[i]
    list[#list + 1] = { "stem" .. i, c:line(p, 3), i == 1 and stemL or stemR, { flat = true, contact = false } }
    list[#list + 1] = { "leaf" .. i, c:ellipse(l[1], l[2], 4, 4), i == 1 and stemL or stemR, { contact = false } }
  end
end
list[#list + 1] = { "stem3", c:line(paths[3], 3), stemR, { flat = true, contact = false } }
list[#list + 1] = { "hub", c:ellipse(31, 12.5, 4, 4), brown }
c:build(list)
c:ground(31.5, 56, 14, 1.5)

local t = c:save(O .. "aseprite/ph/four-leaf-clover.aseprite", O .. "png/ph/four-leaf-clover.png")
print(GV.report(t))
