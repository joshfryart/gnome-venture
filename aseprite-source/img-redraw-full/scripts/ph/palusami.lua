-- ph/palusami (Gourmand P2 dish): a round taro-leaf bundle on a banana leaf; leaf flaps folded up over the top
-- and parted at the crown, where coconut cream wells out and runs glossy down the leaves into a pool
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "palusami"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local CREAM, CREAM_S, CREAM_D = "#f6f0dc", "#e6dcc0", "#c9b48a"
-- banana leaf: long lens with pointed tips
local leaf = c:ellipse(31.5, 47, 22, 7):add(c:poly({ {6, 48}, {13, 43}, {13, 52} })):add(c:poly({ {57, 45}, {50, 42}, {50, 52} }))
c:part(leaf, "#7ab648", { cres = 3, gloss = false })
c:fill(c:line({ {8, 48}, {31, 47}, {55, 45} }, 1), "#5a9a3a")
for _, x in ipairs({ 13, 19, 44, 50 }) do
  c:fill(c:line({ {x, 47}, {x - 3, 42} }, 1), "#9ad06a"); c:fill(c:line({ {x, 48}, {x - 3, 52} }, 1), "#5a9a3a")
end
-- coconut cream pooled on the leaf round the base
local pool = c:ellipse(31.5, 47, 17, 4)
c:part(pool, GV.ramp(CREAM, { shade = CREAM_S, bounce = CREAM_S, deep = CREAM_D, dot = "#fbf6e8" }), { cres = 1, deep = 0, gloss = false, contact = false, contour = "#5a9a3a" })
-- the bundle: a round taro-leaf parcel; the last heart-shaped leaf is folded from the back over the top and
-- down the front, its pointed tip at the front. Coconut cream seeps out along the fold and down the tip.
local bun = c:ellipse(31.5, 35, 17, 13):clip(c:rect(0, 0, 63, 46)):add(c:ellipse(31.5, 44, 15, 3))
c:part(bun, "#2f6a2a", { cres = 4, gloss = false })
for _, l in ipairs({ { {17, 42}, {16, 35} }, { {46, 42}, {47, 35} }, { {22, 44}, {21, 39} }, { {41, 44}, {42, 39} } }) do
  c:fill(c:line(l, 1), "#4f8a3a")                                            -- veins of the under leaves
end
-- cream seeping from under the folded leaf (drawn first, the flap covers most of it)
local flap = c:poly({ {15, 29}, {20, 23}, {31.5, 21}, {43, 23}, {48, 29}, {31.5, 42} }):clip(bun:grow(1))
local seep = flap:grow(2):clip(bun):cut(flap):clip(c:rect(0, 28, 63, 63))
c:fill(seep, CREAM)
c:fill(seep:copy():cut(flap:grow(1)), CREAM_S)
c:part(flap, "#4a9a3a", { cres = 3, gloss = { 22, 26 }, contour = "#1f4a2a" })
c:fill(c:line({ {31, 23}, {31, 40} }, 1), "#2f6a2a")                        -- midrib
for _, v in ipairs({ { {31, 27}, {24, 25} }, { {31, 27}, {38, 25} }, { {31, 32}, {22, 29} }, { {31, 32}, {40, 29} }, { {31, 37}, {27, 34} }, { {31, 37}, {35, 34} } }) do
  c:fill(c:line(v, 1), "#3a7a30")                                            -- side veins
end
c:fill(c:line({ {31, 43}, {31, 45} }, 2), CREAM)                              -- drip off the tip
-- creamy sheen: a pale glossy streak across the top of the folded leaf
c:fill(c:line({ {21, 25}, {27, 22} }, 2), "#d8ecb0")
c:fill(c:line({ {22, 25}, {27, 23} }, 1), "#f0f4d8")
c:px(23, 24, "#ffffff")                                                     -- the one white glint
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
