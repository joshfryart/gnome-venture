-- date-chutney (final, Opus single pass). A slim glass jar of dark, glossy date chutney (6-tone cylinder light,
-- chunks of date, golden sultana and pale onion, mustard-seed dots, wet meniscus under a band of empty glass),
-- glass cues (pale lit rim, broken vertical specular streak, cool reflected edge, rounded shoulder glint), a
-- kraft-cream label with a little date drawn on it, and a cloth cap (diagonal weave, fluted pinked hem)
-- cinched by twisted twine with a bow and two loose ends. 2-tone ground shadow.
-- quirk: a fat drip of chutney has escaped from under the cloth and is running down the glass.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new("date-chutney")
local CH = { "#2a1112", "#46201a", "#68301f", "#8c4626", "#b2652f", "#d68c44" }
local GLASS = { "#5d7f86", "#8fb9b4", "#c7e6dc", "#eef8f0" }
local CLOTH = { "#5e1a2e", "#8e2934", "#bb3c3a", "#df5a40", "#f4835a", "#ffb08a" }
local TW = { "#4e3c2c", "#8a7454", "#c2ac84", "#ece0bc" }
local LAB = { "#8a6a46", "#bf9d6c", "#e4cd9c", "#f8ebc6" }
local DATE = { "#3a141a", "#6e2a22", "#a84a2c" }
local CX = 32

c:groundShadow(CX, 56, 15, 1.2)

-- jar body (cylinder with rounded shoulders and heel)
local body = c:rrect(20, 27, 44, 55, 5)
local neck = c:rect(23, 23, 41, 27)
local jar = body:copy():add(neck)
local pn = X.pillow(jar, 4)
local n = {}
jar:each(function(x, y) local k = K(x, y)
  local nx = max(-0.97, min(0.97, (x - CX) / 13))
  local a = pn[k]
  n[k] = { G.norm(nx * 0.85 + a[1] * 0.35, a[2] * 0.9, sqrt(1 - nx * nx)) }
end)
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local gtok = { r = { name = "jar" } }
local SURF = 31 -- chutney surface row
local idx = {}
jar:each(function(x, y) local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, t in ipairs{ 0.3, 0.47, 0.63, 0.79, 0.93 } do if val >= t then i = j + 1 end end
  idx[k] = i
  if y < SURF then
    -- empty glass headspace: cool, pale toward the light
    c:put(x, y, i >= 5 and GLASS[3] or (i >= 3 and GLASS[2] or GLASS[1]), gtok)
  else
    c:put(x, y, CH[i], gtok)
  end
end)
-- chunks inside (darker date pieces, golden sultanas, onion slivers, mustard seeds)
jar:each(function(x, y) local k = K(x, y)
  if y <= SURF or y > 53 then return end
  local h = X.hash(x, y, 41)
  local i = idx[k]
  if h > 0.94 then c:put(x, y, CH[max(1, i - 2)], gtok)
  elseif h > 0.91 and i >= 3 then c:put(x, y, i >= 5 and "#f0b848" or "#c48a2c", gtok)
  elseif h > 0.895 and i >= 4 then c:put(x, y, "#e9cf9c", gtok)
  elseif h < 0.015 then c:put(x, y, "#e2b23a", gtok) end
end)
-- meniscus: lit wet line on the surface, dark row under it
for x = 21, 43 do
  if jar:has(x, SURF) then c:put(x, SURF, (x < CX) and CH[6] or CH[4], gtok) end
  if jar:has(x, SURF + 1) then c:put(x, SURF + 1, CH[max(1, idx[K(x, SURF + 1)] - 2)], gtok) end
end
-- glass rim: lit left edge pale, right edge cool reflected light
local e = jar:edge()
e:each(function(x, y)
  if x < CX - 6 then c:put(x, y, y < SURF and GLASS[4] or GLASS[2], gtok)
  elseif x > CX + 6 then c:put(x, y, y < SURF and GLASS[2] or "#6a5a76", gtok) end
end)
-- vertical specular streak (broken), shoulder glint
for y = 33, 52 do if y ~= 41 and y ~= 42 and y ~= 47 then c:put(24, y, y < 38 and GLASS[4] or GLASS[3], gtok) end end
for y = 34, 37 do c:put(25, y, GLASS[3], gtok) end
c:put(22, 29, GLASS[4], gtok) c:put(23, 28, GLASS[4], gtok)
c:put(40, 50, GLASS[2], gtok) c:put(40, 51, GLASS[2], gtok)
-- heel: thick glass base, pale line
for x = 24, 40 do c:put(x, 54, x < 33 and GLASS[2] or GLASS[1], gtok) end

