-- ph/yuzu-marmalade (Pantry marmalade): tall jar tapering to the base, woven bamboo cap tied with a red cord knot
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "yuzu-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:poly({ {19, 18}, {46, 18}, {43, 56}, {22, 56} }):closed(1)
c:build{
  { "glass", glass, "glass" },
  { "fill",  c:poly({ {21, 22}, {44, 22}, {41, 54}, {24, 54} }), "#e8d870", { contour = "#9a8a30", gloss = { 24, 25 } } },
}
-- fine peel flecks
for _, p in ipairs({ {25,27}, {31,24}, {38,26}, {42,29}, {23,30}, {27,48}, {33,51}, {38,47}, {29,52}, {36,53} }) do
  c:px(p[1], p[2], "#b0a040"); c:px(p[1] + 1, p[2], "#f0a030")
end
c:part(c:rrect(24, 32, 40, 44, 2), "cream", { gloss = false, contact = false })
-- emblem: bumpy yuzu with a leaf
c:paint({
  "....ugg.",
  ".y.yu.g.",
  "yYyyyyy.",
  "yyyyyyyy",
  ".yyyyyys",
  "yyyyyyss",
  ".ysysss.",
}, 28, 34, { y = "#e8c840", Y = "#fff3a0", s = "#b0901a", u = "umber", g = "#4f9a45" })
-- bamboo cap: slats + node bands
c:part(c:rrect(18, 8, 46, 20, 2), "#c9a96e", { contour = "#7a4a1f", gloss = { 21, 10 } })
for x = 22, 43, 4 do c:fill(c:rect(x, 9, x, 19), x < 32 and "#b08a50" or "#9a6b3f") end
c:fill(c:rect(19, 12, 45, 12), "#9a6b3f"); c:fill(c:rect(19, 16, 45, 16), "#9a6b3f")
c:seam({ {20, 20}, {44, 20} })
-- red cord round the cap and a knot with tails
c:fill(c:rect(19, 14, 45, 14), "#d6322b")
c:part(c:rrect(29, 17, 35, 22, 2), "#d6322b", { flat = true })
c:fill(c:line({ {30, 23}, {28, 28} }, 1), "#a8241f")
c:fill(c:line({ {34, 23}, {36, 28} }, 1), "#a8241f")
c:px(31, 18, "#f07060")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
