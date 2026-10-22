local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tin  = GV.ramp("#8b8f96", { shade = "#5b6470", gloss = "#c9c5bc", deep = "#3a4452" })
local lidR = GV.ramp("#c9c5bc", { shade = "#8b8f96", deep = "#5b6470" })
local seedR = GV.ramp("#e8a317", { shade = "#b07a10", gloss = "#fff1c8" })

local p = c:build{
  { "sprout", c:ellipse(47, 12, 3, 4):add(c:rect(45, 14, 46, 18)), "moss", { flat = true } },
  { "body", c:rrect(12, 29, 52, 55, 3), tin, { cres = 4 } },
  { "lid", c:rrect(10, 17, 54, 30, 3), lidR, { cres = 3, deep = 1, gloss = { 15, 20 } } },
  { "hingeL", c:rrect(14, 27, 17, 31, 1), "#5b6470", { flat = true } },
  { "hingeR", c:rrect(47, 27, 50, 31, 1), "#5b6470", { flat = true } },
  { "label", c:rrect(20, 37, 44, 52, 4), GV.ramp("#f4f0e0"), { cres = 2, deep = 1, gloss = false } },
  { "seed", c:ellipse(32, 45, 4, 5):add(c:poly({{29,43},{35,43},{32,38}})), seedR, { cres = 2, deep = 1, gloss = { 30, 43 } } },
}
-- gold rim round the label
local rim = c:rrect(20, 37, 44, 52, 4):edge()
rim:cut(p.seed.m)
c:fill(rim, "#e8a317")
-- lid lip line
c:fill(c:rect(19, 29, 45, 30), "#5b6470")
c:fill(c:rect(11, 29, 13, 30), "#5b6470"); c:fill(c:rect(51, 29, 53, 30), "#5b6470")
-- seam on the lid join
c:seam({ {14, 28}, {50, 28} })
-- latch tab with a button
c:fill(c:rrect(29, 28, 34, 33, 1), "#e8a317")
c:button(30, 29)
-- seed split line
c:px(33, 44, "#b07a10"); c:px(33, 45, "#b07a10"); c:px(33, 46, "#b07a10")

local t = c:save(B .. "aseprite/ph/marigold-seed.aseprite", B .. "png/ph/marigold-seed.png")
print(GV.report(t))
