-- earwig-pincer (final, Opus single pass). The earwig's forceps: two slim curved cerci rising from the last
-- abdominal plate and hooking in toward each other, like a pair of calipers.
-- Material: glossy chestnut chitin (6 tones), per-pixel tube light, specular streak along each lit edge,
-- small inner teeth near the base, darker tips, AO where the cerci root into the plate, plate bevel + segment groove.
-- quirk: a loose red thread is snagged round the right cercus.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local NAME = "earwig-pincer"
local c = A.new(NAME)
local CH = { "#2a1520", "#4c2129", "#783326", "#a44f2c", "#cd7a3c", "#f0b26e" }
local PL = { "#2a1520", "#45202a", "#6a2e2a", "#8f4430", "#b8653c", "#dc9a5e" }
local SPEC = "#fff0d0"
local tok = { r = { name = "cerci" } }
local ptok = { r = { name = "plate" } }

local function hw(t) return 2.9 * ((1 - t) ^ 0.75) + 0.35 end
local cerci = {
  { { 28, 46 }, { 15, 36 }, { 13, 15 }, { 25, 13 } },
  { { 36, 46 }, { 49, 36 }, { 51, 15 }, { 39, 13 } },
}
-- base plate (last tergite) and the stub segment below it
local plate = A.oval(32, 48, 8.5, 4.4, 0, 0.6)
local pm, pn = A.oval(32, 48, 8.5, 4.4, 0, 0.6)
local sm, sn = A.oval(32, 54.5, 5.5, 3.2, 0, 0.6)
local all = HP.mask()
for side, p in ipairs(cerci) do
  local m, n, T, S, samp = A.tube(p, hw, 160)
  -- inner teeth: 1 px bumps toward the centre line on the lower half
  for _, tt in ipairs{ 0.2, 0.3, 0.4 } do
    local s = samp[floor(tt * 160) + 1]
    local sg = ((s.x + s.px) - s.x) * (32 - s.x) > 0 and 1 or -1
    local w = s.w + 0.9
    local x, y = floor(s.x + s.px * w * sg + .5), floor(s.y + s.py * w * sg + .5)
    if not m:has(x, y) then m:set(x, y) n[K(x, y)] = { s.px * sg * 0.8, s.py * sg * 0.8, 0.6 } T[K(x, y)] = tt S[K(x, y)] = sg * 0.95 end
  end
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.82 then bias[k] = -1 end end)
  X.ao(bias, m, pm, 2, -1)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  local idx = X.tone(c, m, v, CH, { cuts = A.CUTS, bias = bias, tok = tok })
  -- specular streak on the lit edge (glossy chitin), brightest at mid-shaft
  for i = floor(0.18 * 160), floor(0.62 * 160) do
    local s = samp[i + 1]
    local f = side == 1 and -0.45 or -0.4
    local x, y = floor(s.x + s.px * s.w * f + .5), floor(s.y + s.py * s.w * f + .5)
    if m:has(x, y) and (idx[K(x, y)] or 0) >= 3 then c:put(x, y, CH[6], tok) end
  end
  if side == 1 then local s = samp[floor(0.42 * 160) + 1]
    c:put(floor(s.x - s.px * s.w * 0.45 + .5), floor(s.y - s.py * s.w * 0.45 + .5), SPEC, tok) end
  -- cool bounce on the shade edge
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.75 and S[k] > 0.7 and T[k] > 0.12 and T[k] < 0.7 then c:put(x, y, "#6a4a78", tok) end end)
  all:add(m)
end
-- stub segment then plate on top
do
  local bias = {}
  A.cast(bias, sm, pm, 0, 1, -1)
  local v = X.light(sn, { amb = 0.06, wrap = 0.2 })
  X.tone(c, sm, v, PL, { cuts = A.CUTS, bias = bias, tok = ptok })
  sm:each(function(x, y) if y == 55 and (x % 3 == 0) then c:put(x, y, PL[2], ptok) end end)
end
do
  local bias = {}
  local v = X.light(pn, { amb = 0.08, wrap = 0.25 })
  local idx = X.tone(c, pm, v, PL, { cuts = A.CUTS, bias = bias, tok = ptok })
  -- bevel: lit rim along the top edge, segment groove across with a lit lip under it
  pm:each(function(x, y)
    if not pm:has(x, y - 1) and x < 36 then c:put(x, y, PL[6], ptok) end
    if y == 49 and pm:has(x - 1, y) and pm:has(x + 1, y) then c:put(x, y, PL[2], ptok) end
    if y == 50 and pm:has(x, y + 1) and x < 34 and pm:has(x - 1, y) then c:put(x, y, PL[5], ptok) end
  end)
  c:put(28, 46, SPEC, ptok) c:put(29, 46, PL[6], ptok)
end
-- quirk: a loose red thread snagged round the right cercus, one end dangling
do
  local TH = { "#e8493b", "#b52e3f", "#ff8a5c" }
  local pts = { { 47, 30 }, { 48, 30 }, { 49, 29 }, { 50, 29 }, { 51, 30 }, { 52, 31 }, { 52, 32 }, { 53, 33 }, { 53, 34 } }
  for i, q in ipairs(pts) do c:put(q[1], q[2], i <= 4 and (i % 2 == 0 and TH[3] or TH[1]) or (i % 2 == 0 and TH[2] or TH[1])) end
  c:put(46, 31, TH[2])
end
A.save(c, NAME)
