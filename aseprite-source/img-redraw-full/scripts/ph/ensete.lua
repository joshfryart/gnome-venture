local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local orange = GV.ramp("#f08a24", { shade = "#e0501f" })
local leafR = GV.ramp("#58a03e")

-- broad upright leaf, curling right
local leaf = c:poly({ {33, 20}, {33, 13}, {35, 8}, {39, 5}, {44, 4}, {43, 9}, {41, 14}, {37, 19} })
local stalk = c:rrect(30, 14, 33, 22, 1)

c:build{
  { "stalk", stalk, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, leafR, { gloss = false } },
  { "bulb", c:ellipse(31.5, 36, 17, 16), orange },
}
c:fill(c:line({ {35, 17}, {38, 11}, {42, 6} }, 1), leafR.shade)

-- vertical rib lines splitting wedges
local rib = "#b8452f"
c:fill(c:line({ {32, 22}, {32, 50} }, 1), rib)
c:fill(c:line({ {25, 23}, {22, 30}, {21, 37}, {22, 44}, {25, 49} }, 1), rib)
c:fill(c:line({ {39, 23}, {42, 30}, {43, 37}, {42, 44}, {39, 49} }, 1), rib)
-- base dimple
c:fill(c:ellipse(31.5, 49.5, 2, 1), "#8a4f2a")

local t = c:save(O .. "aseprite/ph/ensete.aseprite", O .. "png/ph/ensete.png")
print(GV.report(t))
