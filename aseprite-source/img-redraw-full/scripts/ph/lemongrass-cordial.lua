-- ph/lemongrass-cordial (Pantry cordial): tall straight cylinder bottle, flared kraft-paper cap tied with string, pale green lemongrass cordial, three-blade label
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
-- flared paper cap: frilled collar over the mouth
local paper = c:poly({ {25, 6}, {40, 6}, {47, 21}, {44, 22}, {41, 20}, {38, 22}, {35, 20}, {32, 22}, {29, 20}, {26, 22}, {23, 20}, {20, 22}, {17, 21} })
c:part(paper, GV.ramp("#c9a96e", { shade = "#9a6b3f", deep = "#7a4a1f" }), { gloss = false, cres = 3, deep = 0 })
for _, l in ipairs({ { {28, 8}, {25, 19} }, { {32, 8}, {32, 19} }, { {36, 8}, {39, 19} } }) do c:fill(c:line(l, 1), "#9a6b3f") end
c:fill(c:rect(26, 7, 39, 7), "#e8d8b0")
c:seam({ {19, 20}, {46, 20} }, { free = true })
-- string round the neck with a bow on the left
c:fill(c:rect(23, 16, 41, 17), "#7a4a1f"); c:fill(c:rect(23, 16, 41, 16), "#9a6b3f")
c:part(c:ascii({ "xx.xx", "x.x.x", "xx.xx", ".x.x." }, 20, 15), "#9a6b3f", { flat = true, contact = false })
-- three lemongrass blades fanning from a swollen base
c:fill(c:line({ {32, 48}, {29, 42}, {27, 37} }, 1):add(c:line({ {32, 48}, {32, 36} }, 1)):add(c:line({ {32, 48}, {35, 42}, {37, 37} }, 1)), "#4f9a45")
c:fill(c:rect(30, 46, 33, 48), "#a4b86a"); c:fill(c:rect(30, 45, 33, 45), "#7ab55c")
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
