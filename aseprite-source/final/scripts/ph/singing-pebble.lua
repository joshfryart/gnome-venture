-- singing-pebble: a small smooth river pebble, tilted, worn through by a little wind hole that hums.
-- Family: stone (Part A base #8b8f96 run through GV.ramp), hum marks in thread gold.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#8b8f96", { gloss = "#f1ece0", dot = "#fff3c8" })

-- egg-shaped pebble, fat end lower-left, leaning up to the right
local body = c:ellipse(27, 41, 14, 10.5):add(c:ellipse(34, 36.5, 11, 8)):closed(3)
local p = c:build{
  { "pebble", body, stone, { gloss = { 19, 35 } } },
}
-- the wind hole near the narrow end: a deep rim ring round a dark throat
local hole = c:ellipse(37, 35, 3.5, 2.5)
c:fill(hole, stone.deep)
c:fill(c:ellipse(37.5, 35.5, 2, 1.5), "#2a1a10")
c:fill(c:rect(35, 37, 39, 37):clip(hole), stone.rim)   -- lit lower lip of the hole
-- two dark bean markings, glazed
c:spot(c:rect(22, 44, 24, 45), "#5b6470", "#c9c5bc")
c:spot(c:rect(28, 47, 30, 48), "#5b6470", "#c9c5bc")
-- hand-laid enamel comma along the lit upper-left (the auto comma is too short on grey)
c:paint({ "..gg", ".g..", "g...", "g..." }, 17, 34, { g = stone.gloss })
c:px(19, 36, stone.dot)
-- hum marks: two tiny gold sound arcs off the hole, upper right (not a halo)
local G = "#f5cf6a"
c:paint({ "g.", ".g", ".g" }, 49, 24, { g = G })
c:paint({ "g.", ".g", ".g", ".g" }, 53, 20, { g = G })

local t = c:save(D .. "final/aseprite/ph/singing-pebble.aseprite", PNG .. "singing-pebble.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
