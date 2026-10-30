-- ph/quinoa-soup (Gourmand P2 dish): dark saucepan with ear handles, gold quinoa soup with carrot coins, a wooden ladle standing up on the left
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "quinoa-soup"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pot = GV.ramp("#3f4650", { rim = "#6a7480", gloss = "#9aa6b2", dot = "#c4ccd4" })
-- ear handles behind the body
c:part(c:rrect(6, 28, 14, 33, 2):cut(c:rrect(8, 30, 12, 31, 0)), pot, { cres = 2, gloss = false })
c:part(c:rrect(50, 28, 56, 33, 2):cut(c:rrect(52, 30, 54, 31, 0)), pot, { cres = 2, gloss = false })
-- straight-sided pot, rounded bottom
local body = c:rrect(12, 26, 51, 51, 8):add(c:rect(12, 26, 51, 34))
c:part(body, pot, { cres = 4, gloss = { 16, 34 } })
c:fill(c:rect(13, 44, 50, 44), "#2f343c")                                    -- base band
local rim = c:ellipse(31.5, 26, 20, 5.5)
c:part(rim, "stone", { flat = true, contact = false })
c:fill(rim:edge():clip(c:rect(0, 26, 63, 40)), "#5b6470")
-- soup
local soup = c:ellipse(31.5, 26, 17, 3.5)
c:part(soup, "#e0b94a", { cres = 2, gloss = false, contact = false, contour = "#5b6470" })
for _, p in ipairs({ {20, 25}, {26, 27}, {36, 24}, {41, 27}, {30, 24}, {45, 25} }) do c:px(p[1], p[2], "#f8ecc0") end
-- carrot coins
for _, p in ipairs({ {28, 25}, {39, 26}, {34, 28}, {44, 24} }) do
  c:paint({ ".oo.", "oOoo", ".oc." }, p[1] - 1, p[2] - 1, { o = "#e8742a", O = "#f5a85a", c = "#b84a1a" })
end
-- ladle: handle up and out to the upper-left, bowl sunk in the soup
c:part(c:line({ {22, 26}, {16, 8} }, 3), "wood", { flat = true, contact = false })
c:part(c:rrect(14, 6, 18, 9, 1), "wood", { flat = true, contact = false })
c:fill(c:ellipse(22, 27, 3, 1), "#b88a2a")                                   -- ripple round the ladle
c:ground(31.5, 55, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
