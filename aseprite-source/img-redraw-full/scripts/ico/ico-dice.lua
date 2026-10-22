local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:rrect(9, 9, 55, 55, 9)
local p = c:build{
  { "die", body, "red", { stitch = true, gloss = { 15, 14 } } },
}
local cream = GV.ramp("#f8eed2")
local pips = { {21, 21}, {43, 21}, {32, 32}, {21, 43}, {43, 43} }
for _, q in ipairs(pips) do
  local m = c:ellipse(q[1], q[2], 4.5, 4.5)
  c:fill(m, "#f8eed2")
  -- small inset shade on lower-right for depth (pip is a dimple)
  c:fill(m:copy():cut(m:shift(-1, -1)), "#dcc79a")
end

local t = c:save(O .. "aseprite/ico/ico-dice.aseprite", O .. "png/ico/ico-dice.png")
print(GV.report(t))
