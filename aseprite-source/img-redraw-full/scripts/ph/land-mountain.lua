local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "scene", bleed = "" }

local tile = c:rrect(3, 3, 60, 60, 7)
-- sky bands
c:bands(tile, { "#d4f0e4", "#bfe4e8", "#a9d6ea", "#8fcbd8" }, { dir = "v" })

-- sun
c:part(c:ellipse(15, 15, 5, 5), "gold", { gloss = { 13, 13 } })

-- mountains
local mtn = c:poly({ {3, 51}, {22, 19}, {34, 37}, {42, 25}, {62, 51} }):clip(tile)
local stone = GV.ramp("#968f96", { shade = "#5b6470" })
c:part(mtn, stone, { gloss = false })

-- snow caps
local snow1 = c:poly({ {14, 34}, {22, 19}, {31, 33}, {28, 30}, {25, 33}, {22, 29}, {19, 33}, {17, 31} }):clip(mtn)
local snow2 = c:poly({ {37, 33}, {42, 25}, {48, 34}, {46, 32}, {43, 35}, {41, 32}, {39, 34} }):clip(mtn)
local sn = GV.ramp("#f4f0e0")
c:part(snow1, sn, { gloss = { 20, 24 } })
c:part(snow2, sn, { gloss = false })

-- ridge line
c:fill(c:line({ {22, 22}, {29, 34}, {24, 49} }, 1):clip(mtn):cut(snow1), "#6a6070")

-- meadow
local meadow = c:rect(3, 49, 60, 60):clip(tile)
c:part(meadow, GV.ramp("#58a03e"), { gloss = false })

-- pines
local function pine(x, top, base, w1, w2, s)
  c:part(c:rect(x - 1, base - 1, x + 1, base + 4), "wood", { flat = true })
  c:part(c:poly({ {x - w1, base}, {x + 0.5, top}, {x + w1 + 1, base} }), GV.ramp("#2f5a2a"), { flat = true })
  c:part(c:poly({ {x - w2, base - 1 - s}, {x + 0.5, top + 5 - s}, {x + w2 + 1, base - 1 - s} }), GV.ramp("#4a8a3e"), { flat = true })
end
pine(14, 37, 53, 6, 5, 4)
pine(51, 40, 54, 5, 4, 3)

-- hem stitch on meadow bottom
c:seam({ {10, 58}, {54, 58} })

local t = c:save(R .. "img-redraw-full/aseprite/ph/land-mountain.aseprite", R .. "img-redraw-full/png/ph/land-mountain.png")
print(GV.report(t))
