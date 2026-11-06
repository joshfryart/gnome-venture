-- meadowsweet-tea (final pass, Opus, replaces Sonnet draft). A slim tulip teacup in teal glaze on an ivory saucer:
-- per-pixel lit cup body (6 tones) with a gold rim band, a long glaze specular streak and a cool bounce on the shade
-- side; a ring handle with its own bevel; cream interior wall behind amber tea (darker where it meets the wall, a
-- bright reflection). Saucer with a sunken well, lit rim, dark underside lip and a contact shadow under the foot.
-- A small meadowsweet sprig rests on the saucer. One 2-tone steam curl.
-- quirk: a single meadowsweet floret floats on the tea, ringed by a ripple.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "meadowsweet-tea"
local c = A.new(NAME)

local GLZ  = { "#1d354e", "#2a536c", "#3a788a", "#559fa6", "#86c7bf", "#c0ecdc" }
local CER  = { "#6a5862", "#968488", "#c2b2a6", "#e0d4c0", "#f1e9d8", "#fffaee" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local TEA  = { "#5e2c14", "#8c4a1a", "#b87024", "#da9836", "#f0bc56", "#fcdc8a" }
local STEM = { "#5f2433", "#84323d", "#a8474a", "#c8665c" }
local CRM  = { "#998276", "#c3b092", "#e0d3b0", "#f2e9cc", "#fffae8" }
local LEAF = { "#1f553f", "#2b7246", "#42904c", "#68ae56", "#9acb6c" }
local GSPEC, COOL, STEAM1, STEAM2 = "#f2fff6", "#6a8cb4", "#f4eee8", "#c9c2d2"
local ctok, stok, ttok = { r = { name = "cup" } }, { r = { name = "saucer" } }, { r = { name = "tea" } }

c:groundShadow(31, 53, 19, 2)

-- saucer
local CX = 31
local stop = A.ell(CX, 48, 19, 4.2)
local sall = stop:copy():add(A.ell(CX, 50, 15, 3))
local sn = X.pillow(stop, 2.5)
local sb = {}
local well = A.ell(CX - 1, 47.6, 10, 2.4)
well:each(function(x, y) sb[K(x, y)] = -1 end)
A.ell(CX - 1, 47.6, 8, 1.8):each(function(x, y) sb[K(x, y)] = 0 end)
-- contact shadow right/below the foot
A.ell(CX + 1, 48.2, 6.5, 1.6):each(function(x, y) sb[K(x, y)] = (sb[K(x, y)] or 0) - 2 end)
A.shade(c, stop, sn, CER, { tok = stok, bias = sb, amb = 0.2, wrap = 0.4, cuts = { 0.2, 0.38, 0.55, 0.7, 0.84 } })
sall:each(function(x, y) if not stop:has(x, y) then
  c:put(x, y, (x < CX - 6) and CER[3] or ((x < CX + 8) and CER[2] or CER[1]), stok) end end)
-- saucer rim glint
c:put(CX - 13, 45, CER[6], stok) c:put(CX - 12, 45, CER[6], stok)

-- cup body (tulip): half width per row
local top, bot = 26, 44
local function hw(y)
  local t = (y - top) / (bot - top)
  return 6.6 + 5.6 * cos(min(1, max(0, t)) * pi / 2) ^ 0.9 + 0.5 * sin(t * pi) * (1 - t)
end
local body = HP.mask()
for y = top, bot do local w = hw(y) for x = floor(CX - 1 - w), floor(CX - 1 + w) + 1 do
  if abs(x - (CX - 1) + 0.0) <= w then body:set(x, y) end end end
body:add(A.ell(CX - 1, bot, 6.4, 1.6))
local foot = A.ell(CX - 1, 46, 4.6, 1.3)
-- foot first (so the body overlaps it)
local fn = A.ellN(CX - 1, 46, 4.6, 1.3, foot, 0.8)
A.shade(c, foot, fn, GLZ, { tok = ctok, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 } })
local bn = {}
body:each(function(x, y)
  local w = hw(min(y, bot))
  local s = max(-0.97, min(0.97, (x - (CX - 1)) / (w + 0.5)))
  local ny = (y - top) / (bot - top) * 0.55 - 0.15
  if y > bot then ny = 0.75 end
  bn[K(x, y)] = { A.norm(s, ny, sqrt(1 - s * s)) }
end)

