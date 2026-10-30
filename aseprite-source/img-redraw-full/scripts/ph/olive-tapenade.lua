-- ph/olive-tapenade (Pantry spread): low wide rectangular terrine, dark flat clip lid, an olive on a cocktail pick
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "olive-tapenade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(10, 32, 54, 55, 3), "glass" },
  { "fill",  c:rrect(12, 35, 52, 53, 2), "#3a3a20", { contour = "#1a1a10", gloss = { 13, 38 } } },
}
for _, p in ipairs({ {14,41}, {15,48}, {14,51}, {49,40}, {50,47}, {48,51}, {15,37}, {49,36} }) do c:px(p[1], p[2], "#7ab55c") end
for _, p in ipairs({ {16,43}, {48,44}, {14,46} }) do c:px(p[1], p[2], "#5a5a34") end
c:part(c:rrect(18, 38, 46, 50, 2), "cream", { gloss = false, contact = false })
-- emblem: green and black olive on a twig
c:paint({
  "..tttttt..",
  ".t.l..t...",
  ".gg..kk.l.",
  "gGgg.kKkk.",
  "gggg.kkkk.",
  ".gs...kk..",
}, 20, 40, { t = "#7a5a3a", l = "#7ab55c", g = "#7a8a30", G = "#b8c870", s = "#4f5a1a", k = "#2a1a10", K = "#6a5a50" })
c:paint({ "uuuuu", "", "uuuu", "", "uuuuu" }, 36, 41, { u = "#7a5a3a" })
-- dark flat lid with grey clip pegs at both ends
c:part(c:rrect(9, 25, 55, 33, 2), "#3d2f2a", { contour = "#1a100a" })
c:fill(c:rect(11, 26, 53, 26), "#6a5a50")
c:seam({ {11, 33}, {53, 33} })
c:part(c:rrect(9, 28, 13, 38, 1), "#8b8f96", { flat = true })
c:part(c:rrect(51, 28, 55, 38, 1), "#8b8f96", { flat = true })
-- cocktail pick with an olive
c:fill(c:line({ {41, 25}, {45, 15} }, 1), "#c9a96e")
c:part(c:ellipse(46, 10, 4, 4.5), "#6a8a30", { contour = "#2f3a14", gloss = false })
c:px(44, 8, "#c8d890"); c:px(44, 9, "#a4b86a"); c:px(45, 8, "#a4b86a")
c:paint({ "rr", "rr" }, 46, 10, { r = "#d6322b" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
