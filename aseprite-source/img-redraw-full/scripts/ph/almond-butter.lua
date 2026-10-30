-- ph/almond-butter (Pantry spread): hexagonal faceted glass jar, pale almond butter, bamboo lid, almond label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "almond-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:poly({ {17, 21}, {48, 21}, {52, 25}, {52, 52}, {43, 57}, {23, 57}, {14, 52}, {14, 25} })
c:part(jar, "#d8ecf0", { pale = false, gloss = false })
-- side facets a shade deeper
c:fill(c:rect(14, 25, 22, 53):clip(jar):cut(jar:edge()), "#c8dde4")
c:fill(c:rect(43, 25, 51, 53):clip(jar):cut(jar:edge()), "#b4cdd8")
local fill = c:poly({ {18, 26}, {47, 26}, {50, 28}, {50, 51}, {42, 55}, {24, 55}, {16, 51}, {16, 28} })
c:part(fill, "#d6b98a", { gloss = { 25, 29 }, contact = false })
c:fill(c:rect(17, 28, 22, 52):clip(fill), "#e2c89c")
c:fill(c:rect(43, 28, 48, 52):clip(fill):cut(fill:edge()), "#c9a96e")
-- facet edges: bright glass ridges
c:fill(c:rect(23, 22, 23, 55):clip(jar), "#eef8f2"); c:fill(c:rect(24, 22, 24, 55):clip(jar), "#a9d6ea"); c:fill(c:rect(42, 22, 42, 55):clip(jar), "#6f98c4")
c:fill(c:line({ {15, 52}, {23, 56} }, 1), "#a9d6ea"); c:fill(c:line({ {43, 56}, {51, 52} }, 1), "#6f98c4")
c:fill(c:rect(18, 26, 41, 26), "#ecd8b0")
-- label on the front panel
c:part(c:rect(24, 34, 41, 47), "cream", { gloss = false, contact = false })
c:paint({
  ".....uuu..",
  "...uuAaau.",
  ".uuAaaaasu",
  "uaaaaaasu.",
  ".uussssu..",
}, 28, 38, { a = "#c9a96e", A = "#ecc58a", s = "#9a6b3f", u = "#7a4a1f" })
c:paint({ "uu.uuu.u" }, 28, 44, { u = "#9a6b3f" })
-- bamboo lid, also six-sided
local lid = c:poly({ {16, 12}, {50, 12}, {53, 15}, {53, 21}, {44, 24}, {22, 24}, {13, 21}, {13, 15} })
c:part(lid, "#c9a96e", { gloss = { 17, 14 } })
for _, x in ipairs({ 22, 32, 43 }) do c:fill(c:rect(x, 13, x, 21), "#9a6b3f"); c:px(x - 1, 16, "#9a6b3f"); c:px(x + 1, 16, "#9a6b3f") end
c:fill(c:rect(15, 20, 50, 20), "#9a6b3f")
c:fill(c:rect(22, 12, 22, 23):clip(lid), "#ecc58a"); c:fill(c:rect(43, 12, 43, 23):clip(lid), "#7a4a1f")
c:seam({ {15, 22}, {22, 24}, {43, 24}, {51, 22} }, { free = true })
c:ground(32, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
