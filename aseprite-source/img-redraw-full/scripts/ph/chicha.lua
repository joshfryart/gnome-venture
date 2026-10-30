-- ph/chicha (Gourmand P2 jar): round terracotta jar of cloudy chicha with a foam head, a red-striped cloth tied at the neck, a half-gourd cup on the right
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "chicha"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- jar: round belly, short neck, wide flared mouth
local body = c:ellipse(27, 38, 16, 16):add(c:rrect(19, 18, 35, 26, 2)):add(c:ellipse(27, 18, 10, 3.5))
c:part(body, "#a5663a", { cres = 5, gloss = { 16, 34 } })
c:fill(c:ellipse(27, 18, 10, 3.5):edge():clip(c:rect(0, 14, 63, 18)), "#d8a070")
-- painted zigzag band on the belly
c:fill(c:rect(12, 40, 42, 41):clip(body), "#e6c89a")
for x = 12, 42, 4 do c:px(x, 42, "#e6c89a"); c:px(x + 1, 42, "#e6c89a"); c:px(x + 2, 39, "#e6c89a"); c:px(x + 3, 39, "#e6c89a") end
c:fill(c:rect(13, 45, 41, 45):clip(body), "#7e4428")
-- cloudy chicha and foam head at the lip
c:fill(c:ellipse(27, 18, 8, 2), "#f1e6b4")
for _, p in ipairs({ {20, 16}, {24, 14}, {28, 15}, {32, 14}, {34, 16} }) do
  c:part(c:ellipse(p[1], p[2], 2, 1.5), GV.ramp("#f6f0dc", { dot = "#fffaf0", rim = "#fffaf0" }), { flat = true, contact = false })
end
c:px(25, 13, "#fffaf0")
-- woven cloth tied round the neck, tail hanging on the right
local band = c:rect(18, 22, 36, 25)
local tail = c:poly({ {34, 23}, {41, 25}, {43, 36}, {38, 37}, {35, 27} })
local cloth = band:copy():add(tail)
c:part(cloth, "#f1e6c8", { cres = 2, gloss = false, contact = true })
c:fill(c:rect(18, 23, 36, 23), "#c0392b"); c:fill(c:rect(18, 25, 36, 25):clip(cloth), "#c0392b")
for _, y in ipairs({ 28, 29, 33, 34 }) do c:fill(c:rect(30, y, 50, y):clip(tail), "#c0392b") end
c:paint({ "kk", "kK" }, 34, 22, { k = "#c0392b", K = "#7a1f1a" })
-- half-gourd cup
local cup = c:ellipse(49, 46, 7, 7):clip(c:rect(0, 46, 63, 63)):add(c:ellipse(49, 46, 7, 2))
c:part(cup, "#8a5a2f", { cres = 3, gloss = false })
c:fill(c:ellipse(49, 46, 5, 1), "#f1e6b4")
c:px(46, 46, "#fffaf0")
c:ground(30, 56, 20, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
