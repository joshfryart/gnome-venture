-- ico-snake (final, Opus single pass). Slim grass snake laid in an open S (7-8 px body tapering to a 3 px tail), head
-- lifted at the upper right with a forked red tongue. Material: per-pixel tube light on a 6-tone green, a row of gold
-- diamond saddles down the spine (lit with the same tube), pale belly scutes peeking on the shade edge, a dark scale row
-- along each flank, glossy specular streak on each lit curve, AO under the jaw where head meets neck.
-- quirk: the tail tip is curled round a little acorn it is clearly not sharing.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi, math.atan
local c = A.new("ico-snake")
local GR = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a6d870" }
local GD = { "#5a3a1f", "#8f5a1f", "#c4842a", "#e8b23a", "#f8d66a", "#fff0a8" }
local BE = { "#4a5a3a", "#7c8f4c", "#b4c26a", "#dce596", "#f2f4c0", "#fbfbe0" }
local AC = { "#6a2e26", "#9a4a2a", "#c86c30", "#e48e3e", "#f4b45c", "#ffd88e" }
local CAP = { "#3e2a26", "#5e3e2e", "#7e5838", "#9c7448", "#b89262", "#d4b282" }
local btok, htok, atok = A.tok("snake"), A.tok("head"), A.tok("acorn")

-- quirk prop first (tail is drawn over it): acorn lying in the curl of the tail
do
  local am, an = A.oval(16.5, 47, 2.6, 2.4, 0.3)
  local ai = A.shade(c, am, an, AC, { amb = 0.15, wrap = 0.3, tok = atok })
  local cm, cn = A.oval(16.2, 44.6, 2.9, 1.5, 0.2)
  local ci = A.shade(c, cm, cn, CAP, { amb = 0.15, wrap = 0.3, tok = A.tok("cap") })
  -- cup scales: cross-hatch rows on the cap
  cm:each(function(x, y) if (x + y) % 3 == 0 and (ci[K(x, y)] or 1) >= 3 then A.step(c, ci, CAP, x, y, -1, A.tok("cap")) end end)
  c:put(15, 47, AC[6]) c:put(16, 47, A.CREAM)
end

local pts = { { 45, 18 }, { 37, 16.5 }, { 25, 18 }, { 18.5, 25 }, { 23, 32 }, { 35, 33.5 }, { 45, 39 }, { 45, 47 }, { 35, 51.5 }, { 24, 52 }, { 16, 51.5 }, { 11, 48.5 }, { 10.5, 43.5 }, { 14, 40.5 }, { 19, 41 } }
local function hw(t)
  if t < 0.03 then return 3.0 + t / 0.03 * 0.6 end
  if t < 0.55 then return 3.6 end
  return 3.6 - (t - 0.55) / 0.45 * 2.45
end
local bm, bn, BT, BS, samp = A.ctube(pts, hw, 300)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x)^2 + (samp[i].y - samp[i - 1].y)^2) end

-- head: rounded wedge pointing right-up, painted after body
local HX, HY, HA = 49.5, 16.5, -0.18
local hm, hn = A.oval(HX, HY, 6.2, 4.3, HA)
local hd = A.oval(HX + 3.6, HY - 0.7, 3.2, 3.0, HA) -- snout taper
hm:add(hd)
local hn2 = X.pillow(hm, 3.2)
local bias = {}
bm:cut(hm)
-- AO on the neck right under the jaw
bm:each(function(x, y) local k = K(x, y) if BT[k] < 0.06 then bias[k] = (bias[k] or 0) - 1 end end)
local bidx = A.shade(c, bm, bn, GR, { amb = 0.08, wrap = 0.28, bias = bias, tok = btok })
-- spine saddles: diamonds every 6 px of length, same light index
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  if t > 0.05 and t < 0.9 then
    local ph = (t * LEN) / 7
    local f = abs(ph - floor(ph) - 0.5) * 2 -- 0 at centre of a saddle
    local wdt = 0.46 * (1 - min(1, (t - 0.6) / 0.35) * 0.4)
    if abs(s) * 1.0 + f * 0.85 < wdt then c:put(x, y, GD[bidx[k]], btok) end
  end
end)
-- dark scale row along each flank (between saddles and edge) + pale belly scutes on the shade edge
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  if t > 0.04 and t < 0.95 then
    if s > 0.78 then
      local ph = t * LEN / 2.5
      local ii = min(6, (bidx[k] or 3) + 1)
      c:put(x, y, (ph - floor(ph) < 0.25) and BE[max(1, ii - 2)] or BE[ii], btok)
    end
  end
end)
-- glossy streak along lit curves: brightest band, cream glint at the top of each lit bend
local spec = X.spec(bn, 26)
bm:each(function(x, y) local k = K(x, y)
  if spec[k] > 0.62 and BS[k] < -0.2 and BS[k] > -0.75 and BT[k] > 0.05 and BT[k] < 0.8 then
    if c:get(x, y) == GR[bidx[k]] then c:put(x, y, GR[6], btok) end
  end
end)

-- head
local hidx = A.shade(c, hm, hn2, GR, { amb = 0.1, wrap = 0.3, tok = htok })
-- gold crown mark on the head (top), lit the same
local crown = A.oval(HX - 2, HY - 0.8, 2.4, 1.6, HA)
crown:each(function(x, y) if hm:has(x, y) then c:put(x, y, GD[max(3, hidx[K(x, y)] or 3)], htok) end end)
-- jaw line on the shade side (lower edge) + pale chin
hm:each(function(x, y)
  if not hm:has(x, y + 1) and x > HX - 4 then c:put(x, y, BE[3], htok) end
end)
-- eye: 2x3 ink pill with glint, a lit brow pixel above
c:eyeSmall(51, 13)
c:put(50, 12, GR[6], htok) c:put(51, 12, GR[5], htok)
-- nostril near snout tip, smile curl
c:put(55, 14, GR[1], htok)
c:put(53, 18, GR[1], htok) c:put(54, 18, GR[1], htok) c:put(55, 17, GR[1], htok)
-- specular on the head top-left
c:put(46, 14, A.CREAM, htok) c:put(47, 14, GR[6], htok)

-- forked tongue flicking right-down from the snout
local TG = "#e8493b"
for _, p in ipairs{ { 57, 16 }, { 58, 16 }, { 59, 16 }, { 60, 15 }, { 60, 17 } } do c:put(p[1], p[2], TG) end
A.save(c, "ico-snake")
