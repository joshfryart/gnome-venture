local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = D .. "img-redraw-full/"

local wood  = GV.ramp("#a5663a")
local rimW  = GV.ramp("#8c4a1a")
local hoop  = GV.ramp("#6a6070")
local pipeR = GV.ramp("#968f96")

-- downspout: vertical drop then elbow into the barrel top
local pipe = c:rect(8, 7, 13, 23):add(c:rrect(8, 18, 24, 23, 2))
-- barrel: bulging staves
local body = c:rrect(15, 21, 48, 55, 7):add(c:rrect(13, 27, 50, 49, 4))

local p = c:build{
  { "pipe", pipe, pipeR, { gloss = { 10, 9 } } },
  { "body", body, wood, { gloss = { 18, 34 } } },
}
-- staves
for _, x in ipairs({ 23, 31, 40 }) do
  c:fill(c:line({ { x, 25 }, { x, 54 } }, 2), "#5e2f1e")
end
c:build{
  { "hoopT", c:rect(13, 29, 50, 32):clip(body), hoop, { gloss = false } },
  { "hoopB", c:rect(13, 45, 50, 48):clip(body), hoop, { gloss = false } },
  { "rim",   c:ellipse(31.5, 21, 18, 5.5), rimW, { gloss = false } },
  { "water", c:ellipse(31.5, 21.5, 15, 3.5), "water", { gloss = { 22, 20 } } },
}
c:paint({ "w.w..ww", ".w.ww.." }, 28, 21, { w = "#a9d6ea" })
-- drip under pipe? pipe feeds barrel, drip from elbow end
c:fill(c:rect(10, 26, 11, 27), "#a9d6ea")
-- tap
c:part(c:rect(29, 50, 35, 53), hoop, { flat = true })
c:fill(c:rect(31, 54, 33, 55), "#6a6070")

c:ground(31.5, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ico/ico-barrel.aseprite", O .. "png/ico/ico-barrel.png")
print(GV.report(t))
