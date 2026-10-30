-- ph/candied-ginger (Pantry candied): shallow confectioner's box, lid standing open behind, sugared ginger slices, red ribbon
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "candied-ginger"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lid standing open at the back: card frame, inner face toward us
local lid = c:rrect(10, 7, 54, 34, 2)
c:part(lid, "#c9a96e", { gloss = false })
c:part(c:rect(13, 10, 51, 32), "#e8d8b0", { gloss = false, contact = false })
c:fill(c:rect(11, 34, 53, 34), "#7a4a1f")
-- ginger root on the inner lid
c:paint({
  "......uuu.......",
  ".uuu.uGGgu..uu..",
  "uGggugggggu.ugu.",
  "ugggggggggguuggu",
  ".uggggggggggggu.",
  "..ugggggggggsu..",
  "...uusssssuu....",
}, 24, 16, { u = "#7a4a1f", g = "#c9a96e", G = "#ecc58a", s = "#9a6b3f" })
-- box interior and ginger slices
c:part(c:rect(10, 33, 54, 43), "#9a6b3f", { gloss = false })
local function slice(x, y)
  c:part(c:rrect(x - 4, y - 3, x + 4, y + 2, 2), "#e8c070", { gloss = false, cres = 2, deep = 0, contour = "#c89040" })
  c:px(x - 2, y - 2, "#fbf6e8"); c:px(x + 1, y - 1, "#fbf6e8"); c:px(x - 1, y + 1, "#f5e6b8"); c:px(x + 3, y, "#fbf6e8")
  c:px(x - 3, y - 1, "#f5e6b8")
end
for _, p in ipairs({ {17, 37}, {27, 35}, {37, 35}, {47, 37}, {22, 41}, {32, 40}, {42, 41} }) do slice(p[1], p[2]) end
-- crinkled paper liner and the front wall
local front = c:rrect(8, 43, 56, 55, 2)
c:part(front, "#d8b97e", { gloss = { 11, 46 } })
for x = 9, 55 do c:px(x, 43 + (x % 2), "#f4f0e0") end
c:fill(c:rect(10, 45, 54, 45), "#9a6b3f")
for x = 11, 53, 3 do c:px(x, 53, "#e8a317") end
-- ribbon band with a bow
c:part(c:rect(9, 47, 55, 50), "#d6322b", { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:poly({ {25, 44}, {32, 48}, {25, 53} }):add(c:poly({ {40, 44}, {33, 48}, {40, 53} })), "#d6322b", { gloss = false, cres = 2, deep = 0 })
c:part(c:rect(30, 46, 34, 51), "#ae2a2a", { flat = true, contact = false })
c:px(26, 46, "#ff9158"); c:px(27, 47, "#ff9158")
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
