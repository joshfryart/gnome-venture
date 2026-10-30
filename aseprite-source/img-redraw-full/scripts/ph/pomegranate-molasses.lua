-- ph/pomegranate-molasses (Pantry cordial): spherical oil cruet, long neck, pointed dark metal spout stopper with a flip nub, deep wine molasses, crowned pomegranate label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "pomegranate-molasses"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:ellipse(32, 43, 13):add(c:rect(28, 21, 36, 32)):add(c:rect(26, 20, 38, 21)), "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 44, 11):add(c:rect(30, 30, 34, 34)), GV.ramp("#6a1f2a", { rim = "#a8241f", gloss = "#d6322b", dot = "#f08a7a" }), { contour = "#4a141e", gloss = false } },
}
c:fill(c:line({ {23, 44}, {24, 39}, {27, 36} }, 2), "#a8241f")
-- metal collar + tall cone spout with a flip nub
c:part(c:rect(27, 17, 37, 20), "stone", { gloss = false, cres = 2 })
c:part(c:poly({ {28, 17}, {37, 17}, {33, 8}, {32, 8} }), GV.ramp("#5b6470", { rim = "#8b8f96" }), { gloss = false, cres = 2 })
c:fill(c:line({ {30, 15}, {32, 10} }, 1), "#c9c5bc")
c:part(c:rect(33, 6, 35, 8), "#5b6470", { flat = true, contact = false })
c:seam({ {27, 19}, {37, 19} }, { free = true })
-- label: pomegranate with a crown, two seed dots
c:part(c:rect(24, 39, 40, 53), "cream", { gloss = false, contact = false })
c:paint({
  ".r.r.r.",
  ".rrrrr.",
  "..rrr..",
  ".rrrrr.",
  "rRrrrrr",
  "rRrprrr",
  "rrrrrps",
  ".rrrrs.",
  "..sss..",
}, 29, 41, { r = "#a8241f", R = "#e0501f", p = "#f6b8cf", s = "#6a1f2a" })
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
