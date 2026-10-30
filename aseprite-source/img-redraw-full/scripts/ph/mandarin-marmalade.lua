-- ph/mandarin-marmalade (Pantry marmalade): tiny squat ribbed bulb jar, orange cap with a twin upright leaf crest
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "mandarin-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(17, 29, 47, 55, 10), "glass" },
  { "fill",  c:rrect(19, 33, 45, 53, 8), "#f0a030", { contour = "#a8561a", gloss = { 22, 36 } } },
}
-- five faint segment ribs on the bulb (above and below the label)
for _, x in ipairs({ 22, 27, 32, 37, 42 }) do
  c:fill(c:rect(x, 35, x, 37), "#f5c060"); c:fill(c:rect(x, 50, x, 51), "#c8701c")
end
c:part(c:rrect(23, 39, 41, 48, 2), "cream", { gloss = false, contact = false })
-- emblem: a little mandarin with a leaf
c:paint({
  "...ug..",
  ".oouggg",
  "oOooooo",
  "ooooooo",
  "oooooos",
  ".ossss.",
}, 25, 40, { o = "#f08a24", O = "#ffd38a", s = "#c8561c", u = "umber", g = "#4f9a45" })
c:paint({ "uuu", "", "uu" }, 35, 42, { u = "#7a5a3a" })
c:part(c:rrect(21, 23, 43, 31, 3), "#f08a24")
c:seam({ {23, 30}, {41, 30} })
-- two upright leaves either side of a stem nub
c:part(c:poly({ {31, 25}, {24, 19}, {22, 12}, {23, 9}, {27, 11}, {31, 17} }), "#4f9a45", { contour = "#2f5a2a", gloss = { 25, 13 } })
c:part(c:poly({ {34, 25}, {41, 19}, {43, 12}, {42, 9}, {38, 11}, {34, 17} }), "#4f9a45", { contour = "#2f5a2a", gloss = false })
c:fill(c:line({ {29, 22}, {25, 13} }, 1), "#2f5a2a")
c:fill(c:line({ {35, 22}, {39, 13} }, 1), "#2f5a2a")
c:part(c:rrect(30, 19, 34, 24, 1), "#7a4a1f", { flat = true })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
