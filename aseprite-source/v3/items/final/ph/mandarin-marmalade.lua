-- mandarin-marmalade (final, Opus single pass). A slim glass jar of glowing amber-orange marmalade with shreds of
-- peel suspended in it: glass rim lit top-left (pale bright wall + specular streak, cool wall on the right, thick
-- tinted base), a cream paper label with a tiny mandarin and two ink lines, an orange-gingham cloth cap (pillow
-- shading, check weave, pleat folds, pinked hem) cinched by twisted twine with a bow. Ground shadow (it stands).
-- quirk: a fat drip of marmalade has oozed out from under the cloth and is crawling down the glass.
local NAME = "mandarin-marmalade"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local MARM = { "#6a1c22", "#a3301e", "#d25418", "#ee7a1e", "#ffa236", "#ffcf72" }
local SHRED = { "#8a2a18", "#ffb84a" }
local GLASS = { "#4b7f9a", "#86c2cc", "#c6efe8", "#eafff8" }
local BASE = { "#9a6a3a", "#c98c42", "#e8b064" }   -- thick glass base tinted by the marmalade
local PAPER = { "#b39a78", "#dcc79c", "#f3e5bf", "#fff4d6" }
local CLO = { "#8e3a24", "#c4522a", "#ea7434", "#ff9a52", "#ffc08a" } -- orange check
local CLC = { "#9a8a78", "#c9b89a", "#e9dcbc", "#f8eed2", "#fff4d6" } -- cream check
local TW = { "#5c3a26", "#8f6038", "#c09058", "#e2bc80" }
local LEAF = { "#1f5a40", "#47994f", "#8cc862" }

c:groundShadow(32, 56, 14, 2)

