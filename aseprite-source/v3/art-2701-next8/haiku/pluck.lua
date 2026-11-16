-- pluck (tag "pluck": a small chance to lift an item the creature could drop). Haiku first pass.
-- Steel tweezers pinching the edge of a gold coin, the coin lifted clear of the ground.
-- quirk: a little moss clover stamped in the middle of the coin.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pluck" }

local coin = HP.ellipse(42, 33, 6, 6)
c:part(coin, "gold", { band = 2 })
for _, p in ipairs({ {42, 31}, {41, 32}, {42, 32}, {43, 32}, {42, 33} }) do c:put(p[1], p[2], P.moss.base) end

local tweezers = HP.line({ {12, 56}, {36, 26} }, 3)
  :add(HP.line({ {20, 58}, {40, 28} }, 3))
  :add(HP.ellipse(19, 53, 4, 3))
c:part(tweezers, "stone", { band = 1 })

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "pluck.aseprite", png = OUT .. "pluck.png", scale = 1 }
