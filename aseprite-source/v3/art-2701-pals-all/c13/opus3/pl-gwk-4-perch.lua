-- Crown Points (pl-gwk-4), perch sprite 36x36. Opus richness pass (c13/opus3), hand-built at this size.
-- opus3: opus2's perch eyes were small against the busy gold. The face now sits on a polished oval plate (one
-- smooth pale-gold tone framed by an engraved dark line), the band is taller, the pill eyes and mouth have clear
-- ground; gems got a bezel and a glint; hue-shifted gold; crimson velvet showing at the snapped ends.
-- A snapped-off segment of the king's crown: curved worn-gold band with jagged ends, four ball-tipped points,
-- a ruby and a sapphire, 2x3 pill eyes on the band.
-- quirk: it is old: the fourth point is bent over to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-4-perch", 36)

local GOLD = { "#4e2420", "#8a4a22", "#c47e2a", "#eab03e", "#fad46a", "#fff0b4" }
local RUBY = { "#4a0e2c", "#9a1e3c", "#de3e54", "#ff9c96" }
local SAPH = { "#141e56", "#2846a4", "#4a86e2", "#a6d4fa" }

c:groundShadow(17, 32, 14, 1)
local function ybot(x) local u = (x - 17) / 15 return 27 + math.floor(2.5 * math.sqrt(math.max(0, 1 - u * u)) + .5) end
local pts = { 7, 13, 20, 26 }
local tips = {}
for k, bx in ipairs(pts) do
  local yb = ybot(bx) - 11
  local m, tx, ty
  if k < 4 then
    tx, ty = bx, yb - 9
    m = c:poly{ { bx - 2.5, yb + 1 }, { bx + 2.5, yb + 1 }, { tx + .5, ty } }
  else
    tx, ty = bx + 6, yb - 5
    m = c:poly{ { bx - 2.5, yb + 1 }, { bx + 2.5, yb + 1 }, { bx + 2, yb - 2 }, { tx + 1, ty + 1 }, { tx, ty - 1 }, { bx - 1.5, yb - 4 } }
  end
  local I, T = O.shade(c, m, GOLD, { R = 1, amb = .3, wrap = .45, rim = true, sep = GOLD[1] })
  O.tex(c, I, T, GOLD, function(x, y, i) if k < 4 and x > bx then return -1 end end)
  tips[k] = { tx, ty }
end
local band = HP.mask()
for x = 3, 31 do local yb = ybot(x) for y = yb - 11, yb do band:set(x, y) end end
band:cut(c:poly{ { 2, 17 }, { 4, 17 }, { 3, 21 }, { 5, 24 }, { 3, 28 }, { 2, 30 } })
band:cut(c:poly{ { 33, 17 }, { 31, 17 }, { 32, 21 }, { 30, 24 }, { 32, 28 }, { 33, 30 } })
local bn = {}
band:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 17) / 16))
  local yy = (y - (ybot(x) - 4.5)) / 7
  local l = math.sqrt(sx * sx + yy * yy + .6)
  bn[K(x, y)] = { sx / l, yy / l, math.sqrt(.6) / l }
end)
local bI, bT = O.shadeN(c, band, bn, GOLD, { amb = .28, wrap = .45, rim = true, bounce = "#8a6ab0", bmax = 3, sep = GOLD[1] })
O.tex(c, bI, bT, GOLD, function(x, y, i) local yb = ybot(x) if y == yb - 1 and x % 3 == 0 then return -2 end end)
for _, t in ipairs(tips) do
  O.shade(c, c:ellipse(t[1], t[2] - 1, 1.2, 1.2), GOLD, { sphere = { t[1] - 1, t[2] - 2, 2 }, amb = .4, wrap = .5, sep = GOLD[2] })
end
-- velvet at the snapped ends
for y = 18, 28 do
  if y % 3 ~= 0 then
    for _, x in ipairs({ 2, 3, 32, 33 }) do
      if not band:has(x, y) and (band:has(x + 1, y) or band:has(x - 1, y)) then O.dot(c, x, y, (y % 3 == 1) and "#7a2038" or "#a83848") end
    end
  end
end
-- polished oval plate behind the face, framed by an engraved line
local plate = c:ellipse(16.5, 22.5, 8, 4.5)
plate:each(function(x, y) O.dot(c, x, y, (x + y > 42) and GOLD[4] or GOLD[5]) end)
plate:edge():each(function(x, y) O.dot(c, x, y, GOLD[2]) end)
for _, g in ipairs({ { 5, 22, RUBY }, { 28, 22, SAPH } }) do
  local x, y, R = g[1], g[2], g[3]
  O.flat(c, c:rect(x - 1, y - 1, x + 2, y + 2), GOLD[2], "bezel")
  O.flat(c, c:rect(x, y, x + 1, y + 1), R[2], "gem") O.dot(c, x, y, R[4]) O.dot(c, x + 1, y + 1, R[1])
end

c:eyeSmall(12, 20)
c:eyeSmall(20, 20)
O.dot(c, 11, 24, P.petal.base) O.dot(c, 22, 24, P.petal.base)
O.dots(c, { { 15, 24 }, { 16, 25 }, { 17, 25 }, { 18, 24 } }, P.ink)

O.done(c, "pl-gwk-4-perch", function(c) c:sparkle(3, 6) end)
