-- candied-citrus-peel (final pass, Opus). A slim bundle of three candied peel strips (orange, lemon, orange) fanning
-- out from a twine tie: each strip is a flat, gently curved ribbon (6 tones, flattened ribbon light), with pale pith
-- showing along its shade edge, zest pores and a crust of sugar crystals. The twine has a visible twist and a loose
-- tail; AO and contact shadow where it crosses the strips and where strips overlap.
-- quirk: the right strip's tip has been dipped in dark chocolate, one drip still sliding down.
local NAME = "candied-citrus-peel"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)

local ORA = { "#6e2230", "#a8382c", "#d85a24", "#f2842a", "#ffae48", "#ffd888" }
local LEM = { "#5a4232", "#93742a", "#c89c1e", "#e8c430", "#f6e060", "#fff2a6" }
local PITH = { "#d8b884", "#f0dcae", "#fff0cc" }
local CHOC = { "#22121a", "#381e20", "#563024", "#784632", "#a06a4c" }
local TW = { "#5a3a2a", "#86603e", "#b88e5a", "#dcbc84", "#f2deae" }

-- strips: bezier ctrl pts, ramp, half width
local strips = {
  { p = { { 30, 54 }, { 25, 43 }, { 13, 32 }, { 14, 15 } }, r = ORA, w = 2.4 },
  { p = { { 36, 54 }, { 41, 43 }, { 51, 33 }, { 50, 17 } }, r = ORA, w = 2.4, choc = true },
  { p = { { 33, 55 }, { 34, 41 }, { 29, 27 }, { 33, 11 } }, r = LEM, w = 2.3 },
}
for _, s in ipairs(strips) do
  s.m, s.n, s.T, s.S = A.tube(s.p, function(t) return s.w * (t > 0.94 and 0.8 or 1) end)
  -- flatten into a ribbon: keep a weak cross curvature
  for k, nn in pairs(s.n) do local sn = s.S[k] s.n[k] = { A.norm(nn[1] * 0.45, nn[2] * 0.45, 1) } end
end
-- twine tie across the bundle
local tw, twn, TT, TS = A.tube({ { 26, 47 }, { 30, 46 }, { 36, 46 }, { 40, 48 } }, function(t) return 1.0 end)
local tail, tailn = A.tube({ { 40, 48 }, { 43, 49 }, { 43, 53 }, { 46, 55 } }, function(t) return 0.85 * (1 - t * 0.3) end)

for i, s in ipairs(strips) do
  local tok = { r = { name = "strip" .. i } }
  local b = {}
  for j = i + 1, #strips do X.ao(b, s.m, strips[j].m, 1, -1) A.cast(b, s.m, strips[j].m, 1, 1, -1) end
  X.ao(b, s.m, tw, 1, -1) A.cast(b, s.m, tw, 0, 1, -1)
  local vis = s.m:copy()
  for j = i + 1, #strips do vis:cut(strips[j].m) end
  local idx = A.shade(c, vis, s.n, s.r, { tok = tok, bias = b, cuts = { 0.3, 0.45, 0.6, 0.74, 0.88 }, amb = 0.15, wrap = 0.35 })
  vis:each(function(x, y) local k = K(x, y)
    local S, T = s.S[k], s.T[k]
    -- pith along the shade edge
    if S > 0.62 then c:put(x, y, b[k] and PITH[1] or PITH[2], tok) return end
    -- sugar crystals (sparse, bright on the lit side) and zest pores
    local h = X.hash(x, y, i)
    if h > 0.84 and not b[k] then c:put(x, y, S < 0.1 and A.CREAM or PITH[3], tok)
    elseif h < 0.07 and T > 0.05 then c:put(x, y, s.r[max(1, (idx[k] or 3) - 1)], tok) end
  end)
  -- one wet glint per strip on the lit edge
  local best, bx, by
  vis:each(function(x, y) local k = K(x, y)
    if s.T[k] > 0.55 and s.T[k] < 0.75 and s.S[k] < -0.5 and not b[k] then
      if not best or y < by then best, bx, by = true, x, y end end end)
  if bx then c:put(bx, by, s.r[6], tok) if vis:has(bx, by + 1) then c:put(bx, by + 1, s.r[6], tok) end end
  -- quirk: chocolate-dipped tip
  if s.choc then
    local ctok = { r = { name = "choc" } }
    local cm = HP.mask()
    s.m:each(function(x, y) local k = K(x, y) local S = s.S[k]
      local edge = 0.78 - S * 0.04 + ((x % 2 == 0) and 0.015 or 0)
      if s.T[k] > edge then cm:set(x, y) end end)
    cm:clip(vis)
    A.shade(c, cm, s.n, CHOC, { tok = ctok, cuts = { 0.38, 0.55, 0.72, 0.86 }, amb = 0.15, wrap = 0.35 })
    -- dipped edge: one darker row; drip running down the shade edge
    local dr = { { 50, 28 }, { 50, 29 }, { 50, 30 } }
    for _, p in ipairs(dr) do c:put(p[1], p[2], CHOC[3], ctok) end
    c:put(50, 31, CHOC[2], ctok)
    local gx, gy = A.glint(c, cm, s.n, CHOC[5], 30, ctok)
  end
end

-- twine: twisted strands
local ttok = { r = { name = "twine" } }
local tidx = A.shade(c, tw, twn, TW, { tok = ttok, cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.12, wrap = 0.3 })
tw:each(function(x, y) local k = K(x, y)
  if (x + floor((TS[k] + 1) * 1.2)) % 3 == 0 then c:put(x, y, TW[max(1, (tidx[k] or 3) - 1)], ttok) end end)
tail:cut(tw)
local tlidx = A.shade(c, tail, tailn, TW, { tok = ttok, cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.12, wrap = 0.3 })
tail:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, TW[2], ttok) end end)
c:put(47, 56, TW[4], ttok)   -- frayed end

A.done(c, NAME)
