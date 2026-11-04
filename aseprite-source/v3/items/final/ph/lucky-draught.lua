-- lucky-draught (aC21_3, Opus single pass). A slim pear-drop glass flask: long neck, rolled lip, cork with pores and
-- a pale end grain, gold twine twisted under the lip. Glass: bright lit rim, darker far wall, pale core, one specular
-- and a sparkle. Inside, a rosy potion (6-tone per-pixel light, bright meniscus line, rising bubbles) with a four-leaf
-- clover suspended mid-draught. Stands on a 2-tone ground shadow.
-- quirk: the twine's loose end carries a tiny gold horseshoe charm, dangling beside the neck.
local NAME = "lucky-draught"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local GL = { "#34607e", "#5a94b4", "#94cade", "#c8ecf0", "#e8fbf6" }
local PINK = { "#5a1846", "#86245e", "#b43874", "#dc5890", "#f68ab2", "#ffc6dc" }
local CLOV = { "#1d4a38", "#2f7446", "#4f9e52", "#86c868" }
local CORK = { "#4a2a22", "#6e4430", "#9a6640", "#c48e58", "#e2b47c", "#f2d4a0" }
local TW = { "#8a4a1e", "#d08a2a", "#f5c04a" }
local GOLD = { "#7a3e1a", "#c87a22", "#f2b632", "#ffe38a" }
local gtok, ltok, ktok, ttok, ctok = { r = { name = "glass" } }, { r = { name = "potion" } }, { r = { name = "cork" } }, { r = { name = "twine" } }, { r = { name = "clover" } }
local CX, BY = 31.5, 44

c:groundShadow(32, 56, 9, 1)

-- glass silhouette by half-width profile
local function W(y)
  local neck = (y >= 15 and y <= 33) and 2.6 or 0
  local fl = (y >= 28 and y <= 36) and (2.6 + ((y - 28) / 6) ^ 2 * 3) or 0
  local bw = 0
  if y >= 33 and y <= 54 then local q = 1 - ((y - BY) / 11.6) ^ 2 if q > 0 then bw = 10.8 * sqrt(q) end end
  if y >= 52 then bw = min(bw, 10.8 * sqrt(max(0, 1 - ((52 - BY) / 11.6) ^ 2))) end   -- flat foot
  return max(neck, fl, bw)
end
local glass, nrm = HP.mask(), {}
for y = 15, 54 do
  local w = W(y)
  for x = 18, 46 do
    if abs(x - CX) <= w then
      glass:set(x, y)
      local nx = max(-0.97, min(0.97, (x - CX) / (w + 0.5)))
      local ny = y >= 34 and max(-0.9, min(0.9, (y - BY) / 12.5)) or 0
      nrm[K(x, y)] = { A.norm(nx, ny * 0.7, sqrt(max(0.05, 1 - nx * nx))) }
    end
  end
end
local LVL = 37
local liquid = glass:shrink(1)
liquid:each(function(x, y) if y < LVL then liquid.s[K(x, y)] = nil end end)
local v = X.light(nrm, { amb = 0.12, wrap = 0.3 })
-- empty glass: fresnel rim + pale core, lit rim on the upper-left
local edge = glass:edge()
glass:each(function(x, y) local k = K(x, y)
  if liquid:has(x, y) then return end
  local nn = nrm[k]
  local col
  if edge:has(x, y) then
    col = (nn[1] < -0.2 and y < 50) and GL[5] or ((nn[1] > 0.3 or y >= 50) and GL[1] or GL[2])
  else
    local a = abs(nn[1])
    col = a > 0.65 and GL[3] or (a > 0.35 and GL[4] or GL[5])
    if nn[1] > 0.55 then col = GL[2] end
  end
  c:put(x, y, col, gtok)
end)
-- potion
local pidx = X.tone(c, liquid, v, PINK, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = ltok })
liquid:edge():each(function(x, y) local k = K(x, y)
  if y > LVL then c:put(x, y, PINK[max(1, (pidx[k] or 3) - 1)], ltok) end end)
for x = 18, 46 do if liquid:has(x, LVL) then c:put(x, LVL, x < CX + 5 and PINK[6] or PINK[5], ltok) end end
for x = 18, 46 do if liquid:has(x, LVL + 1) and x > CX - 7 then c:put(x, LVL + 1, PINK[3], ltok) end end   -- under-surface shade
-- glass highlight streak over the potion (curved, left wall) and a reflection window on the right shoulder
liquid:each(function(x, y) local nn = nrm[K(x, y)]
  if nn[1] < -0.55 and nn[1] > -0.8 and y >= 40 and y <= 50 then c:put(x, y, PINK[6], ltok) end end)
