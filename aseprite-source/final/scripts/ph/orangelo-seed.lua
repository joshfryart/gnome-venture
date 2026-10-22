local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fruit = c:ellipse(31.5, 25, 12, 11)
local stem = c:line({ {32, 15}, {33, 11} }, 2)
local leaf = c:poly({ {34, 13}, {38, 9}, {44, 8}, {45, 9}, {42, 14}, {36, 15} })
local body = c:rect(11, 32, 52, 56)
local rim = c:rect(11, 31, 52, 35)

c:build{
  { "fruit", fruit, GV.ramp("#f08a24") },
  { "stem",  stem,  "#2e5a2c", { flat = true } },
  { "leaf",  leaf,  GV.ramp("#58a03e"), { gloss = false } },
  { "body",  body,  "wood", { light = body } },
}
-- slats: darker gaps between boards
for _, y in ipairs({ 41, 47 }) do
  c:fill(c:rect(18, y, 45, y), "#5e2f1e")
  c:fill(c:rect(18, y + 1, 45, y + 1), "#d9a660")
end
-- corner posts
c:build{
  { "postL", c:rect(11, 32, 17, 56), GV.ramp("#a8582f") },
  { "postR", c:rect(46, 32, 52, 56), GV.ramp("#a8582f") },
  { "rim",   rim, GV.ramp("#d9a660") },
}
-- wood grain flecks
c:paint({ "gg...g" }, 23, 38, { g = "#8a4f2a" })
c:paint({ "g...gg" }, 29, 44, { g = "#8a4f2a" })
c:paint({ "gg...g" }, 22, 51, { g = "#8a4f2a" })
-- nails
c:fill(c:rect(13, 37, 14, 38), "#e8a317"); c:fill(c:rect(49, 37, 50, 38), "#e8a317")
c:fill(c:rect(13, 51, 14, 52), "#e8a317"); c:fill(c:rect(49, 51, 50, 52), "#e8a317")
c:ground(31.5, 57, 20, 1.5)
local t = c:save(O .. "aseprite/ph/orangelo-seed.aseprite", O .. "png/ph/orangelo-seed.png")
print(GV.report(t))
