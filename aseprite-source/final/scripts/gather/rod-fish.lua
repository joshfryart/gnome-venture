local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 56, mode = "sticker" }

local tail = c:poly({ {79, 28}, {93, 13}, {91, 27}, {93, 43} })
local dorsal = c:poly({ {38, 15}, {50, 8}, {64, 11}, {60, 18} })
local pelvic = c:poly({ {50, 41}, {58, 48}, {68, 43}, {60, 39} })
local body = c:ellipse(40, 28, 32, 16.5)
body:add(c:poly({ {50, 13}, {84, 24}, {84, 32}, {50, 43} }))
local belly = body:copy():clip(c:ellipse(42, 47, 38, 14))
local gill = c:ellipse(28, 27, 4.5, 9)

local p = c:build{
  { "tail",   tail,   GV.ramp("#3f8f78") },
  { "dorsal", dorsal, GV.ramp("#3f8f78") },
  { "pelvic", pelvic, GV.ramp("#4aa088"), { solid = true } },
  { "body",   body,   GV.ramp("#62b898") },
  { "belly",  belly,  GV.ramp("#d3ecc0"), { light = body, gloss = false } },
  { "gill",   gill,   GV.ramp("#2f6f5c"), { light = body, gloss = false, flat = true } },
}
-- tail inner rays
c:line({ {84, 27}, {90, 18} }, 1):each(function(x, y) c:px(x, y, "#5fb59a") end)
c:line({ {84, 29}, {90, 38} }, 1):each(function(x, y) c:px(x, y, "#5fb59a") end)
-- back sheen
c:fill(c:line({ {20, 17}, {44, 13} }, 2):clip(body), "#8bd2b0")
-- diamond spots
local function dia(x, y) c:paint({ ".s.", "sss", ".s." }, x - 1, y - 1, { s = "#3f8f78" }) end
dia(44, 22); dia(56, 26); dia(68, 22); dia(66, 32)
-- gill arc darker core
c:fill(c:line({ {29, 22}, {30, 27}, {29, 32} }, 1), "#1d4e44")
-- eye and mouth
c:eye(14, 21)
c:paint({ "mm...", "..mmm" }, 9, 32, { m = "#2f6f5c" })

local t = c:save(O .. "aseprite/gather/rod-fish.aseprite", O .. "png/gather/rod-fish.png")
print(GV.report(t))
