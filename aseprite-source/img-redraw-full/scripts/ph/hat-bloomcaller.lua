local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local brim = c:ellipse(32, 48, 22, 6)
local cone = c:poly({ {14,46}, {18,34}, {22,24}, {26,17}, {31,12}, {37,9}, {43,8}, {48,10}, {47,13}, {42,14}, {38,17},
  {39,24}, {43,34}, {50,46} })
local band = c:rect(14, 39, 50, 46):clip(cone:copy():add(c:rect(14, 39, 50, 46)))
local fl = c:mask()
local cx, cy = 31, 28
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  fl:add(c:ellipse(cx + 4.2 * math.cos(a), cy + 4.2 * math.sin(a), 2.2, 2.2))
end
local p = c:build{
  { "brim", brim, "red" },
  { "cone", cone, "petal", { stitch = { side = "lit" }, gloss = { 24, 22 } } },
  { "band", band, "red", { gloss = false } },
  { "flower", fl, GV.ramp("#f6b8cf"), { gloss = false, contour = "#4a2c1a" } },
  { "centre", c:ellipse(cx, cy, 2, 2), "gold", { flat = true } },
  { "bobble", c:ellipse(49, 10, 3, 3), "gold", { gloss = { 48, 9 } } },
}
c:seam({ {15, 40}, {49, 40} })
c:button(15, 41)
c:ground(32, 56, 22, 2.5)
local t = c:save(O .. "aseprite/ph/hat-bloomcaller.aseprite", O .. "png/ph/hat-bloomcaller.png")
print(GV.report(t))
