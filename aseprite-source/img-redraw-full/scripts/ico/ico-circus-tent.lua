local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local poleR = GV.ramp("#a27e55")
local redR  = GV.ramp("#d6322b")
local paleR = GV.ramp("#fffaf0")

local pole  = c:rect(30, 9, 33, 16)
local walls = c:rect(13, 33, 50, 53)
local wst1  = c:rect(20, 33, 26, 53)
local wst2  = c:rect(37, 33, 43, 53)
local roof  = c:poly({ {32, 13}, {54, 34}, {10, 34} })
local rst   = c:poly({ {32, 13}, {40, 34}, {24, 34} }):clip(roof)
local door  = c:poly({ {32, 38}, {37, 54}, {27, 54} })

c:build{
  { "pole",  pole,  poleR, { gloss = false } },
  { "walls", walls, paleR },
  { "wst1",  wst1,  redR, { gloss = false, light = walls } },
  { "wst2",  wst2,  redR, { gloss = false, light = walls } },
  { "door",  door,  "dusk", { gloss = false, light = walls } },
  { "roof",  roof,  redR },
  { "rst",   rst,   paleR, { light = roof } },
}

-- hem stitch along roof-wall seam, button at the door head
c:seam({ {12, 35}, {51, 35} })
c:button(30, 34)

local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-circus-tent.aseprite",
                 D .. "img-redraw-full/png/ico/ico-circus-tent.png")
print(GV.report(t))
