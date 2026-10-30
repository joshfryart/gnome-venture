-- ph/cranberry-cordial (Pantry cordial): conical Erlenmeyer flask, cork, orange ribbon bow at the neck, ruby cranberry cordial, berry-cluster label with an orange-peel curl
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cranberry-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local flask = c:poly({ {26, 25}, {39, 25}, {56, 54}, {55, 56}, {54, 57}, {11, 57}, {10, 56}, {9, 54} }):add(c:rect(27, 12, 37, 26))
c:build{
  { "glass",  flask, "#d8ecf0", { pale = false } },
  { "liquid", c:poly({ {24, 34}, {41, 34}, {52, 54}, {51, 55}, {14, 55}, {13, 54} }), GV.ramp("#a8241f", { shade = "#7a1a16" }), { contour = "#7a1a16", gloss = { 25, 37 } } },
  { "label",  c:rect(24, 41, 40, 51), "cream", { gloss = false, contact = false } },
}
c:part(c:rect(28, 7, 36, 13), "#c9a96e", { gloss = false })
c:fill(c:rect(28, 10, 36, 10), "#9a6b3f"); c:px(30, 8, "#9a6b3f"); c:px(34, 12, "#9a6b3f")
c:seam({ {28, 14}, {36, 14} }, { free = true })
-- ribbon bow at the neck: two loops, knot, two tails
local bow = c:ellipse(26, 21, 3.5, 2.5):add(c:ellipse(38, 21, 3.5, 2.5)):add(c:rect(30, 19, 34, 23))
bow:add(c:line({ {30, 23}, {28, 28} }, 2)):add(c:line({ {34, 23}, {36, 28} }, 2))
c:part(bow, GV.ramp("#e0501f", { shade = "#ae2a2a" }), { gloss = false, cres = 2, deep = 0 })
c:fill(c:rect(31, 20, 33, 22), "#a8241f"); c:px(31, 20, "#f08a24")
c:px(25, 21, "#a8241f"); c:px(39, 21, "#a8241f")
-- berries + leaf + orange peel curl
for _, b in ipairs({ {26, 46}, {30, 46}, {34, 46}, {28, 43} }) do
  c:paint({ ".r.", "rRr", ".r." }, b[1], b[2], { r = "#a8241f", R = "#e0501f" })
end
c:paint({ "gg", ".g" }, 31, 42, { g = "#4f9a45" })
c:paint({ ".oo", "o..", ".o." }, 37, 44, { o = "#f08a24" })
c:ground(32, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
