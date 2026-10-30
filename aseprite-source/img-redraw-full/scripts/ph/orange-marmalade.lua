-- ph/orange-marmalade (Pantry marmalade): round glass jar of amber jelly with fine peel shreds, round orange-slice badge, domed gold lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "orange-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local lid = c:ellipse(32, 18, 17, 7):clip(c:rect(0, 0, 63, 18)):add(c:rrect(15, 17, 49, 23, 1))
c:build{
  { "glass", c:rrect(14, 22, 50, 54, 12), "glass" },
  { "jelly", c:rrect(16, 26, 48, 52, 10), "#f08a24", { contour = "#a8461a", gloss = { 19, 31 } } },
  { "badge", c:ellipse(32, 41, 8, 8), "cream", { gloss = false, contact = false } },
  { "lid",   lid, "gold", { gloss = { 21, 14 } } },
}
-- peel shreds: short 1 px diagonals suspended in the jelly
for _, s in ipairs({ {20, 34}, {24, 29}, {41, 29}, {45, 34}, {19, 45}, {44, 46}, {23, 50}, {39, 50}, {30, 28}, {36, 30} }) do
  for i = 0, 2 do local x, y = s[1] + i, s[2] - i if c:get(x, y) == "#f08a24" then c:px(x, y, "#d6322b") end end
end
c:fill(c:rect(16, 18, 48, 18), "#f5cf6a")                 -- rim highlight where the dome meets the band
c:seam({ {16, 22}, {48, 22} })
-- badge: orange slice, rind ring with radial segment ticks
c:paint({
  "...rrrrr...",
  "..roooooRr.",
  ".rotoyotor.",
  "roootyoooor",
  "royyyyyyyor",
  "rooootyooor",
  "rootoyotoor",
  ".roooooooR.",
  "..rrrrrrr..",
}, 27, 37, { r = "#c8561c", R = "#a8461a", o = "#f08a24", y = "#f5cf6a", t = "#ffd38a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
