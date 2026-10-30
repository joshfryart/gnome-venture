-- ph/date-chutney (Pantry chutney): short wide jar of very dark date chutney, brass onion-dome cap, arch label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "date-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(14, 28, 50, 55, 5), "glass" },
  { "fill",  c:rrect(16, 32, 48, 53, 4), "#4a2a1c", { contour = "#2a1a10", gloss = { 19, 35 } } },
}
for _, p in ipairs({ {20,40}, {23,50}, {45,38}, {43,49}, {19,46}, {46,44} }) do c:px(p[1], p[2], "#b07a10") end
-- arch label (round top)
c:part(c:rect(22, 39, 42, 50):add(c:ellipse(32, 39, 10, 5)), "cream", { gloss = false, contact = false })
-- emblem: date palm with two dates
c:paint({
  ".gg...gg.",
  "g..ggg..g",
  "..g.t.g..",
  "....t....",
  "...dtd...",
  "..dDtdd..",
  "..dd.dd..",
  "....t....",
}, 28, 37, { g = "#4f9a45", t = "#9a6b3f", d = "#7a4a1f", D = "#b08050" })
-- brass cap base and onion dome with a finial
c:part(c:rect(16, 23, 48, 29), "#b07a10")
c:seam({ {18, 28}, {46, 28} })
local dome = c:ellipse(32, 18, 12, 6):add(c:poly({ {25, 14}, {39, 14}, {33, 9}, {31, 9} }))
c:part(dome, "#e8a317", { gloss = { 26, 15 } })
c:part(c:rect(31, 6, 32, 9), "#e8a317", { flat = true })
c:fill(c:rect(21, 22, 43, 22), "#b07a10")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
