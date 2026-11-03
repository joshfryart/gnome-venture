-- ico-mushroom (final pass, Opus single pass). Bold icon: a fly-agaric toadstool. Wide domed red cap (6 tones,
-- waxy bloom band, one cream specular, cool bounce on the shade rim) with raised cream warts that foreshorten
-- toward the edge; a thin band of radial gills under the rim; a slim fibrous stem with a drooping ring skirt and a
-- swollen base. Ambient under the cap and under the ring. Ground shadow (it stands).
-- quirk: a single dewdrop is about to fall from the cap rim.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_2.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, sqrt, abs, atan = math.max, math.min, math.sqrt, math.abs, math.atan
local c = A.new("ico-mushroom")
local CAP = { "#5e1a30", "#8e2438", "#c4333c", "#e8493b", "#ff7752", "#ffaa78" }
local SPOT = { "#a8927e", "#cdb89c", "#e9dabb", "#f8eed4", "#fff4d6", "#fff4d6" }
local STEM = { "#6e5e60", "#9a8882", "#c4b3a2", "#e0d3bf", "#f2e9d6", "#fbf6e8" }
local GILL = { "#4a2e34", "#76524e", "#a07c6c", "#c6a68e" }
local WAT = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0", "#e4fbff" }
local ctok, stok, ttok, gtok, wtok = { r = { name = "cap" } }, { r = { name = "spot" } }, { r = { name = "stem" } }, { r = { name = "gill" } }, { r = { name = "dew" } }

c:groundShadow(32, 56, 13, 2)
-- stem: slim fibrous column with a swollen base
local sm, sn = A.tube({ { 32, 30 }, { 31, 40 }, { 33, 47 }, { 32, 54 } },
  function(t) return 3.2 + 2.3 * max(0, (t - 0.72) / 0.28) ^ 2 end)
sm:cut(c:rect(0, 56, 63, 63))
local sb = {}
-- ambient: top of stem under the cap, rows under the ring
sm:each(function(x, y) local k = K(x, y)
  if y <= 33 then sb[k] = -2 elseif y <= 35 then sb[k] = -1 end
  if y == 41 or y == 42 then sb[k] = (sb[k] or 0) - 1 end
end)
local sidx = A.shade(c, sm, sn, STEM, { amb = 0.12, wrap = 0.3, tok = ttok, bias = sb })
-- fibres: vertical streaks one tone darker
sm:each(function(x, y) local k = K(x, y)
  if y > 43 and y < 53 and (x == 30 or x == 33) and X.hash(x, y, 7) < 0.7 and sidx[k] and sidx[k] >= 3 then A.step(c, sidx, STEM, x, y, -1, ttok) end end)
-- ring skirt (annulus): drooping collar
local ring = c:ellipse(32, 38.5, 6.5, 1.8):add(c:poly{ { 26, 38 }, { 38, 38 }, { 39, 41 }, { 25, 41 } })
ring:add(c:ellipse(32, 40.5, 7, 1.5))
local rn = {}
ring:each(function(x, y) local s = (x + 0.5 - 32) / 7.5
  rn[K(x, y)] = { A.norm(s, (y - 38) * 0.18, sqrt(max(0.05, 1 - s * s))) } end)
local ridx = A.shade(c, ring, rn, STEM, { amb = 0.15, wrap = 0.35, tok = ttok })
-- skirt pleats + darker hem row
ring:each(function(x, y) local k = K(x, y)
  if (y >= 40 and x % 3 == 1) or not ring:has(x, y + 1) then A.step(c, ridx, STEM, x, y, -1, ttok) end end)
