-- ph/cloudberry : six gold drupelets in tiers, stem and leaf
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/cloudberry"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local A = GV.R.gold
local B = GV.ramp("#d0862a")
local con = { contour = "#7a3a14" }

c:build{
  { "stem", c:rect(31, 14, 33, 23), GV.ramp("#2f5a2a", { base = "#2f5a2a" }), { flat = true } },
  { "b1", c:ellipse(32, 30, 8), A, con },
  { "b2", c:ellipse(24, 38, 8), A, con },
  { "b3", c:ellipse(40, 38, 8), B, con },
  { "f1", c:ellipse(19.5, 47, 7.5), B, con },
  { "f2", c:ellipse(33, 48, 8), A, con },
  { "f3", c:ellipse(46.5, 47, 7.5), B, con },
  { "leaf", c:poly({ {34,17}, {33,13}, {36,9}, {42,6}, {41,11}, {38,15} }), GV.ramp("#58a03e"), { gloss = false, contact = false } },
}
c:fill(c:line({ {35, 15}, {40, 8} }, 1), "#2f5a2a")
-- pore dashes, lower right of balls
for _, p in ipairs({ {35,34}, {42,42}, {27,42}, {20,50}, {35,52}, {48,51} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 2, p[2]), "#7a3a14")
end
c:ground(32, 57, 17, 2, "#8a4f2a")
local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
