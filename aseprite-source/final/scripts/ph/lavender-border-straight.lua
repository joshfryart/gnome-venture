local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene", bleed = "lr" }

-- soil strip
c:part(c:rect(-4, 38, 67, 45), "#7a4a1f", { gloss = false, cres = 2 })

-- low green base band of soft puffs
local band = c:rect(-6, 31, 69, 39)
for i = -1, 10 do band:add(c:ellipse(3.2 + 6.4 * i, 32, 4.5, 4)) end
c:part(band, "moss", { gloss = false, cres = 4 })
for i = -1, 10 do c:px(math.floor(1.2 + 6.4 * i), 29, "#c8d77a"); c:px(math.floor(2.2 + 6.4 * i), 29, "#c8d77a") end

-- stems up into the upper blooms
local UX = { -1, 5, 12, 18, 25, 31, 37, 44, 50, 57, 63 }
for _, x in ipairs(UX) do c:px(x, 30, "#54447f"); c:px(x, 29, "#54447f") end

-- upper row: dark violet spikes standing above the band
local up = c:mask()
for _, x in ipairs(UX) do up:add(c:ellipse(x, 24, 2, 4)) end
c:outline(up, { ol = 1, olx = 1 })
c:part(up, GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#3e2f66", rim = "#a894dc", bounce = "#54447f" }),
  { outline = false, gloss = false, cres = 2, deep = 0, light = up })
for _, x in ipairs(UX) do c:px(x - 1, 22, "#c3b2ea"); c:px(x, 24, "#54447f"); c:px(x, 26, "#54447f") end

-- lower row: pale lilac puffs, offset between the upper spikes
local lo = c:mask()
for _, x in ipairs({ 2, 8, 15, 21, 28, 34, 40, 47, 53, 60 }) do lo:add(c:ellipse(x + 0.5, 33, 1.5, 2)) end
c:outline(lo, { ol = 1, olx = 0 })
c:part(lo, GV.ramp("#c3b2ea", { shade = "#7b66b4", deep = "#7b66b4", rim = "#e2d8f8", bounce = "#9a86cc" }),
  { outline = false, gloss = false, cres = 1, deep = 0, pale = false })

local t = c:save(O .. "aseprite/ph/lavender-border-straight.aseprite", O .. "png/ph/lavender-border-straight.png")
print(GV.report(t))
