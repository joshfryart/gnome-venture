-- ico-cup: the Jigsaw cup (a cup of three tiers). A wide two-eared loving cup in gold with a blue jigsaw piece
-- on its belly, on a wood plinth that carries three tier pips (green, gold, red).
-- Not ico-trophy (tall bowl, wire handles, plain): round belly, loop ears, piece badge, pips.
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-cup.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local bowl = c:ellipse(31.5, 22, 15, 16):cut(c:rect(0, 0, 63, 10))
local lip  = c:rrect(14, 8, 49, 12, 2)
local earL = c:ellipse(14, 22, 6, 7):cut(c:ellipse(13, 22, 2, 3))
local earR = c:ellipse(49, 22, 6, 7):cut(c:ellipse(50, 22, 2, 3))
local stem = c:rect(28, 37, 35, 42):add(c:rect(26, 40, 37, 42))
local plinth = c:rrect(16, 43, 47, 54, 2)
c:build{
  { "ears",   earL:add(earR), GV.ramp("#d0862a", { shade = "#a8541c" }), { gloss = false } },
  { "bowl",   bowl, "gold", { gloss = { 20, 16 } } },
  { "lip",    lip, "gold", { gloss = false, flat = true } },
  { "stem",   stem, "gold", { gloss = false } },
  { "plinth", plinth, "wood", { gloss = false } },
}
-- the jigsaw badge on the belly: a small blue piece (tab up, tab right)
local badge = c:rect(25, 20, 35, 30):add(c:ellipse(30, 17.5, 3)):add(c:ellipse(38, 25, 3))
c:part(badge, GV.ramp("#4f8fc0", { shade = "#2f5f98", rim = "#8cc4e8" }), { gloss = false, cres = 2 })
-- three tier pips on the plinth
c:paint({ ".gg.", "gggg", "GGGG", ".GG." }, 20, 46, { g = "#7ab55c", G = "#4a8a3e" })
c:paint({ ".yy.", "yyyy", "YYYY", ".YY." }, 30, 46, { y = "#f5cf6a", Y = "#e8a317" })
c:paint({ ".rr.", "rrrr", "RRRR", ".RR." }, 40, 46, { r = "#dd3a2a", R = "#ae2a2a" })
local t = c:save(D .. "final/aseprite/ico/ico-cup.aseprite", PNG .. "ico-cup.png")
print("ico-cup", GV.report(t))
