local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pouch body: plump sack, slightly wider at the bottom
local body = c:ellipse(32, 37, 18, 16)
body:add(c:ellipse(32, 42, 19, 11))
local neck = c:rrect(23, 16, 41, 23, 3)
local ruffle = c:ellipse(25.5, 12, 5.5, 4):add(c:ellipse(38.5, 12, 5.5, 4)):add(c:ellipse(32, 11, 4, 3.5))
local cord = c:line({ {21, 20}, {43, 20} }, 2)
local endL = c:line({ {21, 21}, {18, 28} }, 2)
local endR = c:line({ {42, 21}, {45, 28} }, 2)
local patch = c:ellipse(32, 39, 9, 8)

local p = c:build{
  { "body",   body,   "#f1ece0" },
  { "neck",   neck,   "#dcb06a" },
  { "ruffle", ruffle, "#f1ece0", { cres = 2, deep = 1 } },
  { "endL",   endL,   "#8c4a1a", { flat = true } },
  { "endR",   endR,   "#8c4a1a", { flat = true } },
  { "cord",   cord,   "#8c4a1a", { flat = true } },
  { "patch",  patch,  "#f4f0e0", { gloss = false, cres = 2, deep = 1 } },
}
-- ruffle gather lines
c:px(28, 13, GV.R.cream.shade); c:px(36, 13, GV.R.cream.shade)
c:px(28, 14, GV.R.cream.shade); c:px(36, 14, GV.R.cream.shade)
-- cord tassel knots
c:fill(c:rect(17, 28, 19, 30), "#8c4a1a"); c:px(17, 28, "#b0703a")
c:fill(c:rect(44, 28, 46, 30), "#8c4a1a"); c:px(44, 28, "#b0703a")

-- edge stitch on pouch
local st = body:copy():cut(neck:grow(2)):cut(patch:grow(1))
c:stitch(st, { side = "lit" })

-- gold ring on patch
c:fill(patch:copy():cut(patch:shrink(1)), "#e8a317")

-- okra seed: tilted pill
local seed = c:line({ {27, 43}, {36, 35} }, 4)
c:part(seed, "gold", { cres = 1, deep = 1, gloss = { 29, 40 } })
c:fill(c:rect(36, 33, 38, 35), "#2e5a2c"); c:px(36, 33, "#4a8a3e")

c:button(30, 18)

local t = c:save(O .. "aseprite/ph/okra-seed.aseprite", O .. "png/ph/okra-seed.png")
print(GV.report(t))
