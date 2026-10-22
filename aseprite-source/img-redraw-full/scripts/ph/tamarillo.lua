local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- egg: narrower shoulders, fuller belly, pointed bottom nub
local body = c:ellipse(31.5, 38, 13.5, 12)
body:add(c:ellipse(31.5, 30, 10.5, 11))
body:add(c:poly({ {27, 48}, {37, 48}, {33, 53}, {31, 53} }))
local fruit = GV.ramp("#e46a9b", { shade = "#a8241f", deep = "#6b1b2c", bounce = "#b8452f" })

local stalk = c:line({ {31, 21}, {31, 16}, {33, 12} }, 3)
local leaf = c:poly({ {33, 18}, {35, 13}, {39, 10}, {46, 8}, {43, 13}, {39, 17}, {35, 19} })

local p = c:build{
  { "body", body, fruit, { cres = 8, deep = 3, gloss = { 25, 25 } } },
  { "stalk", stalk, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
}
-- leaf midrib
c:px(35, 17, "#4a8a3e"); c:px(36, 16, "#4a8a3e"); c:px(37, 15, "#4a8a3e")
c:px(38, 14, "#4a8a3e"); c:px(39, 13, "#4a8a3e"); c:px(40, 12, "#4a8a3e")
-- pale light streak (accent)
c:fill(c:rect(21, 31, 21, 37), "#f6b8cf")
c:fill(c:rect(22, 38, 22, 39), "#f6b8cf")
-- tip nub
c:fill(c:rect(31, 51, 32, 52), "#6b1b2c")

local t = c:save(D .. "img-redraw-full/aseprite/ph/tamarillo.aseprite", D .. "img-redraw-full/png/ph/tamarillo.png")
print(GV.report(t))
