-- ph/sea-buckthorn-juice (Pantry cordial): round Florence flask, long thin neck wound with twine, orange sea buckthorn juice, berry-twig tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "sea-buckthorn-juice"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:ellipse(32, 41, 14):add(c:rect(29, 11, 35, 28))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 42, 12), GV.ramp("#f08a24", { shade = "#c8661f" }), { contour = "#a8541a", gloss = { 25, 36 } } },
}
c:part(c:rect(29, 6, 35, 11), "#c9a96e", { gloss = false })
c:px(31, 8, "#9a6b3f"); c:px(33, 10, "#9a6b3f")
-- twine wound round the neck, loose tail
for y = 13, 23, 2 do c:fill(c:rect(29, y, 35, y), "#c9a96e"); c:px(35, y, "#9a6b3f"); c:fill(c:rect(29, y + 1, 35, y + 1), "#9a6b3f") end
c:part(c:line({ {36, 23}, {38, 26}, {37, 29} }, 1), "#c9a96e", { flat = true, contact = false })
-- tag on a string with a twig of berries
c:fill(c:line({ {33, 27}, {32, 38} }, 1), "#9a6b3f")
c:part(c:rrect(25, 39, 39, 51, 1), "cream", { gloss = false, contact = false })
c:px(32, 40, "#9a6b3f")
c:fill(c:line({ {28, 49}, {36, 42} }, 1), "#7a4a1f")
for _, b in ipairs({ {29, 46}, {32, 44}, {34, 47}, {35, 42}, {31, 48} }) do c:paint({ "oO", "oo" }, b[1], b[2], { o = "#f08a24", O = "#f5cf6a" }) end
c:paint({ "gg" }, 26, 47, { g = "#a4b86a" }); c:paint({ "gg" }, 37, 41, { g = "#a4b86a" })
c:ground(32, 57, 11, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
