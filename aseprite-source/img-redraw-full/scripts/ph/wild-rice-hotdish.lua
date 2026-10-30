-- ph/wild-rice-hotdish (Gourmand P2 dish): square clay casserole from above, dark wild rice, mushroom slices, golden crumb crust on the right
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "wild-rice-hotdish"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- dish with two handle tabs
local dish = c:rrect(11, 14, 52, 52, 6):add(c:rrect(6, 27, 12, 34, 2)):add(c:rrect(51, 27, 56, 34, 2))
c:part(dish, "#a5663a", { cres = 3, gloss = false })
c:fill(c:rrect(13, 16, 50, 46, 5), "#c98a55")                       -- top of the rim
c:fill(c:rrect(13, 16, 50, 46, 5):edge():clip(c:rect(0, 16, 63, 17)), "#e0a870")
-- filling
local fil = c:rrect(16, 19, 47, 43, 3)
c:part(fil, "#3b2f2a", { contour = "#6e3e22", cres = 3, gloss = false, contact = false, rim = false })
-- wild rice grains: long dark and pale-brown flecks
local seed = 7
local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
for _ = 1, 70 do
  local x, y = 17 + rnd(22), 20 + rnd(23)
  local col = (rnd(3) == 0) and "#7a5a44" or "#1d1512"
  if rnd(2) == 0 then c:px(x, y, col); c:px(x + 1, y, col) else c:px(x, y, col); c:px(x, y + 1, col) end
end
-- crumb crust on the right
local crust = c:poly({ {38, 19}, {48, 19}, {48, 44}, {37, 44}, {39, 38}, {37, 32}, {39, 26} }):clip(fil)
c:part(crust, "#dcb06a", { contour = "#8a5a2f", cres = 3, gloss = false, contact = false })
for _, p in ipairs({ {41, 22}, {44, 25}, {40, 29}, {45, 31}, {42, 35}, {44, 40}, {40, 41}, {46, 21} }) do
  c:px(p[1], p[2], "#a8742f")
end
for _, p in ipairs({ {42, 23}, {45, 28}, {41, 37} }) do c:px(p[1], p[2], "#f5d898") end
-- mushroom slices
local function mush(x, y)
  c:paint({ ".mmm.", "mmmmm", ".sss." }, x, y, { m = "#c9a96e", s = "#8a6a3a" })
  c:px(x + 1, y, "#e6d2a0")
end
mush(19, 22); mush(28, 26); mush(20, 33); mush(29, 37); mush(31, 20)
-- thread-gold seam on the rim
c:seam({ {18, 17}, {45, 17} }, { gap = "#a5663a" })
c:seam({ {18, 45}, {45, 45} }, { gap = "#a5663a" })
c:ground(31.5, 55, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
