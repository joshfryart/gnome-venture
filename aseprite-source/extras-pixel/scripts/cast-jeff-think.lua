-- Jeff think (tips): hand on chin, one brow up, a small flat mouth, a lit bulb over his head. 64x64 sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local ASE, PNG = D .. "extras-pixel/cast/", "/home/user/gnome-venture/game/assets/img/puzzles/cast/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dx, dy = -3, 3
local body = c:poly({ {16+dx, 25+dy}, {45+dx, 22+dy}, {46+dx, 50+dy}, {18+dx, 52+dy} })
body:add(c:rrect(26+dx, 14+dy, 35+dx, 26+dy, 2)); body:add(c:ellipse(30.5+dx, 12+dy, 7.5, 6))
body:cut(c:ellipse(32+dx, 53+dy, 6, 4.5))
body:cut(c:rect(0, 61, 63, 63))

-- left arm tab; right arm bent up so the hand rests under the chin
local armL = c:rrect(10, 37, 15, 43, 2); armL:add(c:ellipse(10, 40, 3, 4))
armL:cut(body:grow(1))
local armR = c:line({ {42, 40}, {47, 44}, {43, 48} }, 4)
armR:cut(body:grow(1))
armR:add(c:ellipse(37, 47, 3.5, 3))                                  -- fist tucked under the chin, on the body

-- light bulb, top right: gold glass, stone screw base
local bulb = c:ellipse(49.5, 12, 5.5, 5.5); bulb:add(c:poly({ {46, 14}, {54, 14}, {53, 19}, {47, 19} }))
local base = c:rrect(47, 19, 52, 23, 1)

c:build{
  { "armL", armL, GV.ramp("#2cc97c"), { flat = true } },
  { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
  { "armR", armR, GV.ramp("#2cc97c"), { flat = true } },
  { "base", base, "stone", { flat = true } },
  { "bulb", bulb, GV.ramp("#f5cf6a"), { gloss = { 46, 9 } } },
}
-- bulb filament and screw lines
c:paint({ "u.u", ".u." }, 48, 14, { u = "#b8661a" })
c:paint({ "ssssss" }, 47, 21, { s = "#5b6470" })
-- rays off the bulb (flat gold, 2 px)
c:paint({ "gg" }, 40, 5, { g = "#f5cf6a" }); c:paint({ "gg" }, 56, 5, { g = "#f5cf6a" })
c:paint({ "g", "g" }, 49, 4, { g = "#f5cf6a" })
c:paint({ "gg" }, 40, 12, { g = "#f5cf6a" }); c:paint({ "gg" }, 57, 12, { g = "#f5cf6a" })

c:button(29+dx, 15+dy)
c:seam({ {21+dx, 47+dy}, {25+dx, 47+dy} }); c:seam({ {39+dx, 47+dy}, {43+dx, 47+dy} })

-- face: eyes looking up-right, one brow raised high, the other flat, small tilted mouth
c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy)
c:paint({ "..uuuu", "uu...." }, 34+dx, 22+dy, { u = "umber" })       -- raised brow
c:paint({ "uuuu" }, 19+dx, 25+dy, { u = "umber" })                    -- flat brow
c:paint({ "......uu", "uuuuuu.." }, 25+dx, 40+dy, { u = "umber" })      -- hmm mouth

local t = c:save(ASE .. "jeff-think.aseprite", PNG .. "jeff-think.png")
print("jeff-think", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
