-- ph/sunflower-butter (Pantry spread): bail-top glass jar, glass lid on a red rubber seal held by a wire clamp, sunflower label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "sunflower-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(14, 23, 50, 55, 8), "glass", { gloss = false } },
  { "fill",  c:rrect(16, 28, 48, 53, 6), "#c8a02f", { contour = "#a8841f", gloss = { 19, 31 } } },
  { "lid",   c:rrect(16, 13, 48, 23, 4), "#c8dde4", { pale = false, gloss = { 19, 15 } } },
}
c:fill(c:rect(19, 28, 45, 28), "#e8c860")
-- red rubber seal with its pull tab
c:part(c:rect(15, 23, 49, 25), "#a8441f", { flat = true, contact = false })
c:part(c:rect(9, 24, 14, 26), "#a8441f", { flat = true, contact = false })
-- wire bail: hinge pins on the neck, wire over the lid, latch bar on top
local wire = c:line({ {13, 27}, {13, 16}, {15, 11}, {49, 11}, {51, 16}, {51, 27} }, 2)
c:part(wire, "stone", { flat = true, contact = false })
c:part(c:rrect(27, 9, 37, 13, 1), "#5b6470", { flat = true, contact = false })
c:px(28, 10, "#c9c5bc")
-- label with a sunflower
c:part(c:ellipse(32, 42, 10, 9), "cream", { gloss = false, contact = false })
c:paint({
  "....p.p....",
  "..pp.p.pp..",
  ".pp.ppp.pp.",
  "p.pkkkkkp.p",
  ".ppkKkkkpp.",
  "pp.kkkkk.pp",
  ".ppkkkkkpp.",
  "p.pkkkkkp.p",
  ".pp.ppp.pp.",
  "..pp.p.pp..",
  "....p.p....",
}, 27, 37, { p = "#e8a317", k = "#7a4a1f", K = "#a8742f" })
c:ground(32, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
