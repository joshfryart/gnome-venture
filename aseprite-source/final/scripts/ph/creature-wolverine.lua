local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#44281c")
local fur = GV.ramp("#8c4a1a")
local tan = GV.ramp("#a5663a")
local cream = GV.ramp("#f8eed2")
local dy = 1
local ox = -2
-- tilted fat tail curling up at the right
local function tilted(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dyy = x - cx, y - cy
    local u = dx * ca + dyy * sa; local v = -dx * sa + dyy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local tail = tilted(46, 37 + dy, 6, 11.5, 32)
local tip = tilted(51, 29 + dy, 5, 5, 32):clip(tail)
tail:cut(tip)
local earL = c:ellipse(20.5 + ox, 17 + dy, 5, 5); local earR = c:ellipse(43.5 + ox, 17 + dy, 5, 5)
local ears = earL:copy():add(earR)
local feet = c:ellipse(23 + ox, 53 + dy, 6, 3.5):add(c:ellipse(41 + ox, 53 + dy, 6, 3.5))
local body = c:ellipse(32 + ox, 41 + dy, 16, 13)
local belly = c:ellipse(32 + ox, 45 + dy, 9.5, 8):clip(body)
local head = c:ellipse(32 + ox, 27 + dy, 13, 12)
local brow = c:line({ {15, 17 + dy}, {22, 18 + dy}, {27, 21 + dy}, {30, 23 + dy}, {33, 21 + dy}, {38, 18 + dy}, {45, 17 + dy} }, 5):clip(head)
local muzzle = c:ellipse(32 + ox, 31.5 + dy, 6.5, 4.5)
c:build{
  { "tail", tail, dark },
  { "tip", tip, cream, { pale = true } },
  { "ears", ears, fur },
  { "feet", feet, dark },
  { "body", body, fur },
  { "belly", belly, tan, { flat = true } },
  { "head", head, fur },
  { "brow", brow, dark, { gloss = false } },
  { "muzzle", muzzle, tan, { gloss = false } },
}
-- inner ears
c:fill(c:ellipse(20.5 + ox, 17 + dy, 2.5, 2.5):cut(head), tan.base)
c:fill(c:ellipse(43.5 + ox, 17 + dy, 2.5, 2.5):cut(head), tan.base)
-- nose
c:fill(c:ellipse(32 + ox, 29 + dy, 2.5, 1.5), "#2a1a10")
c:px(29, 28 + dy, "#5e2a3a")
c:eye(19, 21 + dy); c:eye(36, 21 + dy)
-- grumpy little mouth
c:paint({ ".mmm.", "m...m" }, 28, 33 + dy, { m = "#2a1a10" })
c:ground(31, 57 + dy, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-wolverine.aseprite", O .. "png/ph/creature-wolverine.png")
print(GV.report(t))
