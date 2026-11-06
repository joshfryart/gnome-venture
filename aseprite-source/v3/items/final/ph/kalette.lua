-- kalette (final pass, Opus single pass). One flower sprout: a loose rosette of seven small frilly leaves fanning
-- from a tight purple-tinged heart bud, set on a slim pale stalk with a fresh cut end (pale core ring). Leaves are
-- blue-green with purple midribs and purple-flushed frills, V-fold light, AO + contact shadow where each leaf
-- tucks under the next. quirk: a ladybird is out for a walk on the right-hand leaf.
local NAME = "kalette"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1a2c34", "#24463e", "#336646", "#4c8a4e", "#74ae5c", "#a8d07c" }
local PUR = { "#2e1a3e", "#4a2a5e", "#6e3e86", "#9562aa", "#bf92cc", "#e2c4e6" }
local STEM = { "#4d6a4c", "#7f9f74", "#b2cf9a", "#dcecc0", "#f2f7dc" }
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- stalk first (the rosette sits over its top)
local stok = { r = { name = "stalk" } }
local sp = { { 32, 36 }, { 32, 44 }, { 31, 50 }, { 32, 56 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 2.3 + t * 0.4 end)
local sidx = A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.85 } })
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.4) < 0.12 and ST[k] > 0.2 then c:put(x, y, STEM[max(1, sidx[k] - 1)], stok) end end)
-- leaf scars on the stalk
c:put(30, 47, STEM[1], stok) c:put(34, 51, STEM[1], stok) c:put(33, 51, STEM[2], stok)
-- cut end: pale ring with a greener core on the bottom row
local by = 0
sm:each(function(x, y) if y > by then by = y end end)
sm:each(function(x, y) if y == by then c:put(x, y, STEM[5], stok) end end)
sm:each(function(x, y) if y == by and sm:has(x - 1, y) and sm:has(x + 1, y) and sm:has(x - 2, y) and sm:has(x + 2, y) then c:put(x, y, STEM[3], stok) end end)

-- leaves (rounded spoon tips, not pointed): base, control, tip, max half width; order = paint order (back to front)
local L = {
  { 31, 31, 25, 21, 21, 11, 5.4 },
  { 33, 31, 40, 21, 44, 11, 5.4 },
  { 32, 30, 31, 20, 33, 9, 5.0 },
  { 30, 34, 20, 31, 12, 25, 5.2 },
  { 34, 34, 44, 31, 52, 26, 5.2 },
  { 31, 37, 24, 41, 17, 40, 4.6 },
  { 33, 37, 40, 41, 47, 41, 4.6 },
}
for _, l in ipairs(L) do
  l.m, l.n, l.T, l.S, l.len = A.blade(l[1], l[2], l[3], l[4], l[5], l[6], function(t)
    if t > 0.99 then return -1 end
    local w = l[7] * sin(pi * min(1, t * 0.6 + 0.14)) ^ 0.5
    if t > 0.78 then w = w * math.sqrt(max(0, 1 - ((t - 0.78) / 0.22) ^ 2)) end
    return max(0.6, w)
  end, { fold = 0.45 })
  l.F = A.frill(l.m, l.T, l.S, l.len, 3.1, function(t) return 0.3 end, 0.2, 0.97)
  A.ruffle(l.n, l.T, l.S, l.len, 3.1, 0.6, 0.65, 0.2, -1)
end
-- heart bud
local bud = A.rell(32, 33, 0, -1, 4.4, 4.0)
local budN = X.sphere(32, 33, 4.4, bud)

local ltok = { r = { name = "leaf" } }
for i, l in ipairs(L) do
  local vis = l.m:copy()
  local bias = {}
  for j = i + 1, #L do vis:cut(L[j].m) X.ao(bias, l.m, L[j].m, 1, -1) A.cast(bias, l.m, L[j].m, 1, 2, -1) end
  if i <= 5 then vis:cut(bud) X.ao(bias, l.m, bud, 1, -1) A.cast(bias, l.m, bud, 1, 1, -1) end
  local idx = A.shade(c, vis, l.n, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  vis:each(function(x, y) local k = K(x, y) local s, t = l.S[k], l.T[k]
    local ii = idx[k]
    if abs(s) < 0.13 and t > 0.12 and t < 0.86 then c:put(x, y, s <= 0 and PUR[5] or PUR[3], ltok)            -- purple midrib
    elseif abs(s) > 0.74 and (l.F[k] or 1) < 0.75 then c:put(x, y, PUR[max(1, min(6, ii))], ltok)            -- purple-flushed frill
    else
      local ph = (t * l.len - abs(s) * 3) / 3.6 + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.88 and abs(s) > 0.2 and abs(s) < 0.65 and t > 0.15 and t < 0.85 and not bias[k] then
        c:put(x, y, s < 0 and LEAF[min(6, ii + 1)] or LEAF[max(1, ii - 1)], ltok) end
    end
  end)
end
-- bud over back/side leaves, under the two front leaves
local bvis = bud:copy():cut(L[6].m):cut(L[7].m)
local bb = {}
X.ao(bb, bud, L[6].m, 1, -1) X.ao(bb, bud, L[7].m, 1, -1)
local btok = { r = { name = "bud" } }
local bi = A.shade(c, bvis, budN, PUR, { tok = btok, bias = bb, amb = 0.12, wrap = 0.3 })
-- folded leaf lines across the bud (green tips peeking)
bvis:each(function(x, y) local k = K(x, y)
  if (y == 31 and x >= 30 and x <= 33) or (x == 32 and y >= 29 and y <= 31) then c:put(x, y, PUR[max(1, bi[k] - 2)], btok) end
  if y <= 30 and (x == 29 or x == 35) then c:put(x, y, LEAF[min(6, bi[k] + 1)], btok) end
end)
local gx, gy = A.specAt(bvis, budN, 30)
if gx then c:put(gx, gy, PUR[6], btok) end

-- quirk: ladybird on the right leaf
local lx, ly = 47, 26
local qtok = { r = { name = "ladybird" } }
for _, q in ipairs{ { 0, 0, 3 }, { 1, 0, 3 }, { 2, 0, 2 }, { -1, 1, 3 }, { 0, 1, 4 }, { 1, 1, 3 }, { 2, 1, 2 }, { 0, 2, 2 }, { 1, 2, 1 } } do
  c:put(lx + q[1], ly + q[2], RED[q[3]], qtok) end
c:put(lx + 1, ly + 1, "#2b1c26", qtok)            -- spot
c:put(lx - 1, ly, "#2b1c26", qtok) c:put(lx - 2, ly, "#2b1c26", qtok)  -- head
c:put(lx, ly, "#fff4d6", qtok)

A.save(c, NAME)
