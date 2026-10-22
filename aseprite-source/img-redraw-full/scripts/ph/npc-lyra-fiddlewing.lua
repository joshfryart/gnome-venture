local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local green = GV.ramp("#7ab55c", { rim = "#a4b86a" })
local straw = GV.ramp("#dcb06a", { rim = "#d9a660" })
local crownR = GV.ramp("#f5cf6a")
local band = GV.ramp("#d6322b")
local shirt = GV.ramp("#f8eed2")
local flapR = GV.ramp("#b07a10")

-- backdrop
local bd = c:ellipse(40, 50, 36, 36)
-- jacket
local jacket = c:ellipse(39.5, 100, 34, 24)
local shirtM = c:poly({ {30, 76}, {51, 76}, {40.5, 88} })
local flapL = c:poly({ {22, 79}, {30, 76}, {40, 88}, {31, 91} })
local flapRm = c:poly({ {51, 76}, {59, 79}, {50, 91}, {41, 88} })
-- antennae
local antL = c:line({ {32, 38}, {24, 26}, {19, 19}, {16, 16} }, 2):add(c:rect(12, 12, 15, 15))
local antR = c:line({ {48, 38}, {56, 26}, {61, 19}, {64, 16} }, 2):add(c:rect(64, 12, 67, 15))
-- head (wide top for eyes, narrow chin)
local head = c:ellipse(39.5, 54, 20, 17):add(c:ellipse(39.5, 66, 13, 11))
-- hat
local brim = c:ellipse(39.5, 43, 34, 5.5)
local crown = c:ellipse(39.5, 42, 18, 19):cut(c:rect(0, 42, 79, 99))
local bandM = c:rect(21, 35, 58, 39):clip(crown)

local p = c:build{
  { "backdrop", bd, green, { gloss = false } },
  { "jacket", jacket, "gold" },
  { "flapL", flapL, flapR, { flat = true } },
  { "flapR", flapRm, flapR, { flat = true } },
  { "shirt", shirtM, shirt, { flat = true } },
  { "antL", antL, "dusk", { flat = true } },
  { "antR", antR, "dusk", { flat = true } },
  { "head", head, green },
  { "brim", brim, straw, { stitch = { side = "lit" } } },
  { "crown", crown, crownR },
  { "band", bandM, band, { gloss = false } },
}

-- forehead line under the brim
c:px(40, 49, "#4a8a3e"); c:px(40, 50, "#4a8a3e")
-- huge eyes: 7x7 cream disc, 4x4 pupil, 1px glint upper-left
local eye = { ".ccccc.", "ccccccc", "ccgpppc", "ccppppc", "ccppppc", "ccppppc", ".ccccc." }
local leg = { c = "#f2e4c0", p = "#2a1a10", g = "#f2e4c0" }
c:paint(eye, 25, 50, leg)
c:paint(eye, 48, 50, leg)
-- smile
c:paint({ "u.......u", ".u.....u.", "..uuuuu.." }, 36, 63, { u = "#4a2c1a" })
-- button at shirt V tip
c:button(39, 86)

local t = c:save(O .. "aseprite/ph/npc-lyra-fiddlewing.aseprite", O .. "png/ph/npc-lyra-fiddlewing.png")
print(GV.report(t))
