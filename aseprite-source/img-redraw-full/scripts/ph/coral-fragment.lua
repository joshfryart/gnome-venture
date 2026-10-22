local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- one fused coral mass so it reads as a single antler
local coral = c:rrect(27, 34, 37, 55, 2)
coral:add(c:line({ {30, 44}, {24, 34}, {18, 25} }, 6))
coral:add(c:ellipse(17.5, 21.5, 4.5))
coral:add(c:line({ {34, 40}, {41, 30}, {46, 22} }, 6))
coral:add(c:ellipse(46.5, 18.5, 4.5))
coral:add(c:line({ {32, 38}, {32, 14} }, 6))
coral:add(c:ellipse(32, 12, 4.5))
-- small side nub on left arm for asymmetry
coral:add(c:line({ {22, 31}, {16, 34} }, 4))
coral:add(c:ellipse(15, 34.5, 2.5))
coral = coral:closed(2)

local p = c:build{
  { "coral", coral, "petal" },
}
-- flat broken cut face at the bottom
c:fill(c:ellipse(32, 54, 4.5, 1.5), "#f6b8cf")
c:paint({ "..ppppp..", ".p.....p." }, 28, 52, { p = "#c8507e" })
-- pore dots
local pores = { {30,48},{34,44},{31,40},{33,34},{31,28},{33,22},{25,36},{21,30},{39,34},{43,27},{19,22},{46,18},{33,52} }
for _, q in ipairs(pores) do
  if coral:has(q[1], q[2]) then c:px(q[1], q[2], "#f6b8cf") end
end

local t = c:save(O .. "aseprite/ph/coral-fragment.aseprite", O .. "png/ph/coral-fragment.png")
print(GV.report(t))