for _, q in ipairs{ { 37, 41 }, { 38, 42 } } do c:put(q[1], q[2], PINK[6], ltok) end
-- bubbles
for _, q in ipairs{ { 27, 50 }, { 36, 46 }, { 35, 40 } } do c:put(q[1], q[2], PINK[6], ltok) c:put(q[1] + 1, q[2] + 1, PINK[3], ltok) end
c:put(33, 36, GL[3], gtok)       -- one escaping above the surface

-- four-leaf clover suspended in the potion
local OX, OY = 31, 45
local hearts = { { -3, -3 }, { 1, -3 }, { -3, 1 }, { 1, 1 } }
for hi, h in ipairs(hearts) do
  for dy = 0, 2 do for dx = 0, 2 do
    local corner = (h[1] < 0 and dx == 2 or h[1] > 0 and dx == 0) and (h[2] < 0 and dy == 2 or h[2] > 0 and dy == 0)
    local notch = (h[1] < 0 and dx == 0 or h[1] > 0 and dx == 2) and (h[2] < 0 and dy == 0 or h[2] > 0 and dy == 2)
    if not notch then
      local lit = (dx + dy <= 1) and 4 or ((dx + dy >= 3) and 2 or 3)
      if hi == 4 then lit = max(1, lit - 1) end
      c:put(OX + h[1] + dx, OY + h[2] + dy, CLOV[corner and 1 or lit], ctok)
    end
  end end
end
c:put(OX, OY, CLOV[1], ctok)
for _, q in ipairs{ { 1, 1 }, { 2, 2 }, { 2, 3 }, { 3, 4 } } do c:put(OX + q[1] + 1, OY + q[2] + 2, CLOV[2], ctok) end

-- specular + sparkle on the glass
c:put(27, 35, A.CREAM, gtok) c:put(28, 35, A.CREAM, gtok) c:put(27, 36, GL[5], gtok)
c:put(30, 19, GL[5], gtok) c:put(30, 20, GL[5], gtok)

-- rolled lip
local lip = c:rect(28, 15, 35, 16)
lip:each(function(x, y) c:put(x, y, (y == 15 and x < 33) and GL[5] or (x >= 34 and GL[1] or GL[3]), gtok) end)
-- cork: slight taper, pores, pale end grain
local cork = HP.mask()
for y = 8, 14 do for x = 28, 35 do
  local inset = y >= 13 and 1 or 0
  if x >= 29 + inset and x <= 34 - inset + (y <= 9 and 0 or 0) then cork:set(x, y) end
end end
cork:set(28, 9) cork:set(35, 9) cork:set(28, 10) cork:set(35, 10)
cork:each(function(x, y)
  local t = (x - 28) / 7
  local i = t < 0.2 and 5 or (t < 0.45 and 4 or (t < 0.75 and 3 or 2))
  if y == 8 then i = 6 elseif y == 14 or y == 13 then i = max(1, i - 1) end
  if y > 8 and X.hash(x, y, 31) > 0.8 then i = max(1, i - 2) end
  c:put(x, y, CORK[i], ktok)
end)
for x = 29, 34 do c:put(x, 16, CORK[1], ktok) end   -- ambient row where cork meets the glass mouth
lip:each(function(x, y) if y == 16 and (x == 28 or x == 35) then c:put(x, y, GL[2], gtok) end end)

-- twine under the lip: twisted strands
for x = 29, 34 do
  c:put(x, 18, ((x % 2) == 0) and TW[3] or TW[2], ttok)
  c:put(x, 19, ((x % 2) == 1) and TW[2] or TW[1], ttok)
end
-- loose end and the horseshoe charm (quirk)
for _, q in ipairs{ { 35, 19, 2 }, { 36, 20, 3 }, { 36, 21, 2 }, { 37, 22, 3 }, { 38, 23, 2 } } do c:put(q[1], q[2], TW[q[3]], ttok) end
local shoe = { "XX.XX", "XX.XX", "XXXXX", ".XXX." }
local htok = { r = { name = "charm" } }
for r, row in ipairs(shoe) do for i = 1, 5 do if row:sub(i, i) == "X" then
  local x, y = 35 + i, 23 + r
  local g = (i <= 2 and r <= 2) and 4 or ((i >= 4 or r >= 4) and 2 or 3)
  c:put(x, y, GOLD[g], htok)
end end end
c:put(37, 26, GOLD[1], htok) c:put(39, 26, GOLD[1], htok)   -- nail holes

A.save2(c, NAME)
