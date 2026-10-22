local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hill = c:ellipse(31.5, 50, 23, 38):clip(c:rect(0, 0, 63, 50))
local mouthOuter = c:ellipse(31.5, 33, 13, 13):clip(c:rect(0, 0, 63, 33)):add(c:rect(19, 33, 44, 50))
local mouthInner = c:ellipse(31.5, 33, 9, 9):clip(c:rect(0, 0, 63, 33)):add(c:rect(23, 33, 40, 50))
local timber = mouthOuter:copy():cut(mouthInner)
local p = c:build{
  { "hill", hill, "#8b8f96", { gloss = { 18, 22 } } },
  { "timber", timber, "#c4925f", { gloss = false } },
}
c:fill(mouthInner, "#2a1a10")
-- timber inner edge highlight
c:fill(mouthInner:grow(1):cut(mouthInner):clip(timber), "#f0d49a")
-- ladder rails and rungs (wood, inside dark mouth)
local W = "#b07a45"
c:fill(c:rect(26, 31, 27, 50), W)
c:fill(c:rect(36, 31, 37, 50), W)
for _, y in ipairs({ 34, 40, 46 }) do c:fill(c:rect(28, y, 35, y + 1), "#8a4f2a") end
c:px(26, 31, "#ecc58a"); c:px(36, 31, "#ecc58a")
-- rocks on hill
c:spot(c:ellipse(15, 38, 2, 1.5), "#5b6470")
c:spot(c:ellipse(48, 30, 2, 1.5), "#5b6470")
c:spot(c:ellipse(40, 16, 1.5, 1), "#5b6470")
c:part(c:ellipse(51, 45, 4, 3.5), "gold", { gloss = { 49, 43 } })
c:seam({ {19, 28}, {22, 23}, {27, 20}, {32, 19}, {36, 20}, {41, 23}, {44, 28} }, { free = true })
c:button(30, 17)
c:ground(31.5, 51, 22, 1.5)
local t = c:save(O .. "aseprite/ph/lm-delve.aseprite", O .. "png/ph/lm-delve.png")
print(GV.report(t))
