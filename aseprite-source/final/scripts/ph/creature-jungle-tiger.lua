-- ph/creature-jungle-tiger : chibi tiger cub sitting front-on
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O ="C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"

local orange = GV.ramp("#f08a24")   -- ember family
local ember  = GV.ramp("#e0501f")   -- ember family, darker
local cream  = GV.ramp("#f8eed2")   -- pale (cream-safe)
local STR = "#2a1a10"

local head = c:ellipse(31, 26, 14, 12)
local p = c:build{
  { "tail",  c:line({ {41, 48}, {46, 46}, {49, 42}, {50, 38}, {49, 35} }, 3), ember, { gloss = false } },
  { "ears",  c:ellipse(20, 15, 4.5):add(c:ellipse(42, 15, 4.5)), orange, { gloss = false } },
  { "body",  c:ellipse(31, 42, 12, 9), orange },
  { "belly", c:ellipse(31, 45, 6, 5), cream, { gloss = false } },
  { "feet",  c:ellipse(24.5, 49, 4.5, 2.5):add(c:ellipse(37.5, 49, 4.5, 2.5)), ember, { gloss = false } },
  { "head",  head, orange, { gloss = { 21, 17 } } },
  { "muzzle", c:ellipse(31, 30, 6, 4), cream, { gloss = false } },
}
-- inner ears (pale)
c:fill(c:ellipse(20, 15.5, 2):cut(head), cream.base)
c:fill(c:ellipse(42, 15.5, 2):cut(head), cream.base)

-- tail tip dark band
c:fill(c:line({ {49, 36}, {50, 38} }, 2):clip(p.tail.m), STR)
c:fill(c:line({ {48, 43}, {50, 41} }, 1):clip(p.tail.m), STR)

-- forehead stripes (short bars, middle longest)
c:fill(c:rect(30, 15, 31, 19), STR)
c:fill(c:poly({ {25, 16}, {27, 16}, {27, 19}, {26, 19} }):add(c:rect(25, 16, 26, 18)), STR)
c:fill(c:poly({ {35, 16}, {37, 16}, {36, 19}, {35, 19} }):add(c:rect(36, 16, 37, 18)), STR)
-- cheek stripes (horizontal bars from head edge)
c:fill(c:rect(17, 26, 20, 27):add(c:rect(18, 30, 21, 31)), STR)
c:fill(c:rect(42, 26, 45, 27):add(c:rect(41, 30, 44, 31)), STR)
-- body stripes (side bars)
c:fill(c:rect(20, 38, 21, 43), STR)
c:fill(c:rect(41, 38, 42, 43), STR)

-- eyes, nose, mouth
c:eye(21, 21); c:eye(37, 21)
c:paint({
  "nnnnn",
  ".nnn.",
  "..n..",
  "m.m.m",
  ".m.m.",
}, 29, 27, { n = STR, m = "umber" })

-- toe lines
c:px(24, 49, ember.deep); c:px(37, 49, ember.deep)

local t = c:save(O .. "aseprite/ph/creature-jungle-tiger.aseprite", O .. "png/ph/creature-jungle-tiger.png")
print(GV.report(t))
