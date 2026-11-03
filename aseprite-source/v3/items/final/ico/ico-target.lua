-- ico-target (final, Opus, aR0_0). Archery butt seen face-on, an arrow struck just off the bullseye.
-- Face: one low-dome normal field toned through five ring ramps (gold bull, red, cream, red, straw rim), each
-- 6-tone, so the light rolls over all rings together; a deep line where the face meets the rim. Straw rim: twisted
-- coil (diagonal grooves + lit strands), cool bounce lower-right. Arrow: 6-tone wood shaft cylinder with grain
-- ticks, a cast shadow on the face below it, a dark punched hole with two paint cracks where it enters, two
-- feather vanes with barb lines and a quill, a cream nock.
-- quirk: a small snail is making its slow way along the top of the rim.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new("ico-target")
local GOLD  = { "#7a3a16", "#b0621c", "#e09422", "#f8c030", "#ffe060", "#fff4a8" }
local RED   = { "#5a1430", "#8e1e38", "#c42e3c", "#e84a44", "#ff7a5e", "#ffb08a" }
local CRM   = { "#8a6a64", "#b89a88", "#dcc4a6", "#efdcbc", "#fbefd2", "#fff8e6" }
local STRAW = { "#6a3e1a", "#94602a", "#bc8838", "#d8a84a", "#ecc868", "#fae08e" }
local WOOD  = { "#3e2418", "#5e3824", "#865234", "#a86e44", "#c88e5a", "#e6b47c" }
local FEA   = { "#4e1a3a", "#7d2c5e", "#b8406e", "#e2688a", "#ff9ab4", "#ffd0dc" }
local BOUNCE, SPEC = "#8a8ab8", "#fff4d6"
local CX, CY, R = 29.5, 33.5, 20.5
local RINGS = { { 4.6, GOLD, "g" }, { 8.6, RED, "r1" }, { 12.6, CRM, "c1" }, { 16.4, RED, "r2" }, { 99, STRAW, "s" } }

local disc = HP.mask()
for y = 0, 63 do for x = 0, 63 do if (x + 0.5 - CX) ^ 2 + (y + 0.5 - CY) ^ 2 <= R * R then disc:set(x, y) end end end
local dn = A.dome(disc, CX - 0.5, CY - 0.5, R, 7, 0.6)
local v = X.light(dn, { amb = 0.06, wrap = 0.15 })
local toks, RID, RD = {}, {}, {}
for i, r in ipairs(RINGS) do toks[i] = { r = { name = r[3] } } end
local idx = {}
disc:each(function(x, y) local k = K(x, y)
  local d = sqrt((x + 0.5 - CX) ^ 2 + (y + 0.5 - CY) ^ 2)
  local ri = 5 for i, r in ipairs(RINGS) do if d < r[1] then ri = i break end end
  RID[k], RD[k] = ri, d
  local val = v[k]
  local cuts = A.CUTS
  local j = 1 for q, t in ipairs(cuts) do if val >= t then j = q + 1 end end
  if ri == 5 and d < 17.4 then j = j - 2 end                   -- deep line where face meets the rim
  idx[k] = max(1, min(6, j))
end)
-- straw coil: diagonal grooves running round the rim, lit strand tops
disc:each(function(x, y) local k = K(x, y)
  if RID[k] == 5 then
    local a = atan(y + 0.5 - CY, x + 0.5 - CX)
    local ph = (a * R / 2.6 + (RD[k] - 17) * 0.9) % 1
    if ph < 0.25 then idx[k] = max(1, idx[k] - 2) elseif ph < 0.5 and idx[k] >= 3 then idx[k] = min(6, idx[k] + 1) end
  end
end)