-- handle (ring) behind/right of the body
local hdl = A.ell(CX + 12, 33, 4.3, 4.9):cut(A.ell(CX + 12.4, 33, 1.7, 2.4))
hdl:cut(body)
local hn = X.pillow(hdl, 1.4)
local hb = {}
X.ao(hb, hdl, body, 1, -1)
A.shade(c, hdl, hn, GLZ, { tok = ctok, bias = hb, cuts = { 0.24, 0.4, 0.56, 0.72, 0.88 } })

local bb = {}
local bidx = A.shade(c, body, bn, GLZ, { tok = ctok, bias = bb, amb = 0.05, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
-- gold band
body:each(function(x, y) if y == top + 3 then
  local i = bidx[K(x, y)] or 3
  c:put(x, y, GOLD[max(1, min(4, i - 2))], ctok) end end)
-- specular streak + cool bounce on the shade side
for y = top + 5, top + 12 do c:put(floor(CX - 1 - hw(y) * 0.55 + 0.5), y, y < top + 10 and GSPEC or GLZ[6], ctok) end
body:edge():each(function(x, y) local w = hw(min(y, bot))
  if x > CX - 1 + w - 1.2 and y > top + 6 and y < bot then c:put(x, y, COOL, ctok) end end)

-- rim, interior, tea
local rim = A.ell(CX - 1, top, 12.2, 3.4)
local open_ = A.ell(CX - 1, top + 0.2, 10.8, 2.5)
rim:cut(open_)
rim:each(function(x, y)
  local col = (y <= top) and CER[5] or (x < CX - 1 and GLZ[6] or GLZ[4])
  if y > top and x > CX + 6 then col = GLZ[3] end
  if y < top and x > CX + 4 then col = CER[4] end
  c:put(x, y, col, ctok)
end)
c:put(CX - 9, top - 2, CER[6], ctok) c:put(CX - 8, top - 2, CER[6], ctok)
open_:each(function(x, y) c:put(x, y, x < CX - 4 and CER[3] or CER[2], ctok) end)   -- back inner wall in shadow
local tea = A.ell(CX - 1, top + 1, 10.2, 1.7):clip(open_)
local tn = {}
tea:each(function(x, y) local k = K(x, y)
  local i = (y <= top) and 3 or 4
  if x > CX + 5 then i = i - 1 end
  if y >= top + 2 then i = i + 1 end
  c:put(x, y, TEA[max(1, min(6, i))], ttok)
end)
-- tea meets wall: dark line along the back of the surface
tea:each(function(x, y) if not tea:has(x, y - 1) then c:put(x, y, TEA[2], ttok) end end)
-- reflection on the tea
c:put(CX - 7, top + 1, TEA[6], ttok) c:put(CX - 6, top + 1, TEA[6], ttok) c:put(CX - 5, top + 1, TEA[5], ttok)

-- quirk: floating floret + ripple
local fx, fy = CX + 3, top + 1
for _, p in ipairs{ { -2, 0 }, { 2, 0 }, { -1, 1 }, { 1, 1 }, { 0, 1 } } do c:put(fx + p[1], fy + p[2], TEA[4], ttok) end
c:put(fx - 1, fy, CRM[5], ttok) c:put(fx, fy, "#f2d27a", ttok) c:put(fx + 1, fy, CRM[3], ttok) c:put(fx, fy - 1, CRM[4], ttok)

-- steam curl (2 tones, clear of the rim)
local wisp = { { 28, 21 }, { 27, 20 }, { 27, 19 }, { 28, 18 }, { 29, 17 }, { 29, 16 }, { 28, 15 }, { 27, 14 } }
for i, p in ipairs(wisp) do c:put(p[1], p[2], STEAM1, ctok) c:put(p[1] + 1, p[2], STEAM2, ctok) end

-- garnish sprig on the saucer (front left)
local gtok = { r = { name = "sprig" } }
A.stroke(c, { { 21, 50 }, { 17, 49 }, { 14, 48 } }, STEM[2], gtok)
A.stroke(c, { { 21, 49 }, { 17, 48 } }, STEM[4], gtok)
for _, p in ipairs{ { 12, 46, 5 }, { 13, 45, 4 }, { 11, 47, 3 }, { 13, 47, 3 }, { 14, 46, 4 }, { 12, 45, 5 }, { 15, 47, 2 }, { 11, 46, 4 } } do
  c:put(p[1], p[2], CRM[p[3]], gtok) end
c:put(13, 46, "#f2d27a", gtok)
for _, p in ipairs{ { 19, 51, 2 }, { 20, 51, 3 }, { 21, 51, 4 }, { 22, 51, 2 }, { 18, 51, 1 } } do c:put(p[1], p[2], LEAF[p[3]], gtok) end

A.save(c, NAME)
