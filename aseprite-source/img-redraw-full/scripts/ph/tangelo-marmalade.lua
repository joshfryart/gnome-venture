-- ph/tangelo-marmalade (Pantry marmalade): bell-shaped jar, narrow neck swelling to a wide base, gold cap with a nub
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tangelo-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bell = c:ellipse(32, 45, 18, 10):add(c:poly({ {26, 15}, {39, 15}, {41, 26}, {49, 42}, {15, 42}, {23, 26} })):closed(2)
c:build{
  { "glass", bell, "glass" },
  { "fill",  bell:shrink(2):cut(c:rect(0, 0, 63, 21)), "#e8a020", { contour = "#a8561a", gloss = { 27, 25 } } },
}
-- peel strands
for _, l in ipairs({ { {22,38}, {25,35} }, { {40,34}, {43,37} }, { {20,49}, {24,51} }, { {41,51}, {45,48} }, { {30,24}, {33,26} } }) do
  c:fill(c:line(l, 1), "#f5cf6a")
end
c:part(c:rrect(22, 37, 42, 48, 2), "cream", { gloss = false, contact = false })
-- emblem: bell-shaped tangelo with a nipple tip and a leaf
c:paint({
  "...u.gg",
  "..oou.g",
  "..ooo..",
  ".oOooo.",
  "ooooooo",
  "oooooos",
  ".ossss.",
}, 24, 39, { o = "#f08a24", O = "#ffd38a", s = "#c8561c", u = "umber", g = "#4f9a45" })
c:paint({ "uuu", "", "uu" }, 35, 42, { u = "#7a5a3a" })
c:part(c:rrect(24, 11, 40, 17, 2), "#e8a317")
c:seam({ {26, 17}, {38, 17} })
c:part(c:ellipse(32, 8, 2.5, 2.5), "#e8a317", { flat = true })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
