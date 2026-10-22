local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- flame-shaped tuft: round belly + two flicking tips with a notch
local tuft = c:ellipse(32, 37, 12, 12)
tuft:add(c:poly({ {20,38},{20,30},{22,22},{24,16},{26,12},{28,15},{30,19},{32,23},
                  {34,19},{36,15},{38,12},{40,16},{42,22},{44,30},{45,38} }))
tuft:add(c:line({ {41,18},{43,15},{45,14} }, 2))   -- loose hair flick
tuft:cut(c:rect(0, 50, 63, 63))

local band = c:rrect(19, 46, 45, 52, 2)

local p = c:build{
  { "tuft", tuft, GV.ramp("#e8e0cc"), { gloss = { 25, 22 } } },
  { "band", band, GV.ramp("#9a6b3f") },
}

-- strand grooves (2 px)
local g = "#bdb293"
c:fill(c:line({ {27,26},{26,32},{25,39},{26,45} }, 2):clip(p.tuft.m:shrink(1)), g)
c:fill(c:line({ {32,29},{32,45} }, 2):clip(p.tuft.m:shrink(1)), g)
c:fill(c:line({ {37,26},{38,32},{39,39},{38,45} }, 2):clip(p.tuft.m:shrink(1)), g)

c:seam({ {20,49}, {45,49} })

local t = c:save(D .. "img-redraw-hybrid/aseprite/animals/item-goat-hair.aseprite",
                 D .. "img-redraw-hybrid/png/animals/item-goat-hair.png")
print(GV.report(t))
