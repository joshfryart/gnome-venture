-- ph/meyer-lemon-marmalade (Pantry marmalade): wide apothecary jar on a foot ring, flat glass lid with a ball knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "meyer-lemon-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "foot",  c:rrect(18, 51, 46, 55, 1), "glass" },
  { "glass", c:rrect(13, 28, 51, 52, 6), "glass" },
  { "fill",  c:rrect(15, 32, 49, 50, 5), "#f0b830", { contour = "#a8701a", gloss = { 18, 34 } } },
}
for _, p in ipairs({ {19,33}, {25,32}, {39,33}, {46,35}, {18,48}, {24,49}, {41,48}, {47,46} }) do
  c:px(p[1], p[2], "#f08a24"); c:px(p[1] + 1, p[2], "#c8561c")
end
c:part(c:rrect(21, 36, 43, 47, 2), "cream", { gloss = false, contact = false })
-- emblem: lemon slice with an orange-blushed rim
c:paint({
  "..ooooo..",
  ".oyyyyyo.",
  "oyyuyuyyo",
  "oyyyuyyyo",
  "oyyuyuyyo",
  ".oyyyyyo.",
  "..ooooo..",
}, 23, 38, { o = "#f08a24", y = "#f5d23a", u = "#fff3a0" })
c:paint({ "uuuu", "", "uuu" }, 35, 40, { u = "#7a5a3a" })
c:part(c:rrect(13, 22, 51, 28, 2), "#c9e6f2")
c:seam({ {15, 28}, {49, 28} })
c:part(c:rect(29, 18, 35, 23), "#c9e6f2", { flat = true })
c:part(c:ellipse(32, 15, 4.5, 4.5), "#c9e6f2", { gloss = false })
c:px(30, 13, "#ffffff"); c:px(31, 13, "#f0fbff"); c:px(30, 14, "#f0fbff")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
