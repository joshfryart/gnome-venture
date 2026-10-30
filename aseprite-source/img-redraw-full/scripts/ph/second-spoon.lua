-- ph/second-spoon (Gourmand reward decor): a silver spoon planted bowl-up in a squat terracotta pot, like a flower
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N, MARGIN = "second-spoon", 3
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local silver = GV.ramp("#dfe5ea", { shade = "#a9b3bc", deep = "#7d8791", bounce = "#b9c2ca", rim = "#f4f7f9", gloss = "#f8fbfc", dot = "#fbfdfe", pale = false })
local handle = GV.ramp("#c9d0d6", { shade = "#8d97a0", rim = "#e6ebef", pale = false })
c:part(c:rect(31, 22, 33, 38), handle, { flat = true, contact = false })
c:fill(c:rect(33, 25, 33, 38), "#8d97a0")
local bowl = c:ellipse(32, 16, 8, 10)
c:part(bowl, silver, { gloss = false, contact = false })
-- the dish is concave: dark at the upper left, lit at the lower right (reverse of a dome)
local dish = c:ellipse(32, 16.5, 5, 7.5)
dish:each(function(x, y) c:px(x, y, ((x - 32) + (y - 16.5) < -3) and "#b9c2ca" or "#f4f7f9") end)
c:fill(c:rect(35, 19, 35, 21), "#fbfdfe")
c:paint({ "hh", "hh", "h.", "h.", "h." }, 26, 10, { h = "#fbfdfe" })   -- hard metal highlight comma
-- soil mound peeking above the rim
c:part(c:ellipse(32, 38, 11, 2.5), "#5a3b22", { gloss = false, cres = 2, deep = 0, contact = false })
c:px(26, 37, "#7a4a1f"); c:px(37, 37, "#7a4a1f")
-- squat pot and rim
c:part(c:poly({ {19, 42}, {46, 42}, {42, 57}, {23, 57} }), "flame", { contact = false })
c:part(c:rrect(17, 38, 47, 43, 2), GV.ramp("#d6322b", { shade = "#ae2a2a", deep = "#6b1b2c" }))
c:seam({ {19, 43}, {45, 43} }, { free = true })
c:ground(32.5, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= MARGIN and t.bw <= 4, N .. " failed checks")