-- jar body: slim, rounded shoulders
local jar = c:rrect(21, 21, 42, 55, 5)
local neck = c:rect(24, 17, 39, 21)
local jm = jar:copy():add(neck)
local wall = jar:edge()
local inside = jar:copy():cut(wall)
-- marmalade fill (cylindrical lighting, translucent: stays bright inside)
local mtok = { r = { name = "marmalade" } }
local fill = inside:copy():cut(c:rect(0, 52, 63, 63))
local _, mn = X.cyl(31.5, 0, 31.5, 63, function() return 10.5 end, fill)
local midx = A.shade(c, fill, mn, MARM, { amb = 0.3, wrap = 0.45, tok = mtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- suspended peel shreds: short slanted slivers
for _, s in ipairs{ { 24, 27, 1 }, { 30, 25, 1 }, { 37, 28, -1 }, { 26, 44, 1 }, { 35, 46, -1 }, { 39, 38, 1 }, { 24, 37, -1 }, { 32, 49, 1 }, { 38, 50, -1 }, { 29, 30, -1 } } do
  for j = 0, 2 do local x, y = s[1] + j, s[2] + s[3] * floor(j / 2 + 0.5) * (j == 1 and 0 or 1)
    if fill:has(x, y) then local i = midx[K(x, y)] or 3 c:put(x, y, i >= 4 and SHRED[1] or SHRED[2], mtok) end end
end
-- glass walls
local gtok = { r = { name = "glass" } }
wall:each(function(x, y)
  if y >= 52 then return end
  if x <= 22 or (y <= 23 and x < 32) then c:put(x, y, GLASS[3], gtok)
  elseif x >= 41 or y <= 23 then c:put(x, y, GLASS[1], gtok)
  else c:put(x, y, GLASS[2], gtok) end
end)
-- thick base
jar:each(function(x, y) if y >= 52 then
  c:put(x, y, (y == 55 or x >= 40) and BASE[1] or ((y == 52) and BASE[3] or BASE[2]), gtok) end end)
for x = 24, 30 do c:put(x, 53, BASE[3], gtok) end
-- specular streak down the left of the glass + a short second one, cool reflected strip on the right
for y = 26, 45 do c:put(23, y, GLASS[4], gtok) end
for y = 26, 31 do c:put(25, y, GLASS[3], gtok) end
c:put(23, 25, A.CREAM, gtok)
for y = 28, 49 do c:put(40, y, GLASS[2], gtok) end

-- label: cream paper, gently curved (cylinder tones), tiny mandarin + two ink lines
local ptok = { r = { name = "label" } }
local lab = c:rect(26, 33, 37, 43)
lab:each(function(x, y)
  local i = (x <= 27) and 3 or ((x >= 36) and 1 or 3)
  if x >= 34 and x < 36 then i = 2 end
  if x == 28 or x == 29 then i = 4 end
  if y == 43 then i = max(1, i - 1) end
  c:put(x, y, PAPER[i], ptok)
end)
-- AO under the label's lower edge onto the marmalade
for x = 26, 37 do c:put(x, 44, MARM[2], mtok) end
-- tiny mandarin (5x4 disc) + leaf
local fr = { "  ooo", " oOOoo", " oOooo", "  ooo" }
for yy, row in ipairs(fr) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if ch == "o" then c:put(26 + xx, 34 + yy, MARM[4], ptok) elseif ch == "O" then c:put(26 + xx, 34 + yy, MARM[6], ptok) end end end
c:put(30, 35, LEAF[2], ptok) c:put(31, 34, LEAF[3], ptok) c:put(29, 35, LEAF[1], ptok)
for x = 33, 35 do c:put(x, 36, PAPER[1], ptok) end
for x = 33, 36 do c:put(x, 38, PAPER[1], ptok) end
for x = 28, 35 do c:put(x, 41, PAPER[2], ptok) end

-- cloth cap: puff above the twine, skirt flaring below it with a pinked hem
local cap = HP.mask()
for y = 9, 18 do for x = 18, 46 do
  local u, v = (x - 31.5) / 10.5, (y - 15.5) / 6.5
  if u * u + v * v <= 1 then cap:set(x, y) end end end
for y = 17, 25 do
  local half = 8 + (y - 17) * 0.62
  for x = floor(31.5 - half), floor(31.5 + half + 0.5) do
    local hem = (y >= 24) and ((x % 3 == 0) == (y == 25)) -- pinked zigzag
    if y == 25 and x % 3 ~= 1 then hem = true end
    if not hem then cap:set(x, y) end
  end
end
local cn = X.pillow(cap, 3)
local ctok = { r = { name = "cloth" } }
local cv = X.light(cn, { amb = 0.15, wrap = 0.35 })
cap:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs{ 0.25, 0.45, 0.65, 0.85 } do if cv[k] >= t then i = j + 1 end end
  -- pleats on the skirt: fold lines fan out from the twine
  if y > 19 then local f = (x - 31.5) / (y - 15) * 4
    if abs(f - floor(f + 0.5)) < 0.12 then i = max(1, i - 1) end end
  if y <= 13 and x < 30 and y + x < 38 then i = min(5, i + 1) end
  local check = ((floor((x - 1) / 3) + floor(y / 3)) % 2 == 0)
  c:put(x, y, check and CLO[i] or CLC[i], ctok)
end)
-- twine band (twisted: alternating light/dark diagonal pairs) + bow on the right with dangling ends
local ttok = { r = { name = "twine" } }
for x = 22, 41 do
  c:put(x, 18, TW[(x % 2 == 0) and 3 or 2], ttok)
  c:put(x, 19, TW[(x % 2 == 0) and 1 or 2], ttok)
end
c:put(22, 18, TW[4], ttok)
local bow = { { 41, 17, 3 }, { 42, 16, 4 }, { 43, 16, 3 }, { 44, 17, 2 }, { 43, 18, 2 }, { 42, 18, 3 }, { 42, 19, 2 },
  { 43, 20, 2 }, { 44, 20, 1 }, { 44, 21, 2 }, { 45, 22, 1 }, { 42, 20, 3 }, { 42, 21, 2 }, { 42, 22, 1 }, { 43, 23, 2 } }
for _, q in ipairs(bow) do c:put(q[1], q[2], TW[q[3]], ttok) end

-- quirk: drip oozing from under the hem down the glass (front, right of the label)
local dtok = { r = { name = "drip" } }
local drip = { { 38, 26, 4 }, { 39, 26, 3 }, { 38, 27, 4 }, { 39, 27, 3 }, { 38, 28, 5 }, { 39, 28, 3 }, { 38, 29, 4 },
  { 39, 29, 2 }, { 38, 30, 4 }, { 39, 30, 3 }, { 37, 31, 5 }, { 38, 31, 4 }, { 39, 31, 3 }, { 37, 32, 4 }, { 38, 32, 3 }, { 39, 32, 2 },
  { 38, 33, 2 } }
for _, q in ipairs(drip) do c:put(q[1], q[2], MARM[q[3]], dtok) end
c:put(37, 31, A.CREAM, dtok)

A.save(c, NAME)
