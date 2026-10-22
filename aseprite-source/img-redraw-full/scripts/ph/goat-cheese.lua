local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local top = c:poly({ {7,45}, {30,17}, {38,19}, {57,27}, {57,45} })
local rind = c:rrect(7, 43, 56, 52, 2)
local cheese = GV.ramp("#f5cf6a", { gloss = "#fff3c8" })
local p = c:build{
  { "top", top, cheese, { gloss = { 26, 26 } } },
  { "rind", rind, GV.ramp("#d0862a"), { light = top:copy():add(rind) } },
}
-- holes: dark interior with a lit lower lip
local function hole(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  c:fill(m, "#8a5014")
  local lip = m:copy():cut(m:shift(1, 1))
  m:each(function(x, y) if not m:has(x - 1, y - 1) then c:px(x, y, "#5e2f1e") end end)
  c:fill(m:copy():cut(m:shift(-1, -1)), "#fff1c8")
end
hole(40, 32, 4, 3.5)
hole(24, 37, 3, 2.5)
hole(49, 38, 2, 2)
c:seam({ {10, 44}, {54, 44} })
c:ground(32, 54, 18, 2)
local t = c:save(O .. "aseprite/ph/goat-cheese.aseprite", O .. "png/ph/goat-cheese.png")
print(GV.report(t))
