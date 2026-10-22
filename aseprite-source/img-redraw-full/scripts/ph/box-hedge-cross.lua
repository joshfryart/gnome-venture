local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plus = c:rrect(9, 23, 52, 38, 6):add(c:rrect(23, 9, 38, 52, 6))
-- fill the inner corners slightly so the crossing reads as one clipped hedge
plus:add(c:ellipse(30.5, 30.5, 9, 9))
local shadow = plus:shift(2, 3):cut(plus)
local p = c:build{
  { "shadow", shadow, GV.ramp("#6a4528"), { flat = true } },
  { "hedge",  plus,   GV.ramp("#58a03e"), { cres = 5 } },
}
-- leaf-light ridge along each arm top
local L = "#b8d47c"
for x = 12, 49 do if x < 26 or x > 35 then c:px(x, 26, L) end end
for y = 12, 49 do if y < 26 or y > 35 then c:px(26, y, L) end end
for x = 12, 49 do if (x < 26 or x > 35) and x % 3 ~= 0 then c:px(x, 27, "#9cc468") end end
for y = 12, 49 do if (y < 26 or y > 35) and y % 3 ~= 0 then c:px(27, y, "#9cc468") end end
-- clipped leaf clumps
local N = "#7ab55c"
local nubs = { {15,31},{44,30},{31,15},{32,44},{20,34},{35,20} }
for _, n in ipairs(nubs) do
  c:px(n[1], n[2], N); c:px(n[1]+1, n[2], N); c:px(n[1], n[2]+1, N); c:px(n[1]+1, n[2]+1, "#4a8a3e")
end
local t = c:save(B .. "aseprite/ph/box-hedge-cross.aseprite", B .. "png/ph/box-hedge-cross.png")
print(GV.report(t))
