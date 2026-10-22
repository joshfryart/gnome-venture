local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local olive = GV.ramp("#b0bc66")
local dark = GV.ramp("#58a03e")

local feet = c:ellipse(18, 54, 8, 3.5):add(c:ellipse(45, 54, 8, 3.5))
local body = c:ellipse(31.5, 43, 21, 13)
body:add(c:ellipse(31.5, 35, 14, 7))
local bumps = c:ellipse(22, 26, 8, 7.5):add(c:ellipse(41, 26, 8, 7.5))
local belly = c:ellipse(31.5, 49, 11, 6)

local p = c:build{
  { "feet",  feet,  dark },
  { "body",  body,  olive },
  { "bumps", bumps, olive, { light = body:copy():add(bumps), gloss = false } },
  { "belly", belly, "cream", { gloss = false, rim = false } },
}
c:gloss(bumps, olive, { 16, 22 })

-- warts: beans, evenly varied
c:spot(c:ellipse(16.5, 42, 1.5, 1), "#58a03e")
c:spot(c:ellipse(47, 43, 1.5, 1), "#58a03e")
c:spot(c:ellipse(23, 47, 1, 1.5), "#58a03e")
c:spot(c:ellipse(40, 47, 1, 1.5), "#58a03e")
c:spot(c:ellipse(31.5, 31, 1.5, 1), "#58a03e")

-- wide mouth spanning the head
c:fill(c:line({ {19, 37}, {23, 39}, {27, 40}, {36, 40}, {40, 39}, {44, 37} }, 1), "#2a1a10")
c:px(18, 36, "#2a1a10"); c:px(45, 36, "#2a1a10")

-- big eyes on the bumps
c:eye(20, 23); c:eye(39, 23)

local t = c:save("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/aseprite/ph/creature-mire-toad.aseprite",
                 "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/png/ph/creature-mire-toad.png")
print(GV.report(t))
