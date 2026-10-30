-- ph/vanilla-extract (Pantry cordial): tiny amber dropper bottle, dark extract, black collar and rubber bulb, crossed vanilla pods
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "vanilla-extract"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bottle = c:rrect(20, 28, 44, 55, 6):add(c:rrect(27, 21, 37, 30, 1))
c:part(bottle, "#7a4a1f", { gloss = false, pale = false })
c:part(c:rrect(22, 32, 42, 53, 4), "#3a2a1f", { gloss = false, contact = false })
c:fill(c:rect(23, 34, 24, 50), "#5a3a1f")
c:fill(c:rect(23, 31, 41, 31), "#a8742f")   -- liquid line catching light
c:px(21, 31, "#c98a4a"); c:px(21, 32, "#c98a4a"); c:px(21, 33, "#c98a4a")   -- glass rim glint
-- collar and bulb
c:part(c:rrect(25, 17, 39, 22, 1), "#2a1a10", { gloss = false, rim = false, contact = false })
c:fill(c:rect(26, 19, 38, 19), "#5b6470")
c:part(c:ellipse(32, 12, 5.5, 6):add(c:rect(28, 14, 36, 17)), "#4a3a30", { gloss = false })
c:fill(c:rect(29, 8, 29, 10), "#7a6a5a"); c:px(30, 8, "#7a6a5a")
c:px(29, 7, "#ffffff")
-- label with two crossed vanilla pods and a few seeds
c:part(c:rect(22, 36, 42, 49), "cream", { gloss = false, contact = false })
-- pods: two thick curved beans crossed at their stalks (a V), a pale vanilla orchid between them
c:fill(c:line({ {34, 48}, {30, 45}, {27, 42}, {25, 38} }, 2), "#3a2a1f")
c:fill(c:line({ {30, 48}, {34, 45}, {37, 42}, {39, 38} }, 2), "#5a3a1f")
c:px(26, 41, "#7a5a3a"); c:px(28, 43, "#7a5a3a"); c:px(37, 41, "#8a6a4a"); c:px(35, 43, "#8a6a4a")
c:paint({ ".y.", "yky", ".y." }, 31, 38, { y = "#f5cf6a", k = "#e8a317" })
c:ground(32, 57, 13, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
