local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5
local ring = c:ellipse(cx, cy, 22):cut(c:ellipse(cx, cy, 18))
local disc = c:ellipse(cx, cy, 18.5)
local tower = c:poly({ {25, 46}, {28, 29}, {36, 29}, {39, 46} })
local roof = c:poly({ {26, 30}, {32, 22}, {38, 30} })
local sails = c:line({ {22, 17}, {41, 36} }, 2):add(c:line({ {41, 17}, {22, 36} }, 2))
local p = c:build{
  { "ring", ring, "#5b6470", { light = c:ellipse(cx, cy, 22) } },
  { "disc", disc, "#c9a96e", { light = c:ellipse(cx, cy, 22) } },
  { "tower", tower, "#8b8f96" },
  { "roof", roof, "#a8582f" },
  { "sails", sails, "#f1ece0", { flat = true, contour = "#4a2c1a" } },
}
c:outline(sails)
-- perforation dots on the ring (dotted stamp edge)
for i = 0, 15 do
  local a = i * math.pi / 8
  local x = math.floor(cx + 20 * math.cos(a) + 0.5)
  local y = math.floor(cy + 20 * math.sin(a) + 0.5)
  c:px(x, y, "#c9c5bc")
end
c:fill(c:rect(30, 25, 32, 27), "#2a1a10")   -- hub
c:fill(c:rect(31, 41, 33, 45), "#5e2f1e")   -- door
local t = c:save(O .. "aseprite/stops/stamp-mill.aseprite", O .. "png/stops/stamp-mill.png")
print(GV.report(t))
