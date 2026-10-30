-- ph/natto (Pantry ferment): wara-zuto, a rice-straw bundle tied at both ends.
-- Redraw B: no more candy-wrapper flares or label tag. The bundle is a sheaf of lengthwise straw (texture runs the whole
-- length, through the ties into ragged stalk ends); the top is split open in the middle in a lens and glossy beans fill
-- it. The sticky threads run across the beans and onto the straw (inside the silhouette), so they never get a black border.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "natto"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local straw = GV.ramp("#e8d890", { shade = "#c9b878", deep = "#9a8a50", bounce = "#d8c080", rim = "#f6eab0", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
local bean = GV.ramp("#a8702a", { shade = "#7a4a1f", deep = "#5e2f1e", bounce = "#8a5a24", gloss = "#e0b070", dot = "#f5d8a0", rim = "#c08a40" })
-- sheaf: full body between the ties, bunched narrower ends past them, ragged stalk tips
local CY = 41
local wrap = c:mask()
local tipL = { 9, 10, 8, 9, 10, 9, 8, 10, 9, 8, 10, 9, 9 }      -- left end x per row (ragged)
local tipR = { 55, 54, 56, 55, 54, 56, 55, 54, 56, 55, 54, 55, 55 }
for x = 8, 56 do
  local h
  if x >= 18 and x <= 46 then h = 8 elseif x >= 15 and x <= 49 then h = 7 else h = 6 end
  for y = CY - h, CY + h do
    local i = y - (CY - 6) + 1
    local inL = (x >= 15) or (i >= 1 and i <= #tipL and x >= tipL[i])
    local inR = (x <= 49) or (i >= 1 and i <= #tipR and x <= tipR[i])
    if inL and inR then wrap:set(x, y) end
  end
end
c:part(wrap, straw, { gloss = { 21, 36 }, cres = 4, deep = 2 })
-- lengthwise straw lines, every other row, broken into stalks
wrap:each(function(x, y)
  if (y - CY) % 2 == 0 and (x * 7 + y * 3) % 11 ~= 0 then
    local g = c:get(x, y)
    if g == straw.base or g == straw.rim then c:px(x, y, "#d4be70")
    elseif g == straw.shade then c:px(x, y, "#a8955a") end
  end
end)
-- ties: dark cord bands at the necks
c:part(c:rect(15, 33, 17, 49), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:rect(47, 33, 49, 49), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
-- split opening on top: a lens where the straw parts
local lens = c:ellipse(32, 36, 11, 4)
c:part(lens, "#5e2f1e", { flat = true, rim = false, contact = false, contour = "#2a1a10" })
-- beans filling the lens and bulging just above the top line
local beans = { {24, 36}, {28, 37}, {32, 37}, {36, 37}, {40, 36}, {26, 34}, {30, 34}, {34, 34}, {38, 34}, {28, 31}, {32, 31}, {36, 31} }
for _, p in ipairs(beans) do
  c:part(c:ellipse(p[1], p[2], 2, 1.5), bean, { flat = true, contact = false, contour = "#2a1a10" })
  c:px(p[1] - 1, p[2] - 1, "#f5d8a0")
end
-- sticky threads stretched across the beans and onto the straw (1 px, inside the art)
c:fill(c:line({ {25, 34}, {29, 32}, {34, 31}, {39, 34} }, 1), "#f4f0e0")
c:fill(c:line({ {30, 36}, {34, 39}, {39, 41}, {43, 41} }, 1), "#f4f0e0")
c:fill(c:line({ {27, 37}, {24, 40}, {21, 41} }, 1), "#f4f0e0")
c:ground(32, 54, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
