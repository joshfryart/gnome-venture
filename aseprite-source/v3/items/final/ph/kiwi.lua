-- kiwi (final, Opus single pass). A whole kiwi fruit lying on the diagonal behind, and a halved one in front facing
-- the viewer. Whole: egg-shaped, matte fuzzy brown skin (per-pixel ellipsoid light, hash fuzz grain, a few hairs
-- breaking the silhouette), a woody stem nub in a sunken socket at the top tip and a dried blossom star at the other.
-- Half: brown skin crescent seen behind the cut face; the face is wet green flesh with a pale rind ring, lighter
-- radiating fibres, a ring of dark radial seeds round a cream core with striations, one wet glint.
-- AO where the half sits against the whole. quirk: a teaspoon is stuck in the half, ready to scoop.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan, math.pi
local c = A.new("kiwi")

local BRN   = { "#3a2416", "#56381e", "#765226", "#946c34", "#b28a4a", "#cfaa6a" }
local FLESH = { "#2a5a2a", "#3c7e2e", "#56a032", "#78c03a", "#a0d84e", "#cfee86" }
local CORE  = { "#b0bc66", "#d4dc94", "#eef0bc", "#fbfae2" }
local SEED  = { "#2b1c26", "#4a2c34" }
local TIN   = { "#2e2c40", "#4a4a60", "#6a6c82", "#9092a6", "#b8bacb", "#e8eaf0" }

---------------------------------------------------------------- half (masks first for AO on the whole)
local fcx, fcy, frx, fry = 39, 42, 9.5, 9
local face = c:ellipse(fcx, fcy, frx, fry)
local skinH, skinN = A.oval(41.2, 44.2, 10.2, 9.6, 0, 1)
local halfAll = face:copy():add(skinH)

