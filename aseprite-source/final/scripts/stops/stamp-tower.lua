local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local disc = c:ellipse(31.5, 31.5, 25.5, 25.5)
local ring = c:ellipse(31.5, 31.5, 21.5, 21.5):cut(c:ellipse(31.5, 31.5, 18.5, 18.5))
local shaft = c:poly({ {25, 25}, {39, 25}, {43, 47}, {21, 47} })
local batt = c:rect(23, 21, 40, 25)
batt:add(c:rect(23, 17, 26, 21)); batt:add(c:rect(30, 17, 33, 21)); batt:add(c:rect(37, 17, 40, 21))
local baseL = c:rect(19, 46, 44, 48)
local flame = c:ellipse(31.5, 14, 3, 3)
flame:add(c:poly({ {28, 14}, {35, 14}, {32, 8}, {31, 8} }))

c:build{
  { "disc",  disc,  GV.ramp("#e8d9b0") },
  { "ring",  ring,  GV.ramp("#5b6470") },
  { "shaft", shaft, GV.ramp("#8b8f96") },
  { "batt",  batt,  GV.ramp("#5b6470") },
  { "baseL", baseL, GV.ramp("#5b6470"), { flat = true } },
  { "flame", flame, GV.ramp("#f08a24"), { gloss = false } },
}
-- dotted outer ring: 2x2 dots around r25
for i = 0, 23 do
  local a = i * math.pi * 2 / 24
  local x = math.floor(31.5 + 23.5 * math.cos(a) - 0.5 + 0.5)
  local y = math.floor(31.5 + 23.5 * math.sin(a) - 0.5 + 0.5)
  c:fill(c:rect(x, y, x + 1, y + 1), "#5b6470")
end
-- thin inner ring r19
c:fill(c:ellipse(31.5, 31.5, 18.5, 18.5):cut(c:ellipse(31.5, 31.5, 17.5, 17.5)):cut(shaft):cut(batt):cut(baseL), "#8b8f96")
-- window slit
c:fill(c:rrect(30, 31, 33, 38, 1), "#3d2a1c")
-- flame core
c:fill(c:ellipse(31.5, 14.5, 1.5, 1.5), "#f5cf6a")
c:px(31, 11, "#f5cf6a")
-- stone courses
c:paint({ "ssss.....ssss" }, 26, 41, { s = "#6b7079" })

local t = c:save(O .. "aseprite/stops/stamp-tower.aseprite", O .. "png/stops/stamp-tower.png")
print(GV.report(t))
