local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stoneD = GV.ramp("#6a6070")
local stoneL = GV.ramp("#968f96", { deep = "#5b6470" })

local body = c:ellipse(31.5, 24, 21, 24):cut(c:rect(0, 0, 63, 23))
local handles = c:rrect(6, 22, 12, 28, 2):add(c:rrect(51, 22, 57, 28, 2))
local rim = c:ellipse(31.5, 24, 21, 6)
local stew = c:ellipse(31.5, 23.5, 17, 4)

local p = c:build{
  { "handles", handles, stoneD, { gloss = false } },
  { "body", body, stoneL, { gloss = { 20, 33 } } },
  { "rim", rim, stoneD, { gloss = false } },
  { "stew", stew, "moss", { gloss = false, rim = false } },
}
-- three lumps in different greens
local lumps = {
  { c:rrect(21, 21, 25, 24, 1), "#58a03e" },
  { c:rrect(37, 21, 41, 24, 1), "#a4b86a" },
  { c:rrect(29, 23, 33, 26, 1), "#c8d77a" },
}
for i, l in ipairs(lumps) do
  c:part(l[1], GV.ramp(l[2]), { flat = true })
end
c:seam({ {13, 33}, {50, 33} })
c:ground(31.5, 49, 15, 1.5)

local t = c:save(D .. "img-redraw-full/aseprite/ph/three-sisters-stew.aseprite", D .. "img-redraw-full/png/ph/three-sisters-stew.png")
print(GV.report(t))
