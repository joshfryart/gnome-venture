-- ph/marzipan (Pantry candied): cream marzipan loaf in a twisted wax-paper wrapper (candy silhouette), moulded pear and strawberry in front
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "marzipan"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- twisted tails, then the loaf over their pinch
local tails = c:poly({ {16, 29}, {12, 30}, {9, 22}, {7, 25}, {7, 39}, {9, 42}, {12, 34}, {16, 35} })
tails:add(c:poly({ {48, 29}, {52, 30}, {55, 22}, {57, 25}, {57, 39}, {55, 42}, {52, 34}, {48, 35} }))
c:part(tails, "#f4f0e0", { gloss = false })
for _, l in ipairs({ { {12, 31}, {9, 25} }, { {12, 32}, {8, 32} }, { {12, 33}, {9, 39} }, { {52, 31}, {55, 25} }, { {52, 32}, {56, 32} }, { {52, 33}, {55, 39} } }) do
  c:fill(c:line(l, 1), "#c9c5bc")
end
c:fill(c:rect(11, 30, 12, 34), "#d8c49a"); c:fill(c:rect(52, 30, 53, 34), "#d8c49a")
local loaf = c:rrect(13, 21, 51, 43, 7)
c:part(loaf, "#f4e8c0", { gloss = { 18, 25 } })
for x = 16, 48, 3 do c:px(x, 23, "#e8a317"); c:px(x + 1, 41, "#e8a317") end
-- pink wrapper stripe and the almond label
c:part(c:rect(14, 28, 50, 30), "petal", { flat = true, contact = false })
c:part(c:rrect(23, 33, 41, 41, 1), "cream", { gloss = false, contact = false })
c:paint({
  "....uuuu....",
  "..uuAaaaau..",
  ".uAaaaaaasu.",
  "uaaaaaaassu.",
  ".uuussssuu..",
}, 26, 35, { a = "#c9a96e", A = "#ecc58a", s = "#9a6b3f", u = "#7a4a1f" })
-- moulded fruits in front
local pear = c:ellipse(24, 51, 4, 4):add(c:ellipse(24, 46, 2.5, 3))
c:part(pear, "#c8d77a", { gloss = { 22, 45 }, cres = 2 })
c:fill(c:rect(24, 41, 24, 43), "#7a4a1f"); c:px(25, 41, "#4f9a45"); c:px(26, 41, "#4f9a45")
c:px(24, 55, "#2a1a10")
local berry = c:poly({ {33, 46}, {44, 46}, {43, 51}, {39, 56}, {38, 56}, {34, 51} })
c:part(berry, "#d6322b", { gloss = { 35, 48 }, cres = 2 })
for _, p in ipairs({ {37, 49}, {41, 49}, {39, 52}, {36, 51}, {42, 51} }) do c:px(p[1], p[2], "#f5cf6a") end
c:part(c:poly({ {34, 44}, {43, 44}, {41, 47}, {36, 47} }), "leaf", { flat = true, contact = false })
c:px(38, 42, "#2f5a2a"); c:px(38, 43, "#2f5a2a")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
