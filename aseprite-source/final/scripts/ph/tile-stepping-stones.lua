local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
local G, GS, UM = "#7ab55c", "#4a8a3e", "#4a2c1a"

c:fill(c:rect(0, 0, 63, 63), G)
-- grass tufts: little two-blade ticks leaning right
local tuft = { "...a.", "a..a.", ".a.a.", ".aa..", "..a.." }
for _, p in ipairs({ {48,12},{48,45},{58,25},{2,39},{30,54},{27,32},{54,17},{4,4},{56,56},{12,48} }) do
  c:paint(tuft, p[1] - 2, p[2] - 2, { a = GS })
end
for _, p in ipairs({ {44,8},{26,46},{52,38},{8,56},{36,28},{60,4} }) do c:px(p[1], p[2], "#6a9a3a") end

local stone = GV.ramp("#8b8f96", { shade = "#5b6470" })
local function rock(cx, cy)
  c:fill(c:ellipse(cx + 1, cy + 3, 13, 10), GS)            -- sunk shadow in the grass
  local m = c:ellipse(cx, cy, 13, 10)
  c:fill(m:grow(1), UM)
  c:part(m, stone, { outline = false, gloss = false, cres = 3, deep = 1 })
  c:fill(c:ellipse(cx - 2, cy - 2, 9, 6), "#c9c5bc")
  for x = cx - 7, cx - 2 do c:px(x, cy - 6, "#fff3c8") end
  c:px(cx - 8, cy - 5, "#fff3c8"); c:px(cx - 8, cy - 4, "#fff3c8")
end
rock(20, 18)
rock(44, 44)
local t = c:save(O .. "aseprite/ph/tile-stepping-stones.aseprite", O .. "png/ph/tile-stepping-stones.png")
print(GV.report(t))
