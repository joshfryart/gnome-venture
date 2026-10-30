-- ph/coriander-chutney (Pantry chutney): round jar on a stemmed pedestal foot, flat gold lid, coriander leaf on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "coriander-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "foot",  c:rrect(21, 51, 43, 56, 2), "glass" },
  { "stem",  c:rect(27, 45, 37, 52), "glass", { gloss = false } },
  { "glass", c:rrect(14, 20, 50, 47, 8), "glass" },
  { "fill",  c:rrect(16, 24, 48, 45, 6), "#4f9a45", { contour = "#2a5a20", gloss = { 19, 27 } } },
}
for _, p in ipairs({ {20,26}, {27,25}, {37,26}, {44,28}, {18,40}, {24,43}, {40,43}, {45,40} }) do c:px(p[1], p[2], "#a4b86a") end
c:part(c:rrect(22, 30, 42, 41, 2), "cream", { gloss = false, contact = false })
-- emblem: ruffled three-lobed coriander leaf
c:paint({
  "..g.g....",
  ".gGggg...",
  "g.gvg.gg.",
  ".gg.vgGgg",
  "..g.gvg.g",
  ".....t...",
  ".....t...",
}, 24, 32, { g = "#4f9a45", G = "#8cc060", v = "#2f5a2a", t = "#7a5a3a" })
c:paint({ "uuu", "", "uu" }, 35, 34, { u = "#7a5a3a" })
c:part(c:rrect(15, 14, 49, 22, 3), "gold")
c:seam({ {17, 21}, {47, 21} })
-- fresh lobed leaf poking out of the lid
c:fill(c:line({ {31, 15}, {34, 11} }, 1), "#4a8a3e")
c:part(c:ellipse(32, 10, 3, 2.5):add(c:ellipse(37, 8, 3, 2.5)):add(c:ellipse(39, 12, 2.5, 2.5)), "#7ab55c", { contour = "#2f5a2a", gloss = false })
c:px(31, 9, "#b8e08a"); c:px(36, 7, "#b8e08a"); c:fill(c:line({ {34, 11}, {37, 9} }, 1), "#4f9a45")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