-- label: cream paper band with a drawn date and two handwriting dashes
local lab = c:rrect(26, 38, 39, 47, 1)
local lbias = {}
local ln = {}
lab:each(function(x, y) local k = K(x, y) ln[k] = n[k] end)
local ltok = { r = { name = "label" } }
local li = G.toneN(c, lab, ln, LAB, { tok = ltok, cuts = { 0.2, 0.42, 0.7 }, amb = 0.25, wrap = 0.35 })
-- top edge lit, bottom edge shadow
for x = 26, 39 do if lab:has(x, 38) then c:put(x, 38, LAB[min(4, (li[K(x, 38)] or 3) + 1)], ltok) end end
for x = 27, 38 do c:put(x, 48, CH[1], gtok) end
-- little date glyph
local glyph = { ".aab.", "abbbc", ".bcc." }
local GM = { a = DATE[3], b = DATE[2], c = DATE[1] }
for yy, row in ipairs(glyph) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if GM[ch] then c:put(29 + xx, 39 + yy, GM[ch], ltok) end end end
c:put(35, 40, "#c49a52", ltok)
for x = 29, 36 do if x ~= 33 then c:put(x, 45, LAB[1], ltok) end end

-- quirk drip: down the glass from under the cloth, right of centre
local dm = c:rect(36, 30, 37, 35):add(c:ellipse(36.5, 36.5, 1.5, 1.5))
dm:each(function(x, y)
  local col = (x == 36) and CH[5] or CH[3]
  if y >= 36 then col = (x <= 36 and y == 36) and CH[6] or CH[3] end
  c:put(x, y, col, gtok)
end)
c:put(36, 36, "#ffd9a0", gtok)
c:put(38, 37, CH[2], gtok) c:put(37, 38, CH[2], gtok)

-- cloth cap: dome over the lid + pinked skirt
local cl = c:ellipse(CX, 22, 11, 7)
cl:clip(c:rect(0, 15, 63, 23))
cl:add(c:poly{ { 21, 22 }, { 43, 22 }, { 47, 30 }, { 17, 30 } })
-- pinked hem: notch every 3 px
for x = 16, 48 do if x % 3 == 0 then cl.s[K(x, 30)] = nil cl.s[K(x, 29)] = nil elseif x % 3 == 1 then cl.s[K(x, 30)] = nil end end
-- cinch at the twine
for _, q in ipairs{ {21, 24}, {21, 25}, {43, 24}, {43, 25}, {20, 25}, {44, 25} } do cl.s[K(q[1], q[2])] = nil end
local cn = X.pillow(cl, 3)
-- folds: the skirt flutes outward (alternating light/dark columns)
local cb = {}
cl:each(function(x, y) local k = K(x, y)
  if y >= 26 then local f = G.fr((x - CX) / 5 + 0.25) if f < 0.3 then cb[k] = -1 elseif f > 0.7 then cb[k] = 1 end end end)
-- contact shadow of the cloth on the glass
cl:shift(0, 1):each(function(x, y) if jar:has(x, y) and not cl:has(x, y) then c:put(x, y, y < SURF and GLASS[1] or CH[1], gtok) end end)
local ctok = { r = { name = "cloth" } }
local ci = G.toneN(c, cl, cn, CLOTH, { tok = ctok, bias = cb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.15, wrap = 0.3 })
-- diagonal weave: every 3rd diagonal one tone darker
cl:each(function(x, y) local k = K(x, y)
  if (x + y) % 3 == 0 and (ci[k] or 1) > 2 then c:put(x, y, CLOTH[ci[k] - 1], ctok) end
end)
-- gold stitch along the hem

-- twine: twisted band around the neck + bow + loose ends
local ttok = { r = { name = "twine" } }
for x = 21, 43 do
  for y = 24, 25 do
    local i = ((x + (y - 24)) % 3 == 0) and 1 or (y == 24 and 3 or 2)
    if x > 38 and i > 1 then i = i - 1 end
    c:put(x, y, TW[i], ttok)
  end
end
-- bow on the right
local bow = { "ab..ab", "bcabcc", ".bddb.", "bccacb", "ab..ba" }
local BM = { a = TW[1], b = TW[2], c = TW[3], d = TW[4] }
for yy, row in ipairs(bow) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BM[ch] then c:put(39 + xx, 21 + yy, BM[ch], ttok) end end end
-- loose ends, one curling
for _, q in ipairs{ {43, 27, 2}, {44, 28, 3}, {44, 29, 2}, {45, 30, 3}, {45, 31, 2}, {46, 32, 1}, {41, 27, 2}, {41, 28, 3}, {40, 29, 2}, {40, 30, 1} } do
  c:put(q[1], q[2], TW[q[3]], ttok) end

G.fin(c)
