-- ph/chili-jam (Pantry jam): A-shaped jar with slanted shoulders and no vertical sides, red lid, green chili-stalk knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "chili-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local jar = c:poly({ {21, 18}, {44, 18}, {52, 56}, {13, 56} }):closed(2)
c:build{
  { "glass", jar, "glass" },
  { "fill",  c:poly({ {23, 22}, {42, 22}, {49, 54}, {16, 54} }), "#e03a2a", { contour = "#7a1a14", gloss = { 24, 25 } } },
}
-- seed flecks and sugar glints
for _, p in ipairs({ {25,28}, {31,24}, {37,27}, {40,30}, {21,47}, {27,50}, {35,51}, {42,49}, {46,52}, {19,52} }) do c:px(p[1], p[2], "#f5cf6a") end
for _, p in ipairs({ {28,26}, {23,50}, {44,46} }) do c:px(p[1], p[2], "#ff9a80") end
c:part(c:ellipse(32, 41, 10, 7), "cream", { gloss = false, contact = false })
-- emblem: curled chili with a green stalk
c:paint({
  "......gg.",
  ".....gg..",
  "...rrrr..",
  "..rRrrrr.",
  ".rr...rr.",
  ".r.......",
  ".rr......",
  "..r......",
}, 27, 36, { r = "#d6322b", R = "#ff8a70", g = "#4f9a45" })
c:fill(c:rect(29, 40, 33, 40), "#d6322b")
c:paint({ "uu", "", "uu" }, 36, 42, { u = "#7a5a3a" })
c:part(c:rrect(20, 12, 45, 19, 3), "#a8241f")
c:seam({ {22, 18}, {43, 18} })
-- green chili stalk knob, curled over
c:part(c:rrect(30, 9, 34, 13, 1):add(c:rect(31, 6, 33, 9)):add(c:rect(33, 6, 37, 8)), "#4f9a45", { flat = true, contour = "#2f5a2a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
