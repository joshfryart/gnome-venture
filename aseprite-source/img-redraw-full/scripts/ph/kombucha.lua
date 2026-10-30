-- ph/kombucha (Pantry ferment): jar of amber tea under a cloth cover tied with gold, scoby layer, rising bubbles
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "kombucha"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(18, 22, 46, 55, 7), "glass" },
  { "tea",   c:rrect(20, 28, 44, 53, 5), "#c9a96e", { contour = "#8a5a2f", gloss = { 22, 34 } } },
  { "scoby", c:rrect(20, 27, 44, 30, 1), "#efe0bc", { gloss = false, contact = false, cres = 2, deep = 0 } },
}
-- cloth cover: cream felt dome over the mouth, gold tie, skirt with pointed corners hanging below
local dome = c:rrect(17, 8, 47, 20, 6)
local skirt = c:poly({ {15, 19}, {49, 19}, {50, 32}, {46, 26}, {40, 29}, {32, 26}, {24, 29}, {18, 26}, {14, 32} })
c:part(skirt:add(dome), "cream", { stitch = { side = "lit" } })
c:part(c:rrect(16, 18, 48, 22, 1), "gold", { gloss = false, cres = 2, deep = 0 })   -- tie band
c:seam({ {17, 20}, {47, 20} }, { gap = "#b8661a" })
c:paint({ "gg..gg", "gggggg", ".gkkg.", "gg..gg", "g....g" }, 37, 18, { g = "#e8a317", k = "#b8661a" })   -- bow
for _, b in ipairs({ {27, 44}, {33, 40}, {29, 36}, {36, 32} }) do c:px(b[1], b[2], "#fbf6e8") end
c:px(38, 47, "#e8d0a0"); c:px(25, 49, "#e8d0a0")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
