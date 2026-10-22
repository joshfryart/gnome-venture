local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene", ol = 1, olx = 0 }

local tile = c:rrect(2, 2, 60, 60, 7)
local meadow = c:rect(0, 46, 63, 63):clip(tile)
-- slight rolling top to the meadow
meadow:add(c:ellipse(14, 47, 14, 2.5):clip(tile)); meadow:add(c:ellipse(48, 46, 16, 2.5):clip(tile))

local DARK, LIT = GV.ramp("#2e5a2c"), GV.ramp("#58a03e")
local function pine(ax, ay, w, yb, lw, lay, lyb)
  local d = c:poly({ { ax, ay }, { ax + w/2 + 1, yb }, { ax - w/2, yb } })
  local l = c:poly({ { ax, lay }, { ax + lw/2 + 1, lyb }, { ax - lw/2, lyb } })
  return d, l
end

c:part(tile, GV.ramp("#b0bc66"), { gloss = false, bounce = false, cres = 0, deep = 0 })
-- pale distant ridge for depth
c:fill(c:ellipse(20, 47, 22, 6):add(c:ellipse(50, 48, 18, 5)):clip(tile):cut(meadow), "#9aa858")
c:part(meadow, "moss", { gloss = false, cres = 0, deep = 0, outline = false, bounce = false })
c:fill(meadow:edge():cut(meadow:shift(0, 1)):clip(tile:shrink(1)), "#4a8a3e")
c:fill(c:ellipse(26.5, 57, 8, 2):clip(meadow), "#a5663a")
c:fill(c:ellipse(26.5, 56.5, 6, 1):clip(meadow), "#c48552")

-- trunks (behind the needles)
c:part(c:rect(49, 40, 51, 53), "wood", { flat = true })
c:part(c:rect(15, 40, 17, 54), "wood", { flat = true })
c:part(c:rect(33, 40, 35, 56), "wood", { flat = true })

-- right low pine, left medium, centre tall in front
local d, l = pine(50, 21, 21, 40, 17, 30, 46)
c:part(d, DARK, { gloss = false, cres = 3 }); c:part(l, LIT, { gloss = false, cres = 3 })
d, l = pine(16, 17, 24, 40, 19, 28, 47)
c:part(d, DARK, { gloss = false, cres = 3 }); c:part(l, LIT, { gloss = false, cres = 3 })
d, l = pine(34, 11, 26, 39, 21, 25, 48)
c:part(d, DARK, { gloss = false, cres = 3 }); c:part(l, LIT, { gloss = false, cres = 3 })

-- red berry with a leaf
c:part(c:ellipse(8, 54, 2.5, 2.5), "red", { gloss = { 7, 53 } })
c:px(9, 50, "#2f5a2a"); c:px(10, 50, "#2f5a2a"); c:px(9, 51, "#4a8a3e")

-- second ring of the 2 px tile edge
local ring = tile:grow(2):cut(tile:grow(1))
ring:each(function(x, y) c:px(x, y, c:tone(x, y)) end)

-- hem stitch inside the bottom edge
c:seam({ { 9, 59 }, { 54, 59 } }, { free = true })

local t = c:save(O .. "aseprite/ph/land-forest.aseprite", O .. "png/ph/land-forest.png")
print(GV.report(t))
