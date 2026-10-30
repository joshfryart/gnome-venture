-- ph/lingonberry-cordial (Pantry cordial): tall slim green-glass bottle, neck dipped in dripping red wax, bright red lingonberry cordial, sprig label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "lingonberry-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(23, 23, 41, 56, 5):add(c:rect(28, 10, 36, 24)):add(c:poly({ {28, 19}, {37, 19}, {42, 27}, {23, 27} }))
c:build{
  { "glass",  glass, GV.ramp("#9ec3c8"), { pale = false } },
  { "liquid", c:rrect(25, 28, 39, 54, 4), GV.ramp("#d6322b", { shade = "#a8241f", gloss = "#ff9158", rim = "#f2793a" }), { contour = "#8a1f1a", gloss = { 27, 31 } } },
  { "label",  c:rect(25, 37, 39, 50), "cream", { gloss = false, contact = false } },
}
-- bulbous wax dip with two drips down the neck
local wax = c:rrect(26, 6, 38, 17, 4):add(c:rrect(27, 17, 28, 23, 1)):add(c:rrect(35, 17, 36, 20, 1)):add(c:rect(27, 15, 37, 18))
c:part(wax, GV.ramp("#a8241f", { rim = "#d6322b", gloss = "#f2793a", dot = "#ff9158" }), { cres = 2, gloss = { 29, 8 } })
c:fill(c:rect(29, 9, 30, 13), "#d6322b")
-- sprig: stem, three leaves, three berries
c:fill(c:line({ {28, 48}, {36, 40} }, 1), "#4f9a45")
c:paint({ "gg", "gg" }, 27, 44, { g = "#4f9a45" }); c:paint({ "ggg" }, 33, 46, { g = "#4f9a45" }); c:paint({ "gg" }, 35, 39, { g = "#4f9a45" })
for _, b in ipairs({ {29, 41}, {32, 39}, {34, 43} }) do
  c:paint({ ".r.", "rRr", ".r." }, b[1] - 1, b[2] - 1, { r = "#d6322b", R = "#f2793a" })
end
c:ground(32, 57, 10, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
