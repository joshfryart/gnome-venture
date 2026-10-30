-- ph/tahini (Pantry spread): tall narrow tin can, foil half peeled and rolled back across the top, pull-ring standing up, tahini showing, sesame sprig on a paper wrapper
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tahini"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- top seen from above: the back half is still foil, the front half is peeled off and rolled back into a
-- bright tube across the middle, showing the pale tahini; the pull-ring stands up at the end of the roll
local foil = GV.ramp("#aab4be", { gloss = "#eef2f4", dot = "#f6f8f8", rim = "#dfe4e8", shade = "#7d8894", deep = "#5b6470", bounce = "#8b96a2" })
local can = c:rrect(18, 19, 46, 55, 3)
c:part(can, "#c9c5bc", { gloss = false, contact = false })
c:fill(c:rect(20, 26, 21, 52), "#f4f0e0")
c:fill(c:rect(19, 52, 45, 52), "#8b8f96")
local top = c:ellipse(32, 18, 14, 6)
c:part(top, "#8b8f96", { flat = true, contact = false, rim = false })                     -- tin rim
local inner = c:ellipse(32, 18, 12, 4.5)
c:part(inner:copy():cut(c:rect(0, 0, 63, 17)), GV.ramp("#d6b98a", { rim = "#ecd8b0" }), { flat = true, contact = false, contour = false })   -- tahini
c:fill(c:line({ {24, 20}, {29, 19}, {34, 21}, {39, 20} }, 1):clip(inner), "#ecd8b0"); c:px(30, 21, "#b8925a"); c:px(36, 21, "#b8925a")
c:part(inner:copy():clip(c:rect(0, 0, 63, 15)), GV.ramp("#aab4be", { rim = "#dfe4e8" }), { flat = true, contact = false, contour = false })   -- foil still on
-- the rolled foil: a bright tube with a dark underside
c:part(c:rrect(20, 14, 44, 17, 2), foil, { gloss = false, cres = 2, deep = 0, contact = false, contour = "#5b6470" })
c:fill(c:rect(22, 15, 41, 15), "#eef2f4")
-- pull-ring standing up at the left end of the roll (pokes above the rim)
c:part(c:ellipse(22, 11, 2.5, 3), "#5b6470", { flat = true, contact = false, contour = false })
c:fill(c:rect(22, 10, 22, 12), "#2a1a10"); c:px(21, 9, "#dfe4e8")
-- paper wrapper with umber borders and stitch dashes
local wrap = c:rect(18, 26, 46, 50)
c:part(wrap, "cream", { gloss = false, contact = false })
c:fill(c:rect(18, 26, 46, 26), "#7a4a1f"); c:fill(c:rect(18, 50, 46, 50), "#7a4a1f")
for x = 20, 44, 3 do c:px(x, 28, "#e8a317"); c:px(x + 1, 48, "#e8a317") end
-- sesame sprig: stem, paired pods, a few loose seeds
c:fill(c:rect(32, 30, 32, 45), "#4f9a45")
for _, p in ipairs({ {28, 31}, {34, 31}, {28, 36}, {34, 36}, {28, 41}, {34, 41} }) do
  c:paint({ "pp", "pP", "pp", "ss" }, p[1] + (p[1] < 32 and 1 or -1), p[2], { p = "#c9a96e", P = "#9a6b3f", s = "#4f9a45" })
end
c:paint({ "uu" }, 31, 29, { u = "#c9a96e" })
for _, p in ipairs({ {24, 44}, {39, 43}, {41, 45} }) do c:px(p[1], p[2], "#d6b98a"); c:px(p[1] + 1, p[2], "#9a6b3f") end
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
