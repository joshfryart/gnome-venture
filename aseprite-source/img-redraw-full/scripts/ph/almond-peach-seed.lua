local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cream = GV.ramp("#f1ece0")
local sand  = GV.ramp("#dcb06a")
local ember = GV.ramp("#f08a24")
local winR  = GV.ramp("#f4f0e0")

-- slightly bulged pot body
local body = c:rrect(13, 19, 51, 56, 5)
body:add(c:ellipse(32, 37, 20, 15))
body:cut(c:rect(0, 0, 63, 18))
local lid = c:poly({ { 17, 11 }, { 47, 11 }, { 51, 17 }, { 13, 17 } })
lid:add(c:rrect(28, 8, 36, 12, 2)) -- knob
local band = c:rect(13, 17, 51, 18)

local p = c:build{
  { "body", body, cream },
  { "lid",  lid,  cream },
  { "band", band, sand, { flat = true } },
  { "frame", c:rrect(18, 23, 46, 50, 6), ember, { gloss = false } },
}
-- window interior
local win = c:rrect(20, 25, 44, 48, 5)
c:fill(win, "#f4f0e0")
c:fill(c:rrect(20, 25, 44, 26, 2):clip(win), "#fff3c8")

-- peach
local peach = c:ellipse(33, 36, 9, 7.5)
peach:add(c:ellipse(29, 38, 6, 5))
c:fill(peach, ember.base)
-- shade lower right
local sh = peach:copy():cut(peach:shift(-2, -2))
c:fill(sh, ember.shade)
-- pink blush arc along upper edge
local arc = peach:copy():cut(peach:shift(1, 2))
c:fill(arc, "#e46a9b")
-- dots
c:fill(c:ellipse(28, 39, 1, 1), "#e46a9b")
c:fill(c:ellipse(33, 36, 1, 1), "#e46a9b")
c:fill(c:ellipse(38, 33, 1, 1), "#e46a9b")
c:px(30, 31, ember.gloss); c:px(31, 31, ember.gloss); c:px(29, 32, ember.gloss)
-- cleft
c:px(35, 31, ember.deep); c:px(36, 32, ember.deep)
-- leaf stem
c:fill(c:line({ { 25, 43 }, { 22, 46 } }, 2), "#2e5a2c")
c:fill(c:ellipse(24, 46, 2, 1), "#4a8a3e")

-- base dashes
for _, x in ipairs({ 25, 31, 37 }) do
  for i = 0, 2 do c:px(x + i, 53, "#8c4a1a") end
end

c:seam({ { 14, 18 }, { 50, 18 } }, { free = true })
c:button(30, 12)

local t = c:save(D .. "img-redraw-full/aseprite/ph/almond-peach-seed.aseprite",
                 D .. "img-redraw-full/png/ph/almond-peach-seed.png")
print(GV.report(t))
