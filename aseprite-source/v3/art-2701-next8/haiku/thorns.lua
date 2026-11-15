-- thorns (tag "thorns": while this guard is up, a blocked hit pricks the creature). Haiku first pass.
-- A moss-green cactus with two arms, cream spines scattered over it and a petal-pink flower on top.
-- quirk: the flower on top, the cactus still blooms when it guards.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thorns" }

local cactus = HP.rrect(24, 18, 40, 57, 7)
  :add(HP.rrect(14, 30, 26, 40, 4))
  :add(HP.rrect(14, 24, 20, 42, 3))
  :add(HP.rrect(38, 36, 50, 46, 4))
  :add(HP.rrect(44, 28, 50, 48, 3))
c:part(cactus, "moss", { band = 2 })

for _, p in ipairs({ {27, 24}, {33, 22}, {37, 29}, {29, 34}, {35, 38}, {27, 47}, {33, 50}, {41, 52},
                     {16, 36}, {17, 31}, {46, 40}, {46, 46} }) do
  c:put(p[1], p[2], P.cream)
end

c:part(HP.ellipse(32, 14, 3, 3), "petal", { band = 1 })
c:put(32, 14, P.gold.base)

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "thorns.aseprite", png = OUT .. "thorns.png", scale = 1 }
