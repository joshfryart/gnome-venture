local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- slim diagonal blade, lower edge bulges, pointed tip upper right
local vane = c:poly({ {17,51}, {12,42}, {13,31}, {20,21}, {30,13}, {42,8}, {53,6},
                      {50,16}, {45,27}, {37,37}, {27,46} })
-- barb notches cut into both edges
vane:cut(c:poly({ {12,36}, {19,35}, {13,32} }))
vane:cut(c:poly({ {19,22}, {26,24}, {22,19} }))
vane:cut(c:poly({ {48,22}, {41,25}, {46,18} }))
vane:cut(c:poly({ {40,35}, {34,36}, {38,31} }))

c:build{
  { "vane",  vane, GV.ramp("#a8c45a") },
  { "quill", c:line({ {13,57}, {18,51} }, 3), "#d9a660", { flat = true } },
  { "shaft", c:line({ {18,51}, {46,13} }, 3), "#e8eeb0", { flat = true, contact = false } },
}
-- barbs, dark green
local barb = GV.ramp("#58a03e").base
for _, s in ipairs({ { {16,43}, {21,44} }, { {22,36}, {27,37} }, { {29,27}, {34,28} },
                     { {32,40}, {37,35} }, { {39,30}, {43,25} } }) do
  c:fill(c:line(s, 1), barb)
end
local t = c:save(O .. "aseprite/ico/ico-feather.aseprite", O .. "png/ico/ico-feather.png")
print(GV.report(t))
