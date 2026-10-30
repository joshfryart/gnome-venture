-- ph/rice-and-peas (Gourmand P2 dish): shallow wooden bowl heaped with white rice, red-brown pigeon peas, a coconut chunk on the rim
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "rice-and-peas"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- shallow wooden bowl: low belly plus the rim ellipse
local bowl = c:ellipse(31.5, 38, 24, 13):clip(c:rect(0, 38, 63, 63)):add(c:ellipse(31.5, 38, 24, 7))
bowl:cut(c:rect(0, 50, 63, 63)):add(c:rrect(21, 47, 42, 52, 2))
c:part(bowl, "#8a5a2f", { cres = 3, gloss = false })
c:fill(c:ellipse(31.5, 38, 24, 7):edge():clip(c:rect(0, 31, 63, 38)), "#c08a58")    -- lit rim lip
c:fill(c:ellipse(31.5, 38, 21, 5), "#5e3a1e")                                     -- bowl inside
-- wood grain on the belly
c:seam({ {12, 46}, {51, 46} }, { gap = "#6b4220" })
c:fill(c:line({ {16, 49}, {24, 50} }, 1), "#6b4220"); c:fill(c:line({ {38, 50}, {46, 49} }, 1), "#6b4220")
-- rice heap
local rice = c:ellipse(31.5, 37, 19, 5):add(c:ellipse(30.5, 31, 15, 8):clip(c:rect(0, 0, 63, 37)))
c:part(rice, "cream", { contour = "#4a2c1a", gloss = { 21, 28 }, cres = 3, contact = false })
local seed = 11
local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
for _ = 1, 26 do                                                             -- rice grain ticks
  local x, y = 15 + rnd(32), 25 + rnd(15)
  if rice:has(x, y) and rice:has(x + 1, y) and c:get(x, y) == "#f1ece0" then c:px(x, y, "#d8cfba") end
end
-- pigeon peas 2x2 with a dark lower pixel
for _, p in ipairs({ {20, 31}, {26, 27}, {33, 25}, {38, 30}, {24, 35}, {31, 32}, {41, 35}, {17, 37}, {35, 37}, {28, 38} }) do
  c:px(p[1], p[2], "#c4664a"); c:px(p[1] + 1, p[2], "#a8503a")
  c:px(p[1], p[2] + 1, "#a8503a"); c:px(p[1] + 1, p[2] + 1, "#6a2a22")
end
-- coconut chunk resting on the right rim: brown shell arc, white flesh
local shell = c:ellipse(49, 31, 7, 7):clip(c:rect(0, 0, 63, 31))
c:part(shell, "#6b4a2a", { cres = 2, gloss = false, contact = false })
local flesh = c:ellipse(49, 32, 5, 5):clip(c:rect(0, 0, 63, 31))
c:part(flesh, GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { cres = 2, contour = false, gloss = false, contact = false })
c:fill(c:rect(43, 31, 55, 32), "#d8c49a")                                    -- cut face edge
c:ground(31.5, 55, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
