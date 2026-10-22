local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- spine dome with scalloped spikes along the top
local dome = c:ellipse(29.5, 41, 17, 19):cut(c:rect(0, 42, 63, 63))
local spikes = {
  { {13, 35}, {11, 27}, {18, 30} },
  { {16, 27}, {17, 19}, {24, 24} },
  { {22, 23}, {27, 15}, {31, 22} },
  { {30, 22}, {36, 15}, {38, 24} },
  { {37, 25}, {44, 20}, {43, 30} },
}
for _, s in ipairs(spikes) do dome:add(c:poly(s)) end
local feet = c:rrect(18, 39, 22, 45, 1):add(c:rrect(37, 39, 41, 45, 1))
local snout = c:poly({ {35, 29}, {41, 29}, {52, 37}, {52, 42}, {41, 45}, {35, 45} })
snout:add(c:ellipse(39, 37, 6, 8))
local ear = c:ellipse(37.5, 29.5, 2.5, 2.5)
local nose = c:ellipse(51.5, 39.5, 2.5, 2.5)

local p = c:build{
  { "feet", feet, "#dcb06a", { flat = true } },
  { "dome", dome, "#6a4528" },
  { "snout", snout, "#dcb06a" },
  { "ear", ear, "#dcb06a", { gloss = false } },
  { "nose", nose, "#3a2418", { gloss = { 50, 38 } } },
}
-- spine highlight arcs on upper left
local hl = c:line({ {17, 37}, {18, 33}, {21, 29} }, 2):add(c:line({ {22, 38}, {23, 34}, {26, 31} }, 2))
c:fill(hl:clip(p.dome.m), "#8a4f2a")
c:eye(40, 32)
local t = c:save(O .. "aseprite/ico/ico-hedgehog.aseprite", O .. "png/ico/ico-hedgehog.png")
print(GV.report(t))
