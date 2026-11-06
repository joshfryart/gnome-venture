-- dried-mango (Opus single pass). Three slim, leathery strips of dried mango fanned from the bottom and held by
-- a kraft-paper band; each strip gently curved, edges ragged.
-- Material: per-pixel light on a soft half-cylinder (6-tone saturated orange, cool-violet shade), fibre ridges
-- across each strip (dark groove + lit lip), translucent glowing edge on the lit side, sugar glints, ambient
-- shading where strips overlap and under the band; paper band with fold creases and a lit top edge.
-- quirk: the middle strip's tip has curled back on itself, showing its paler, matte underside.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local c = A.new("dried-mango")
local MG    = { "#6e2420", "#a83a1c", "#d8621e", "#f28d26", "#ffb83e", "#ffdc7a" }
local UNDER = { "#9a5a2a", "#c8823a", "#e6a852", "#f6c874", "#ffe2a0", "#fff0c4" }
local PAPER = { "#4e3424", "#7a573a", "#a37c52", "#c6a070", "#e2c28e", "#f2dcae" }
local GLOW, SPEC, BOUNCE = "#ffe9a0", "#fff4d6", "#9a4a6a"

local strips = {
  { { { 27, 50 }, { 22, 40 }, { 14, 26 }, { 12, 10 } }, 3.6, 1 },   -- left
  { { { 37, 50 }, { 42, 40 }, { 50, 28 }, { 52, 14 } }, 3.5, 3 },   -- right
  { { { 32, 51 }, { 32, 40 }, { 29, 22 }, { 33, 9 } },  3.8, 2 },   -- middle (front)
}
local stok = { r = { name = "mango" } }
local masks = {}
local all = HP.mask()
for si, s in ipairs(strips) do
  local p, W, seed = s[1], s[2], s[3]
  local m, n, T, S, samp = A.tube(p, function(t)
    local w = W * (0.88 + 0.12 * sin(t * 9 + seed)) + (X.hash(floor(t * 40), seed, 3) - 0.5) * 0.7
    if t > 0.93 then w = w * (1 - (t - 0.93) * 6) end
    return w
  end)
  -- soften the cylinder: strips are flat-ish leather
  for k, nn in pairs(n) do n[k] = { A.norm(nn[1] * 0.75, nn[2] * 0.75 - 0.08 * sin(T[k] * 14 + seed), nn[3]) } end
  local bias = {}
  for _, o in ipairs(masks) do X.ao(bias, m, o, 1, -1) end
  local L = 46
  m:each(function(x, y) local k = K(x, y)
    local t, sn = T[k], S[k]
    -- fibre ridges across the strip, slightly chevroned
    local ph = t * L * 0.62 + sn * sn * 1.3 + seed
    local f = ph % 2.6
    if f < 0.55 and abs(sn) < 0.8 then bias[k] = (bias[k] or 0) - 1
    elseif f < 1.05 and abs(sn) < 0.7 then bias[k] = (bias[k] or 0) + 1 end
  end)
  local idx = A.tone(c, m, n, MG, { bias = bias, amb = 0.1, wrap = 0.3 })
  -- translucent glowing edge on the lit side
  m:edge():each(function(x, y) local k = K(x, y) if S[k] < -0.5 and T[k] > 0.1 and T[k] < 0.92 and (idx[k] or 0) >= 3 then c:put(x, y, GLOW, stok) end end)
  A.bounce(c, m, n, BOUNCE, 0.72, stok)
  masks[#masks + 1] = m
  all:add(m)
  s.m, s.n, s.T, s.S, s.samp = m, n, T, S, samp
end
-- the middle strip shades the side strips where it crosses them (painted over them already; add contact shade)
for si = 1, 2 do
  local o = strips[si]
  A.cast({}, o.m, strips[3].m, 1, 1, -1)
  strips[3].m:shift(1, 1):each(function(x, y)
    if o.m:has(x, y) and not strips[3].m:has(x, y) then
      local cur = c:get(x, y)
      for i = 2, 6 do if cur == MG[i] then c:put(x, y, MG[i - 1], stok) break end end
    end
  end)
end
-- sugar glints: one cream specular on the middle strip, two tiny hi crystals
do local m, n = strips[3].m, strips[3].n
  local gx, gy = A.glint(c, m, n, SPEC, MG[6], stok, 24)
end
c:put(16, 24, MG[6], stok) c:put(47, 30, MG[6], stok)

-- quirk: the middle strip's tip curls back (pale matte underside), rolled toward the viewer
do
  local cm, cn, CT, CS = A.tube({ { 33, 10 }, { 35, 5 }, { 39, 6 }, { 38, 12 } }, function(t) return 2.9 - t * 0.9 end)
  cm:cut(strips[3].m:shrink(1))
  local cb = {}
  cm:each(function(x, y) local k = K(x, y) if CT[k] > 0.7 then cb[k] = -1 end end)
  A.tone(c, cm, cn, UNDER, { bias = cb, amb = 0.15 })
  -- dark crease under the roll where it meets the strip
  strips[3].m:each(function(x, y) if cm:has(x, y - 1) and not cm:has(x, y) and y > 8 then c:put(x, y, MG[1], stok) end end)
end

-- kraft-paper band across the bunch, tilted slightly
local band = HP.mask()
for y = 38, 48 do for x = 16, 50 do
  local yc = 42.5 + (x - 33) * 0.06
  if abs(y - yc) <= 3 then band:set(x, y) end
end end
local bx0, bx1 = 1e9, -1e9
all:each(function(x, y) if band:has(x, y) then bx0 = min(bx0, x) bx1 = max(bx1, x) end end)
band:clip(c:rect(bx0 - 1, 30, bx1 + 1, 50))
-- band hugs the strips: rounded vertical normal, slight bulge over each strip
local bn = {}
band:each(function(x, y)
  local yc = 42.5 + (x - 33) * 0.06
  local sy = (y - yc) / 3.6
  local sx = ((x - bx0) / (bx1 - bx0)) * 2 - 1
  bn[K(x, y)] = { A.norm(sx * 0.7, sy, sqrt(max(0.05, 1 - sy * sy))) }
end)
local bb = {}
band:each(function(x, y) local k = K(x, y)
  if x == 25 or x == 41 then bb[k] = -1 end              -- fold creases
  if x == 26 or x == 42 then bb[k] = 1 end
end)
local btok = { r = { name = "band" } }
A.tone(c, band, bn, PAPER, { bias = bb, amb = 0.12, wrap = 0.3, tok = btok })
-- AO: strips just above/below the band
all:each(function(x, y) if not band:has(x, y) and (band:has(x, y - 1) or band:has(x, y + 1)) then
  local cur = c:get(x, y)
  for i = 2, 6 do if cur == MG[i] then c:put(x, y, MG[max(1, i - 2)], stok) break end end
end end)
-- printed mango stamp on the band
local sx = 33
c:put(sx, 41, "#e8722a", btok) c:put(sx + 1, 41, "#e8722a", btok) c:put(sx - 1, 42, "#c8501e", btok)
c:put(sx, 42, "#e8722a", btok) c:put(sx + 1, 42, "#c8501e", btok) c:put(sx, 43, "#c8501e", btok)
c:put(sx + 1, 40, "#3f9150", btok)
A.done(c, "dried-mango")
