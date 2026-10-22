local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function tilted(cx, cy, rx, ry, deg)
  local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local fur  = GV.ramp("#a38f80")
local dark = GV.ramp("#8f7060")

local tail = tilted(46, 35, 5.5, 13, 28)
local tip  = tilted(46, 35, 5.5, 13, 28):clip(c:ellipse(51, 23, 6, 6))
local earL = c:ellipse(18, 14, 5)
local earR = c:ellipse(38, 14, 5)
local feet = c:ellipse(20.5, 52, 5.5, 3):add(c:ellipse(35.5, 52, 5.5, 3))
local body = c:ellipse(28, 41, 15, 12)
local belly = c:ellipse(28, 47, 10, 6):clip(body)
local head = c:ellipse(28, 24, 12)
local brow = c:line({ {17, 21}, {21, 18}, {25, 17}, {31, 17}, {35, 18}, {39, 21} }, 3):clip(head)
local snout = c:ellipse(28, 37, 4.5, 11)

c:build{
  { "tail",  tail,  dark },
  { "tip",   tip,   "cream", { gloss = false } },
  { "earL",  earL,  fur },
  { "earR",  earR,  fur },
  { "feet",  feet,  dark },
  { "body",  body,  fur },
  { "belly", belly, "cream", { gloss = false, rim = false } },
  { "head",  head,  fur },
  { "brow",  brow,  dark, { flat = true } },
  { "snout", snout, "cream" },
}
c:fill(c:ellipse(18, 14, 2.5), "#f8eed2")
c:fill(c:ellipse(38, 14, 2.5), "#f8eed2")
c:fill(c:ellipse(28, 46, 3, 2.5), "#3a2530")
c:px(27, 45, "#7a5a6a")
c:eye(18, 21); c:eye(34, 21)
c:ground(28, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/creature-giant-anteater.aseprite", O .. "png/ph/creature-giant-anteater.png")
print(GV.report(t))