-- arrow geometry (needed for the cast shadow before painting)
local HX, HY = 33.5, 30.0     -- entry point
local EX, EY = 53.5, 10.0     -- nock end
local am, an, AT, AS = X.cyl(HX, HY, EX, EY, function(t) return 1.15 end)
local shadow = am:shift(1, 2)
shadow:each(function(x, y) local k = K(x, y) if idx[k] and not am:has(x, y) then idx[k] = max(1, idx[k] - 2) end end)
-- punched hole + paint cracks
local hole = { { 33, 30, 1 }, { 34, 30, 1 }, { 33, 31, 1 }, { 32, 31, 2 }, { 34, 31, 2 }, { 33, 32, 2 } }
for _, h in ipairs(hole) do local k = K(h[1], h[2]) if idx[k] then idx[k] = h[3] end end
for _, p in ipairs({ { 31, 33 }, { 30, 34 }, { 36, 32 }, { 37, 33 } }) do local k = K(p[1], p[2]) if idx[k] then idx[k] = max(1, idx[k] - 2) end end

for k, i in pairs(idx) do local x, y = k % 1024 - 256, k // 1024 - 256
  local ri = RID[k] c:put(x, y, RINGS[ri][2][i], toks[ri]) end
-- bounce on the rim lower-right, glint upper-left of the bull
disc:edge():each(function(x, y) local k = K(x, y)
  if (x + 0.5 - CX) + (y + 0.5 - CY) > 17 then c:put(x, y, BOUNCE, toks[5]) end end)
c:put(27, 31, GOLD[6], toks[1]) c:put(28, 31, SPEC, toks[1])
c:put(20, 22, CRM[6], toks[3])

-- arrow shaft (only outside the entry)
local atok = { r = { name = "shaft" } }
local aidx = A.shade(c, am, an, WOOD, { amb = 0.14, wrap = 0.3, tok = atok })
am:each(function(x, y) local k = K(x, y) if AT[k] > 0.2 and AT[k] < 0.62 and (x * 3 + y) % 7 == 0 then A.step(c, aidx, WOOD, x, y, -1, atok) end end)
-- fletching: two vanes near the nock
local ftok = { r = { name = "fea" } }
local function vane(sx, sy, ex, ey, ox, oy)
  local wfn = function(t) if t > 0.98 then return -1 end return max(0.5, 2.4 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6) end
  local m, n, T, S = A.blade(sx, sy, (sx + ex) / 2 + ox, (sy + ey) / 2 + oy, ex, ey, wfn, { fold = 0.3 })
  m:cut(am)
  local fi = A.shade(c, m, n, FEA, { amb = 0.16, wrap = 0.3, tok = ftok })
  m:each(function(x, y) local k = K(x, y) if (x - y) % 3 == 0 and abs(S[k]) > 0.3 then A.step(c, fi, FEA, x, y, -1, ftok) end end)
  return m
end
local v1 = vane(45.5, 18.0, 52.0, 11.5, -3.2, -3.2)
local v2 = vane(45.5, 18.0, 52.0, 11.5, 3.2, 3.2)
-- quill line over the vanes, cream nock at the end
for t = 0.58, 0.92, 0.02 do local x, y = floor(HX + (EX - HX) * t + .5), floor(HY + (EY - HY) * t + .5) c:put(x, y, WOOD[5], atok) end
A.map(c, { "ab", "bc" }, 53, 9, { a = SPEC, b = CRM[4], c = CRM[2] }, { r = { name = "nock" } })

-- quirk: snail on the top of the rim
local SN = {
  "...SSSS.......",
  "..SddhhS......",
  ".SdSSSShS..e.e",
  ".SdSddSdS..e.e",
  ".SdSSdSdS..bb.",
  "..SddddS..bbb.",
  "bbbbbbbbbbbbb.",
  ".BBBBBBBBBBB..",
}
A.map(c, SN, 21, 5, { S = "#7d2c5e", d = "#f5809f", h = "#ffc4d8", b = "#d2c890", B = "#8e8a52", e = "#5a5a34" }, { r = { name = "snail" } })

A.save(c, "ico-target")
