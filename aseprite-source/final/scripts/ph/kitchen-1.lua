local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local chim = c:rect(40, 15, 47, 30)
local cap = c:rect(39, 12, 48, 16)
local smoke = c:ellipse(46, 8, 3, 2.5):add(c:ellipse(42, 9, 2, 1.5))
local walls = c:rect(12, 34, 52, 55)
local roof = c:poly({ {8, 37}, {32, 18}, {56, 37} })
local eave = c:rrect(8, 35, 56, 38, 1)
local door = c:ellipse(21.5, 47, 4.5, 4):add(c:rect(17, 47, 26, 55))
local win = c:rect(34, 42, 46, 50)
local p = c:build{
  { "smoke", smoke, GV.ramp("#d6c9b6"), { flat = true } },
  { "chim", chim, "stone" },
  { "cap", cap, GV.ramp("#6a6070") },
  { "walls", walls, GV.ramp("#dcb06a") },
  { "roof", roof, "red" },
  { "eave", eave, GV.ramp("#c66b50"), { gloss = false } },
  { "door", door, GV.ramp("#5e2f1e"), { gloss = false } },
  { "win", win, "gold" },
}
-- plank lines on walls (not over door/window)
for _, y in ipairs({ 44, 51 }) do
  for x = 14, 50 do
    if not door:grow(1):has(x, y) and not win:grow(1):has(x, y) then c:px(x, y, "#b8864a") end
  end
end
-- window cross bars
c:fill(c:rect(39, 42, 41, 50), "#5e2f1e")
c:fill(c:rect(34, 45, 46, 46), "#5e2f1e")
c:px(35, 43, "#fff1c8"); c:px(36, 43, "#fff1c8"); c:px(35, 44, "#fff1c8")
c:px(24, 51, "#f5cf6a"); c:px(24, 52, "#e8a317")
c:seam({ {10, 36}, {54, 36} })
c:button(30, 22)
c:ground(32, 57, 23, 2.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/kitchen-1.aseprite", D .. "img-redraw-full/png/ph/kitchen-1.png")
print(GV.report(t))
