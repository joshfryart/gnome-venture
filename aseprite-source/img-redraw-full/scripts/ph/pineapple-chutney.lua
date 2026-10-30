-- ph/pineapple-chutney (Pantry chutney): oval jar with a diamond grid like pineapple skin, spiky leaf-crown lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pineapple-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- crown first (behind the lid base): five spiky leaves
local crown = c:poly({ {29, 20}, {31, 7}, {35, 20} })
crown:add(c:poly({ {25, 20}, {22, 9}, {30, 19} })):add(c:poly({ {34, 19}, {42, 9}, {39, 20} }))
crown:add(c:poly({ {23, 20}, {17, 13}, {27, 18} })):add(c:poly({ {37, 18}, {47, 13}, {41, 20} }))
c:build{
  { "glass", c:ellipse(32, 39, 18, 16), "glass" },
  { "fill",  c:ellipse(32, 40, 16, 13.5), "#e8b830", { contour = "#a8701a", gloss = { 21, 34 } } },
}
-- diamond grid embossed on the jar, every 6 px
local fill = c:ellipse(32, 40, 16, 13.5)
local grid = c:mask()
for k = -60, 120, 6 do
  grid:add(c:line({ {k, 20}, {k + 40, 60} }, 1)):add(c:line({ {k + 40, 20}, {k, 60} }, 1))
end
grid:clip(fill):cut(c:rrect(23, 33, 41, 47, 2))
c:fill(grid, "#c88a1a")
for _, p in ipairs({ {24,30}, {36,29}, {19,44}, {44,42}, {30,51} }) do c:px(p[1], p[2], "#d6322b") end
c:part(c:rrect(24, 34, 40, 46, 2), "cream", { gloss = false, contact = false })
-- emblem: pineapple with crown and grid dots
c:paint({
  "..g.g.g..",
  "...ggg...",
  "..yyyyy..",
  ".yYydyyy.",
  ".ydyyydy.",
  ".yyydyys.",
  ".ydyyyds.",
  "..yysss..",
}, 28, 36, { y = "#e8b830", Y = "#fff3a0", d = "#a8701a", s = "#c88a1a", g = "#4f9a45" })
c:part(crown, "#4f9a45", { contour = "#2f5a2a", gloss = false })
c:fill(c:line({ {32, 10}, {32, 17} }, 1), "#7ab55c")
c:px(23, 12, "#7ab55c"); c:px(41, 12, "#2f5a2a")
c:part(c:rrect(22, 17, 42, 25, 2), "#4f9a45", { contour = "#2f5a2a" })
c:seam({ {24, 24}, {40, 24} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
