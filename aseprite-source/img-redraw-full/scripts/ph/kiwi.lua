local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ball = c:ellipse(31.5, 37, 16, 15)
-- cut crescent: lower band of the ball, curved top edge
local cut = ball:copy():clip(c:ellipse(31.5, 58, 24, 18))
local stalk = c:rect(31, 15, 33, 23)
local leaf = c:poly({ {33, 17}, {36, 11}, {41, 6}, {45, 6}, {44, 10}, {40, 15}, {35, 19} })
local p = c:build{
  { "stalk", stalk, "#2f5a2a", { flat = true } },
  { "ball", ball, GV.ramp("#a5663a"), { gloss = { 22, 28 } } },
  { "cut", cut, GV.ramp("#58a03e", { rim = "#c8d77a" }), { gloss = false, cres = 2, deep = 1 } },
  { "leaf", leaf, "moss", { gloss = false } },
}
-- fuzz speckles
local fz = { {26,34},{31,31},{37,33},{41,38},{22,38},{28,38},{34,37},{39,29},{25,30},{44,34},{30,26} }
for _, q in ipairs(fz) do
  local x, y = q[1], q[2]
  c:px(x, y, (x + y > 72) and "#8a4f2a" or "#d0862a")
end
-- pale core and seeds in the flesh
c:fill(c:ellipse(31.5, 47, 6, 1.5), "#e6f0b0")
for _, q in ipairs({ {24,46},{27,44},{36,44},{39,46},{31,49},{32,44} }) do c:px(q[1], q[2], "#2a1a10") end
-- leaf midrib
c:line({ {35, 17}, {42, 8} }, 1)
c:fill(c:line({ {35, 17}, {42, 8} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/kiwi.aseprite", O .. "png/ph/kiwi.png")
print(GV.report(t))
