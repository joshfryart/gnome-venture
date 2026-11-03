-- badger-claw (pass B, final; pass A = badger-claw.pA). One long, slim digging claw, side-on, gently arched,
-- dark sepia root -> pale horn tip (one 9-step keratin ramp: light index + a shift along the length).
-- Realism: swept section with a tall dorsal keel and a thin ventral side (asymmetric widths), per-pixel light,
-- growth striations along the curve, ventral groove, broken specular streak on the keel + one sparkle,
-- cool bounce on the ventral edge, open root cut square with a dark sheath slot and a pale cut lip.
-- Pass B: re-cut silhouette (claw profile instead of a round horn: keel + thin underside, sharper tip, square root),
-- consistent dorsal/ventral sides along the whole curve, striations + groove visible, tuft redrawn as hair strands.
-- quirk: a lock of badger hair (banded guard hairs: pale base, black, white tips) still caught in the root.
local NAME = "badger-claw"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

local KER = { "#2a1c26", "#3d2830", "#553739", "#714d42", "#906850", "#b08762", "#cfa97b", "#e8cd9c", "#f8eed2" }
local SPEC, BOUNCE = "#fffaea", "#9a9cc6"
local HAIRW = { "#b9b2b0", "#ece6dc", "#fff6ea" }
local HAIRK = { "#2f2a36", "#4a4352", "#655d6c" }

-- centreline bezier, root -> tip
local P = { {18, 17}, {33, 12}, {48, 25}, {52, 52} }
local function bez(t)
  local u = 1 - t
  return u^3*P[1][1] + 3*u*u*t*P[2][1] + 3*u*t*t*P[3][1] + t^3*P[4][1],
         u^3*P[1][2] + 3*u*u*t*P[2][2] + 3*u*t*t*P[3][2] + t^3*P[4][2]
end
local function wd(t) return 0.4 + 6.2 * (1 - t) ^ 1.05 end    -- dorsal (outer) half-width: tall keel
local function wv(t) return 0.3 + 4.4 * (1 - t) ^ 1.4 end      -- ventral (inner) half-width: thin
local S = {}
for i = 0, 500 do local t = i / 500 local x, y = bez(t) S[#S + 1] = { x, y, t } end
local m, T, SN, n = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local best, bi = 1e9, 1
  for i, p in ipairs(S) do local d = (p[1] - x) ^ 2 + (p[2] - y) ^ 2 if d < best then best, bi = d, i end end
  local p = S[bi]
  local t = p[3]
  local q, o = S[min(#S, bi + 1)], S[max(1, bi - 1)]
  local tx, ty = q[1] - o[1], q[2] - o[2]
  local tl = sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
  local px, py = -ty, tx                                 -- +s = ventral (inner side of the arch)
  local sd = (x - p[1]) * px + (y - p[2]) * py
  local along = (x - p[1]) * tx + (y - p[2]) * ty
  local w = sd < 0 and wd(t) or wv(t)
  if abs(sd) <= w and t < 0.996 and not (bi == 1 and along < -0.4) then
    m:set(x, y)
    local k = K(x, y)
    local s = sd / (w + 0.5)
    local sn = max(-0.96, min(0.96, s))
    n[k] = { px * sn, py * sn, sqrt(1 - sn * sn) }
    T[k], SN[k] = t, s
  end
end end
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local cuts = { 0.2, 0.38, 0.55, 0.71, 0.86 }
local idx = {}
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], SN[k]
  local i = 1
  for j, cu in ipairs(cuts) do if v[k] >= cu then i = j + 1 end end
  -- growth striations (constant s on the dorsal side), broken into long dashes
  for gi, g in ipairs{ -0.62, -0.25 } do
    if abs(s - g) < 0.13 and t > 0.08 and t < 0.8 and X.hash(floor(t * 30), gi, 3) > 0.35 then i = i - 1 end
  end
  if s > 0.3 and s < 0.62 and t > 0.1 and t < 0.75 then i = i - 1 end   -- ventral groove
  local tt = t + (X.hash(x, y, 7) - 0.5) * 0.07
  local sh = floor(min(1, tt / 0.78) * 3.99)
  i = max(1, min(6, i))
  idx[k] = i + sh
  c:put(x, y, KER[max(1, min(9, i + sh))])
end)
-- specular streak on the keel crest, broken in two; sparkle at the bend
m:each(function(x, y)
  local k = K(x, y) local t, s = T[k], SN[k]
  if s > -0.82 and s < -0.58 and ((t > 0.16 and t < 0.3) or (t > 0.36 and t < 0.58)) then
    c:put(x, y, (t > 0.44 and t < 0.5) and SPEC or KER[min(9, idx[k] + 2)])
  end
end)
-- cool reflected light on the ventral edge
m:edge():each(function(x, y) local k = K(x, y) if SN[k] > 0.55 and T[k] > 0.2 and T[k] < 0.88 then c:put(x, y, BOUNCE) end end)

-- open root: cut square; pale cut lip + dark sheath slot
m:each(function(x, y)
  local k = K(x, y)
  if T[k] < 0.018 then c:put(x, y, KER[5]) end
  if T[k] < 0.045 and T[k] >= 0.018 and SN[k] > -0.55 and SN[k] < 0.5 then c:put(x, y, KER[1]) end
end)

-- quirk: lock of badger hair caught in the root. strands fan out to the left
-- the lock is one soft teardrop mask fanning out left of the root, banded along the flow, strand lines across
local LX, LY = 0, -5
local lp = { {17,17},{14,16},{11,15},{7,14},{9,17},{6,19},{10,20},{7,23},{5,26},{10,25},{13,24},{17,25} }
for _, q in ipairs(lp) do q[1], q[2] = q[1] + LX, q[2] + LY end
local lock = c:poly(lp)
lock:cut(m)
local AXX, AXY = 0.42, 0.91                                    -- across-lock direction (perp. to the hair flow)
lock:each(function(x, y)
  local a = (x - 12 - LX) * AXX + (y - 21 - LY) * AXY          -- across the lock: -5 (top) .. +5 (bottom)
  local u = x - LX                                              -- along the flow: 17 at the root .. 6 at the tips
  -- badger guard hairs are banded: pale base, black middle, white tips (bands run across the lock)
  local band = u >= 15 and 1 or u >= 11 and 2 or 3
  local ramp = band == 2 and HAIRK or HAIRW
  local i = 2
  if floor(a * 1.4) % 2 == 0 then i = 1 end                      -- strand lines along the flow
  if a < -2.8 then i = 3 end                                     -- lit upper edge
  if band == 1 then i = 1 end                                    -- base sits in the root's shadow
  c:put(x, y, ramp[i])
end)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