-- gills: band under the rim
local cap = c:ellipse(32, 30, 21, 16):cut(c:rect(0, 31, 63, 63))
cap:add(c:ellipse(32, 30, 21, 2.2))
local gill = c:ellipse(32, 31, 18, 4.6):cut(cap)
gill:cut(c:rect(0, 0, 63, 30))
gill:each(function(x, y)
  local d = abs(x + 0.5 - 32)
  local i = 3
  if y <= 32 then i = 1 elseif d < 6 then i = 2 elseif x > 38 then i = 2 end
  if i > 1 and (x % 2 == 0) then i = i - 1 end
  if i == 3 and x < 24 and y >= 33 then i = 4 end
  c:put(x, y, GILL[i], gtok)
end)
-- stem in front of the gills again (top of stem shows inside gill band)
sm:each(function(x, y) if gill:has(x, y) then c:put(x, y, STEM[(x < 32) and 2 or 1], ttok) end end)
-- cap: flattened dome, normals from an oblate ellipsoid with a bevelled rim
local cn = {}
cap:each(function(x, y)
  local dx, dy = (x + 0.5 - 32) / 21.5, (y + 0.5 - 31) / 16.5
  local q = dx * dx + dy * dy
  local nz = sqrt(max(0.04, 1 - q))
  local nx, ny = dx, dy * 1.1
  if y >= 29 then ny = ny + 0.55 end            -- rim lip curls under
  cn[K(x, y)] = { A.norm(nx, ny, nz * 1.1) }
end)
local cb = {}
local cidx = A.shade(c, cap, cn, CAP, { amb = 0.06, wrap = 0.25, tok = ctok, bias = cb })
-- waxy bloom: a pale band across the shoulder
cap:each(function(x, y) local k = K(x, y)
  local dx, dy = (x + 0.5 - 22) / 10, (y + 0.5 - 21) / 6
  local q = dx * dx + dy * dy
  if q > 0.75 and q < 1.0 and cidx[k] and cidx[k] >= 4 and cidx[k] <= 5 and x < 32 then A.step(c, cidx, CAP, x, y, 1, ctok) end end)
-- cool bounce on the lower-right rim
cap:each(function(x, y) if y >= 28 and y <= 30 and x >= 44 and not cap:has(x + 1, y) == false and not cap:has(x + 1, y + 1) then end end)
for _, p in ipairs{ { 49, 29 }, { 50, 28 }, { 51, 27 }, { 47, 30 }, { 48, 30 } } do if cap:has(p[1], p[2]) then c:put(p[1], p[2], "#9a3a6a", ctok) end end
-- warts: raised cream spots, foreshortened toward the rim
local spots = { { 23, 20, 3.2, 2.6 }, { 35, 16, 2.6, 2.0 }, { 44, 22, 2.8, 2.3 }, { 30, 25, 2.2, 1.6 }, { 15, 26, 1.8, 1.6 },
  { 39, 27, 1.8, 1.2 }, { 50, 26, 1.3, 1.3 }, { 28, 16, 1.2, 1.0 } }
for _, s in ipairs(spots) do
  local m = c:ellipse(s[1], s[2], s[3], s[4]):clip(cap:shrink(1))
  m:each(function(x, y) local i = cidx[K(x, y)] or 3
    local dx, dy = x + 0.5 - s[1], y + 0.5 - s[2]
    local j = min(6, max(1, i - 1 + ((dx + dy < -1) and 1 or 0)))
    c:put(x, y, SPOT[j], stok) end)
  -- cast shadow on the cap lower-right of each wart
  m:shift(1, 1):each(function(x, y) if cap:has(x, y) and not m:has(x, y) then
    local k = K(x, y) local i = cidx[k] or 3 c:put(x, y, CAP[max(1, i - 2)], ctok) end end)
end
-- specular on the cap + one sparkle
c:put(18, 19, A.CREAM, ctok) c:put(19, 19, A.CREAM, ctok) c:put(18, 20, CAP[6], ctok)
-- quirk: dewdrop hanging from the rim
local dm = c:ellipse(46, 37, 1.6, 1.9):add(c:rect(46, 33, 46, 35))
dm:each(function(x, y) c:put(x, y, WAT[3], wtok) end)
dm:each(function(x, y) if not dm:has(x + 1, y) or not dm:has(x, y + 1) then c:put(x, y, WAT[2], wtok) end end)
c:put(45, 36, WAT[5], wtok) c:put(46, 38, WAT[4], wtok) c:put(46, 33, WAT[4], wtok)
A.save(c, "ico-mushroom", "ico")
