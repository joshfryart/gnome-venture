-- moringa (ph, Opus single pass). A single long, slim drumstick pod laid on the diagonal: three-angled, so it
-- carries a pale lit ridge and a dark groove along its length; it swells over each seed and pinches between them
-- (AO ticks at each pinch), tapers to a point, and ends in a short woody stalk. Behind it, a sprig of the
-- feathery leaf: a thin curved rachis with paired small oval leaflets (V-folded, midribs) and a terminal leaflet,
-- AO lines where leaflets overlap. Pod 6-tone yellow-green, leaves 6-tone blue-green; one waxy specular on a bulge.
-- quirk: one leaflet has turned yellow and is drifting off the sprig.
local NAME = "moringa"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local POD  = { "#24402f", "#365e33", "#527d38", "#76a040", "#a2c25a", "#d4e48e" }
local LEAF = { "#14363a", "#1d5245", "#29714a", "#3f9150", "#62b05a", "#96cc70" }
local YEL  = { "#6a4a26", "#9a7228", "#c69a2e", "#e6c044", "#f6dc72", "#fff0b0" }
local STALK = { "#4a3428", "#7a5638", "#a87c4e" }
local RACH = "#5f8a44"
local SPEC = "#f6ffd8"

-- leaf sprig (behind the pod)
local ltok = { r = { name = "leaf" } }
local rp = { { 22, 46 }, { 13, 37 }, { 13, 23 }, { 21, 12 } }
local union = HP.mask()
local function drawLeaflet(cx, cy, ang, ra, rb, ramp)
  local m = G.rell(cx, cy, cos(ang), sin(ang), ra, rb)
  local b = {}
  X.ao(b, m, union, 1, -2)
  local mm = G.leaflet(c, cx, cy, ang, ra, rb, ramp, ltok, b)
  union:add(mm)
  return mm
end
for i = 1, 5 do
  local t = 0.12 + (i - 1) * 0.175
  local x, y = G.bez(rp, t)
  local x2, y2 = G.bez(rp, min(1, t + 0.01))
  local da = atan(y2 - y, x2 - x)
  local sz = 1 - (i - 1) * 0.06
  for _, side in ipairs{ -1, 1 } do
    local a = da + side * 1.05
    local ra, rb = 2.9 * sz, 1.75 * sz
    drawLeaflet(x + cos(a) * (ra + 0.9), y + sin(a) * (ra + 0.9), a, ra, rb, LEAF)
  end
end
do local x, y = G.bez(rp, 1) local x2, y2 = G.bez(rp, 0.97)
  local a = atan(y - y2, x - x2)
  drawLeaflet(x + cos(a) * 2.2, y + sin(a) * 2.2, a, 2.8, 1.75, LEAF) end
-- rachis on top: 1px, lit tone on the upper stretch
for i = 0, 60 do local x, y = G.bez(rp, i / 60)
  c:put(floor(x + 0.5), floor(y + 0.5), i < 50 and RACH or LEAF[4], ltok) end

-- pod: long slim three-angled drumstick
local pp = { { 16, 53 }, { 25, 40 }, { 37, 25 }, { 51, 10 } }
local LEN = 57
local pm, pn, PT, PS = G.tube(pp, function(t)
  if t < 0.035 then return 1.0 end
  if t > 0.86 then return max(0.35, 2.4 * ((1 - t) / 0.14) ^ 0.8) end
  return 2.25 + 0.5 * cos(2 * pi * (t * LEN / 6.4))
end, 220)
local stalk = HP.mask()
pm:each(function(x, y) if PT[K(x, y)] < 0.035 then stalk:set(x, y) end end)
pm:cut(stalk)
-- pod sits over the sprig: AO on the leaves just above-left of the pod
local pbias = {}
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local ph = (t * LEN / 6.4) % 1
  if abs(ph - 0.5) < 0.07 and s > -0.6 then pbias[k] = -1 end      -- pinch between seeds
end)
local ptok = { r = { name = "pod" } }
local pidx = G.toneN(c, pm, pn, POD, { tok = ptok, bias = pbias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  if t > 0.05 and t < 0.9 then
    if s > -0.5 and s < -0.18 then c:put(x, y, POD[min(6, (pidx[k] or 4) + 1)], ptok) end   -- lit ridge
    if s > 0.2 and s < 0.42 then c:put(x, y, POD[max(1, (pidx[k] or 3) - 1)], ptok) end     -- groove
  end
end)
-- cool reflected light along the lower-right edge
pm:edge():each(function(x, y) local k = K(x, y) if PS[k] > 0.6 and PT[k] > 0.08 and PT[k] < 0.85 then c:put(x, y, "#4f8c7a", ptok) end end)
-- dry brown tip
pm:each(function(x, y) if PT[K(x, y)] > 0.96 then c:put(x, y, STALK[2], ptok) end end)
-- woody stalk
local stok = { r = { name = "stalk" } }
stalk:each(function(x, y) c:put(x, y, PS[K(x, y)] < 0 and STALK[3] or STALK[2], stok) end)
c:put(15, 54, STALK[1], stok) c:put(14, 55, STALK[2], stok)
-- leaves next to the pod get an AO row (contact shadow)
local edgeAO = pm:grow(1):cut(pm)
edgeAO:each(function(x, y) if union:has(x, y) and (x + 0 > 0) then
  local k = K(x, y) local cur = c:get(x, y)
  for i = 2, 6 do if cur == LEAF[i] then c:put(x, y, LEAF[i - 1], ltok) break end end end end)
-- one waxy specular on a bulge (lit side)
do
  local bx, by, best
  local sp = X.spec(pn, 36)
  pm:each(function(x, y) local k = K(x, y)
    if PT[k] > 0.35 and PT[k] < 0.6 and pm:has(x + 1, y) and (not best or sp[k] > best) then best, bx, by = sp[k], x, y end end)
  c:put(bx, by, SPEC, ptok) c:put(bx + 1, by, POD[6], ptok)
end

-- quirk: a yellowed leaflet drifting off
local ytok = { r = { name = "yellow" } }
G.leaflet(c, 37, 48, 0.5, 2.7, 1.7, YEL, ytok)

G.save2(c, NAME)
