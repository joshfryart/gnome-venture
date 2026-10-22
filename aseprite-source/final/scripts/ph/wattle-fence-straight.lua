local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lr" }

local wood = GV.ramp("#a5663a")
local p = c:build{
  { "shadow", c:rect(0, 37, 63, 40), "#6a4528", { flat = true, gloss = false } },
  { "band",   c:rect(0, 26, 63, 37), wood, { gloss = false } },
}
-- weave: period 8 so the strip tiles at x 0 / 64
local band = p.band.m
for k = 0, 8 do
  local x = -2 + 8 * k
  local dark = c:line({ {x, 28}, {x + 4, 35} }, 2):clip(band)
  c:fill(dark, "#2a1a10")
  local lx = x + 4
  local light = c:line({ {lx, 28}, {lx + 3, 34} }, 1):clip(band)
  c:fill(light, "#dcb06a")
end
-- knot
c:part(c:ellipse(32, 31.5, 5, 5), "#44281c", { gloss = false, rim = false })
c:fill(c:ellipse(31, 30.5, 2, 2), "#a5663a")
c:px(30, 29, "#dcb06a")
local t = c:save(O .. "aseprite/ph/wattle-fence-straight.aseprite", O .. "png/ph/wattle-fence-straight.png")
print(GV.report(t))
