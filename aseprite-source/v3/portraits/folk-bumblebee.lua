local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P or dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/palette.lua")

local NAME = "folk-bumblebee"
local c = HP.canvas{ w = 80, h = 100, scale = 4, name = NAME }
local disc = c:ellipse(39.5, 44.5, 31, 31)
c:fillMask(disc, P.dusk.hi)
c:fillMask(disc:copy():cut(disc:copy():shift(-2, -2)), P.dusk.base)
-- wings behind shoulders
c:part(c:ellipse(18, 62, 8, 14), "sky")
c:part(c:ellipse(62, 62, 8, 14), "sky")
-- antennae: stalks then clubs (quirk: left = ball, right = heart)
c:fillMask(c:line({ {32,32},{28,20},{25,13} }, 1), P.ink)
c:fillMask(c:line({ {48,32},{52,20},{55,13} }, 1), P.ink)
c:part(c:ellipse(25, 11, 3, 3), "wood", { band = 1 })
c:paint({ ".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }, 52, 6, { X = "petal.base" })
-- body, fuzzy stripes, apron
local body = c:poly{ {10,99},{14,82},{26,72},{40,76},{54,72},{66,82},{70,99} }
c:part(body, "gold")
c:fillMask(c:rect(0, 78, 79, 80):clip(body), P.ink)
c:fillMask(c:rect(0, 90, 79, 92):clip(body), P.ink)
local ap = c:poly{ {26,99},{28,80},{40,84},{52,80},{54,99} }
c:fillMask(ap, P.cream)
c:fillMask(ap:copy():cut(ap:copy():shift(-2, -2)), P.stone.hi)
-- neck and head (fuzzy)
c:part(c:rect(33, 64, 47, 74), "gold")
c:part(c:ellipse(40, 49, 20, 18), "gold")
c:fillMask(c:rect(22, 36, 58, 37):clip(c:ellipse(40, 49, 20, 18)), P.ink)
c:eyeLocked(29, 46) c:eyeLocked(43, 46)
c:cheek(26, 55) c:cheek(51, 55)
c:px(37, 57, P.ink) c:px(38, 58, P.ink) c:px(39, 58, P.ink) c:px(40, 58, P.ink) c:px(41, 57, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
c:save{ png = "/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/" .. NAME .. "_x4.png", scale = 4 }