---------------------------------------------------------------- whole fruit
do
  local m, n = A.oval(26, 28, 15, 10.5, -0.45, 0.9)
  m:cut(halfAll)
  local bias = {}
  X.ao(bias, m, halfAll, 2, -1)
  -- stem socket and blossom end AO
  local ux, uy = math.cos(-0.45), math.sin(-0.45)
  local tx, ty = 26 + ux * 15, 28 + uy * 15
  local bx, by = 26 - ux * 15, 28 - uy * 15
  m:each(function(x, y) local k = K(x, y)
    local d1 = sqrt((x - tx) ^ 2 + (y - ty) ^ 2)
    local d2 = sqrt((x - bx) ^ 2 + (y - by) ^ 2)
    if d1 < 3.2 then bias[k] = (bias[k] or 0) - 1 end
    if d2 < 2.6 then bias[k] = (bias[k] or 0) - 1 end
    -- fuzz grain
    local h = X.hash(x, y, 31)
    if h > 0.82 then bias[k] = (bias[k] or 0) + 1 elseif h < 0.16 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local tok = { r = { name = "whole" } }
  local idx = A.toneN(c, m, n, BRN, { bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- hairs breaking the silhouette (upper-left lit side) and on the shade side
  for _, p in ipairs{ { 14, 31 }, { 17, 24 }, { 22, 20 }, { 31, 16 }, { 20, 37 } } do
    if not m:has(p[1], p[2]) then c:put(p[1], p[2], (p[2] < 30) and BRN[5] or BRN[3], tok) end
  end
  -- stem nub
  local sx, sy = floor(tx - ux * 1 + .5), floor(ty - uy * 1 + .5)
  c:put(sx, sy, BRN[1], tok) c:put(sx + 1, sy, BRN[2], tok) c:put(sx + 1, sy - 1, BRN[4], tok) c:put(sx + 2, sy - 1, BRN[3], tok)
  c:put(sx + 2, sy - 2, BRN[5], tok)
  -- dried blossom star
  local qx, qy = floor(bx + ux * 1.5 + .5), floor(by + uy * 1.5 + .5)
  c:put(qx, qy, BRN[1], tok) c:put(qx - 1, qy, BRN[2], tok) c:put(qx, qy - 1, BRN[2], tok) c:put(qx + 1, qy + 1, BRN[2], tok)
  c:put(qx, qy + 1, BRN[1], tok)
  -- soft sheen pop
  c:put(19, 23, BRN[6], tok) c:put(20, 23, BRN[6], tok) c:put(21, 22, BRN[5], tok)
end

---------------------------------------------------------------- half: skin crescent
do
  local m = skinH:copy():cut(face)
  local bias = {}
  m:each(function(x, y) local h = X.hash(x, y, 41) local k = K(x, y)
    if h > 0.84 then bias[k] = 1 elseif h < 0.14 then bias[k] = -1 end end)
  local tok = { r = { name = "skin" } }
  A.toneN(c, m, skinN, BRN, { bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- hairs
  for _, p in ipairs{ { 52, 43 }, { 47, 54 } } do if not halfAll:has(p[1], p[2]) then c:put(p[1], p[2], BRN[2], tok) end end
end

---------------------------------------------------------------- half: cut face
do
  local tok = { r = { name = "flesh" } }
  face:each(function(x, y)
    local dx, dy = (x + .5 - fcx - .5) / (frx + .5), (y + .5 - fcy - .5) / (fry + .5)
    local r = sqrt(dx * dx + dy * dy)
    local a = atan(dy, dx)
    local lit = -(dx + dy) * 0.5                  -- upper-left brighter
    local col
    if r > 0.93 then
      col = BRN[(dx + dy > 0.3) and 2 or 3]       -- thin skin edge on the cut
    elseif r > 0.84 then
      col = FLESH[(lit > 0.05) and 6 or 5]        -- pale rind ring
    elseif r > 0.3 then
      local i = (r > 0.58) and 3 or 4
      if lit > 0.18 then i = i + 1 elseif lit < -0.22 then i = i - 1 end
      -- radiating fibres (lighter), between them darker juice cells
      local fa = (a / (2 * pi) * 22) % 1
      if r > 0.48 then
        if fa < 0.18 then i = i + 1 elseif fa > 0.55 and fa < 0.7 and X.hash(x, y, 5) > 0.4 then i = i - 1 end
      end
      col = FLESH[max(1, min(6, i))]
    else
      local i = 3
      if lit > 0.12 then i = 4 elseif lit < -0.12 then i = 2 end
      local fa = (a / (2 * pi) * 10) % 1
      if r > 0.12 and fa < 0.2 then i = max(1, i - 1) end
      col = CORE[i]
    end
    c:put(x, y, col, tok)
  end)
  -- ring of radial seeds
  for j = 0, 15 do
    local a = j / 16 * 2 * pi + 0.1
    local rr = (j % 2 == 0) and 0.4 or 0.47
    local x = floor(fcx + .5 + math.cos(a) * rr * (frx + .5))
    local y = floor(fcy + .5 + math.sin(a) * rr * (fry + .5))
    local x2 = floor(fcx + .5 + math.cos(a) * (rr + 0.12) * (frx + .5))
    local y2 = floor(fcy + .5 + math.sin(a) * (rr + 0.12) * (fry + .5))
    c:put(x, y, SEED[1], tok)
    if x2 ~= x or y2 ~= y then c:put(x2, y2, SEED[2], tok) end
  end
  -- wet glint on the flesh
  c:put(34, 37, "#f4ffd6", tok) c:put(35, 37, FLESH[6], tok) c:put(34, 38, FLESH[6], tok)
end

---------------------------------------------------------------- quirk: teaspoon stuck in the flesh
do
  local tok = { r = { name = "spoon" } }
  -- scooped hollow where the spoon goes in
  for _, p in ipairs{ { 42, 45 }, { 43, 45 }, { 43, 46 }, { 42, 46 }, { 41, 46 } } do c:put(p[1], p[2], FLESH[2], tok) end
  c:put(41, 45, FLESH[1], tok) c:put(44, 47, FLESH[5], tok)
  -- handle (2 px, polished): lit upper edge, dark lower edge, rising out of the fruit to the lower right
  local pts = {}
  for i = 0, 11 do
    local x = 44 + i
    local y = floor(46 + i * 0.62 + .5)
    c:put(x, y, (i < 2) and TIN[4] or TIN[5], tok)
    c:put(x, y + 1, (i < 2) and TIN[2] or TIN[3], tok)
  end
  -- end paddle
  for _, p in ipairs{ { 55, 52, 5 }, { 56, 52, 4 }, { 56, 53, 3 }, { 55, 54, 2 }, { 56, 54, 2 }, { 57, 53, 2 } } do
    c:put(p[1], p[2], TIN[p[3]], tok) end
  c:put(49, 49, TIN[6], tok)
  -- contact shadow of the handle on the skin
  for i = 0, 4 do local x = 45 + i local y = floor(46 + (i + 1) * 0.62 + .5) + 2
    if skinH:has(x, y) and not face:has(x, y) then c:put(x, y, BRN[1], tok) end end
end

A.save(c, "kiwi")
