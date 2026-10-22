local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lr" }

local light = GV.ramp("#d6c9b6")
local grey = GV.ramp("#968f96", { shade = "#5b6470" })

-- mortar band behind the stones
c:part(c:rect(0, 25, 63, 38), GV.ramp("#6a6070"), { gloss = false, rim = false, bounce = false })

-- alternating stones, varied a touch in height so the run feels hand-laid
local i = 0
for x = -3, 63, 8 do
  if x + 7 < 24 or x > 39 then
    local top = (i % 2 == 0) and 26 or 27
    local bot = (i % 2 == 0) and 37 or 36
    local ramp = (i % 2 == 0) and light or grey
    local g = (x == -3) and { 2, 28 } or false
    c:part(c:rrect(x, top, x + 6, bot, 3), ramp, { gloss = g, cres = 3, contact = false, contour = false })
    i = i + 1
  end
end

-- centre keystone block, proud of the band
c:part(c:rrect(24, 22, 39, 41, 4), GV.ramp("#6a6070"), { gloss = false })
c:part(c:rrect(27, 25, 36, 38, 3), grey, { gloss = { 29, 27 } })

local t = c:save(R .. "img-redraw-full/aseprite/ph/stone-wall-straight.aseprite", R .. "img-redraw-full/png/ph/stone-wall-straight.png")
print(GV.report(t))
