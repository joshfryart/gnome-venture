local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local belly = c:ellipse(31.5, 41, 19, 15)
local neck = c:rrect(21, 22, 42, 30, 2)
local lid = c:ellipse(31.5, 22, 14, 8):cut(c:rect(0, 25, 63, 63))
local knob = c:ellipse(31.5, 12.5, 3.5, 3.5)

local p = c:build{
  { "belly", belly, GV.ramp("#f4f0e0") },
  { "neck",  neck,  GV.ramp("#dcb06a") },
  { "lid",   lid,   GV.ramp("#b0bc66") },
  { "knob",  knob,  "moss" },
}

-- glaze band around the lower belly
local band = c:rect(0, 49, 63, 50):clip(belly:shrink(2))
c:fill(band, "#b0bc66")
band:each(function(x, y) if x > 36 then c:px(x, y, "#8a9a4a") end end)

-- painted berry motif
local berry = c:ellipse(31.5, 40, 6.5, 6.5)
local b = c:part(berry, GV.ramp("#b0bc66"), { contact = false })
c:line({ {32, 33}, {33, 31} }, 2)
c:fill(c:line({ {32, 33}, {33, 31} }, 2), "#2e5a2c")
local leaf = c:poly({ {34, 31}, {37, 28}, {41, 28}, {39, 31}, {35, 33} })
c:fill(leaf, "#58a03e")
c:px(36, 30, "#7ab55c"); c:px(37, 29, "#7ab55c")

-- gold seam at the neck
c:seam({ {21, 26}, {42, 26} })

local t = c:save(O .. "aseprite/ph/kalyna-seed.aseprite", O .. "png/ph/kalyna-seed.png")
print(GV.report(t))
