-- ph/poi (Gourmand P2 jar): wooden bowl brimming with smooth lilac poi and a swirl groove, taro leaf tucked behind, grey pounder stone on the right
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "poi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- taro leaf behind, tip up-left
local leaf = c:ellipse(22, 25, 11, 10):add(c:poly({ {12, 22}, {9, 8}, {26, 17} }))
c:part(leaf, "#4f8a3a", { cres = 3, gloss = { 15, 15 } })
c:fill(c:line({ {11, 10}, {18, 19}, {25, 30} }, 1), "#2f6a2a")
c:fill(c:line({ {18, 19}, {13, 25} }, 1), "#2f6a2a"); c:fill(c:line({ {21, 24}, {30, 19} }, 1), "#2f6a2a")
-- wooden bowl
local bowl = c:ellipse(28, 38, 21, 15):clip(c:rect(0, 38, 63, 63)):add(c:ellipse(28, 38, 21, 6))
bowl:cut(c:rect(0, 51, 63, 63)):add(c:rrect(19, 48, 37, 53, 2))
c:part(bowl, "#8a5a2f", { cres = 3, gloss = false })
c:fill(c:ellipse(28, 38, 21, 6):edge():clip(c:rect(0, 31, 63, 38)), "#b88050")
c:fill(c:line({ {12, 45}, {20, 47}, {30, 47} }, 1), "#6b4220")                -- wood grain
c:fill(c:line({ {34, 49}, {42, 47} }, 1), "#6b4220")
-- poi: smooth domed paste brimming over the rim
local poi = c:ellipse(28, 37, 18, 4.5):add(c:ellipse(28, 34, 14, 5):clip(c:rect(0, 0, 63, 37)))
c:part(poi, "#9a6ac0", { contour = "#4a2c1a", cres = 3, gloss = false, contact = false })
c:fill(c:line({ {18, 36}, {22, 33}, {29, 32}, {35, 34}, {33, 37}, {27, 37}, {25, 35} }, 2), "#7a4aa0")  -- swirl groove
c:fill(c:rect(21, 32, 24, 32), "#c8a0e8")
c:px(20, 33, "#c8a0e8")
-- poi pounder: knob, waist, flared stone base
local pound = c:ellipse(50, 30, 3, 3):add(c:rrect(48, 32, 52, 41, 1)):add(c:poly({ {48, 39}, {53, 39}, {57, 52}, {44, 52} }))
pound:add(c:ellipse(50.5, 51, 6, 2))
c:part(pound, "stone", { cres = 3, gloss = { 47, 44 } })
c:px(46, 48, "#6a6e76"); c:px(53, 45, "#6a6e76")
c:ground(31, 56, 22, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
