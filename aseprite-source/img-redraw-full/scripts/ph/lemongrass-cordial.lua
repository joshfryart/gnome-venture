-- ph/lemongrass-cordial (Pantry cordial): tall straight cylinder bottle, rounded kraft-paper cap tied with string over a short pinked frill, pale green lemongrass cordial, three-blade label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "lemongrass-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:rrect(21, 17, 43, 56, 4), "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(23, 23, 41, 54, 3), GV.ramp("#c8d77a", { shade = "#a4b86a", deep = "#7ab55c", gloss = "#eef2c0", dot = "#f6f8dc" }), { contour = "#8a9a4a", gloss = { 25, 26 } } },
  { "label",  c:rect(24, 34, 40, 50), "cream", { gloss = false, contact = false } },
}
-- paper cap: a soft rounded puff over the mouth, tied tight at the neck, with a short pinked frill
-- skirt below the string that stays inside the bottle width (the old wide trapezoid read as a roof)
local kraft = GV.ramp("#c9a96e", { shade = "#9a6b3f", deep = "#7a4a1f", rim = "#e8d8b0", bounce = "#a8742f" })
c:part(c:ellipse(32, 11, 8, 5):add(c:rect(26, 11, 38, 15)), kraft, { gloss = { 28, 8 }, cres = 3, deep = 0 })
c:fill(c:line({ {30, 9}, {29, 14} }, 1):add(c:line({ {35, 9}, {36, 14} }, 1)), "#a8742f")
-- frill skirt: pinked bottom edge (zig-zag), paler paper so it reads as paper, not roof tiles
local frill = c:poly({ {25, 16}, {39, 16}, {43, 20}, {43, 21}, {42, 22}, {41, 21}, {40, 22}, {39, 21}, {38, 22}, {37, 21}, {36, 22}, {35, 21}, {34, 22}, {33, 21}, {32, 22}, {31, 21}, {30, 22}, {29, 21}, {28, 22}, {27, 21}, {26, 22}, {25, 21}, {24, 22}, {23, 21}, {22, 22}, {21, 21}, {21, 20} })
c:part(frill, GV.ramp("#e8d8b0", { shade = "#b8925a", deep = "#9a6b3f", bounce = "#c9a96e", rim = "#f4ecd0" }), { gloss = false, cres = 2, deep = 0, pale = true })
for x = 22, 42, 2 do c:px(x, 21, "#b8925a") end
c:seam({ {23, 19}, {41, 19} }, { free = true })
-- string tied tight round the neck, bow loops and tails on the left
c:fill(c:rect(25, 15, 39, 16), "#7a4a1f"); c:fill(c:rect(25, 15, 39, 15), "#9a6b3f")
c:part(c:ascii({ "xx.xx", "x.x.x", "xx.xx", ".x.x.", "x...x" }, 20, 13), "#9a6b3f", { flat = true, contact = false })
-- three lemongrass blades fanning from a swollen base
c:fill(c:line({ {32, 48}, {29, 42}, {27, 37} }, 1):add(c:line({ {32, 48}, {32, 36} }, 1)):add(c:line({ {32, 48}, {35, 42}, {37, 37} }, 1)), "#4f9a45")
c:fill(c:rect(30, 46, 33, 48), "#a4b86a"); c:fill(c:rect(30, 45, 33, 45), "#7ab55c")
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
