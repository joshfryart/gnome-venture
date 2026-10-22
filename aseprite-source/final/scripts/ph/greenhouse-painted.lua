local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local house = c:poly({ {9,54},{9,38},{17,21},{48,21},{56,38},{56,54} })
local glass = GV.ramp("#a9d6ea", { rim = "#c8ecdc", gloss = "#e4f6ee" })
local plants = c:ellipse(15, 44, 4, 4):add(c:ellipse(21, 42, 4, 5)):add(c:ellipse(28, 44, 4, 4))
  :add(c:ellipse(36, 42, 4, 5)):add(c:ellipse(43, 44, 4, 4)):add(c:ellipse(50, 44, 4, 4))
  :add(c:rect(12, 44, 53, 48))
plants:clip(house:copy():shrink(2))

local p = c:build{
  { "glass", house, glass, { gloss = { 20, 27 } } },
  { "plants", plants, GV.ramp("#58a03e"), { gloss = false } },
  { "base", c:rrect(8, 48, 57, 56, 2), "stone", { gloss = { 10, 51 } } },
}

-- glazing bars (petal pink)
local pink = "#e46a9b"
local bars = c:mask()
bars:add(c:line({ {10,37},{55,37} }, 2))          -- transom
bars:add(c:line({ {25,21},{25,47} }, 2))
bars:add(c:line({ {32,21},{32,47} }, 2))
bars:add(c:line({ {39,21},{39,47} }, 2))
bars:add(c:line({ {18,21},{18,47} }, 2))  -- fan bars from roof corners
bars:add(c:line({ {47,21},{47,47} }, 2))
-- frame ring inside the glass edge
bars:add(house:copy():cut(house:copy():shrink(2)))
bars:clip(house)
bars:cut(c:rrect(8, 48, 57, 56, 2))
-- keep plants visible over lower bars
local lowerbars = bars:copy():clip(plants):cut(house:copy():cut(house:copy():shrink(2)))
bars:cut(lowerbars)
c:fill(bars, pink)
-- lit top edge on frame
local top = c:line({ {18,21},{47,21} }, 1)
c:fill(top, "#f6b8cf")

-- tomatoes
c:paint({ ".rr.", "rrrr", "rrrr", ".rd." }, 19, 43, { r = "#dd3a2a", d = "#ae2a2a" })
c:paint({ ".rr.", "rrrr", "rrrr", ".rd." }, 40, 42, { r = "#dd3a2a", d = "#ae2a2a" })
c:px(20, 44, "#ffc27a"); c:px(41, 43, "#ffc27a")

-- glass gloss streaks in two panes
c:px(19, 25, "#e4f6ee"); c:px(19, 26, "#e4f6ee"); c:px(20, 24, "#e4f6ee")
c:px(43, 25, "#e4f6ee"); c:px(43, 26, "#e4f6ee")

c:seam({ {11, 51}, {54, 51} })
c:ground(32.5, 57, 25, 2)
local t = c:save(O .. "aseprite/ph/greenhouse-painted.aseprite", O .. "png/ph/greenhouse-painted.png")
print(GV.report(t))
