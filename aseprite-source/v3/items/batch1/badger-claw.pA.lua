-- badger-claw (pass A). One long, slim digging claw, side-on: dark sepia root -> pale horn tip, gently arched.
-- Realism: swept-tube normals (dorsal keel lit, ventral side cool bounce), growth striations along the curve,
-- broken specular streak on the keel, open hollow root showing the dark sheath inside.
-- quirk: a little tuft of badger hair (white-black-white stripe) still stuck in the root.
local NAME = "badger-claw.pA"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

-- one long keratin ramp: tone index + a shift along the length (root dark sepia -> tip pale horn)
local KER = { "#2a1c26", "#3d2830", "#4c3236", "#684840", "#87614c", "#a87f5e", "#c9a377", "#e3c798", "#f6ecd0" }
local SPEC, BOUNCE = "#fff8e6", "#8a8fb8"
local INK, CREAM = "#2b1c26", "#fff4d6"

-- centreline bezier, base -> tip
local P = { {16, 22}, {33, 11}, {49, 20}, {53, 53} }
local function bez(t)
  local u = 1 - t
  return u^3*P[1][1] + 3*u*u*t*P[2][1] + 3*u*t*t*P[3][1] + t^3*P[4][1],
         u^3*P[1][2] + 3*u*u*t*P[2][2] + 3*u*t*t*P[3][2] + t^3*P[4][2]
end
local function wfn(t) return 0.5 + 5.2 * (1 - t) ^ 1.15 end
local S = {}
for i = 0, 400 do local t = i / 400 local x, y = bez(t) S[#S + 1] = { x, y, t } end
local m, T, SN, n = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local best, bi = 1e9, 1
  for i, p in ipairs(S) do local d = (p[1] - x) ^ 2 + (p[2] - y) ^ 2 if d < best then best, bi = d, i end end
  local p = S[bi]
  local t = p[3]
  local w = wfn(t)
  if sqrt(best) <= w and t < 0.995 and (bi > 1 or true) then
    local q = S[min(#S, bi + 1)] local o = S[max(1, bi - 1)]
    local tx, ty = q[1] - o[1], q[2] - o[2]
    local tl = sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end           -- +s = lower-right (ventral/shade)
    local s = ((x - p[1]) * px + (y - p[2]) * py) / (w + 0.5)
    -- base end: only keep pixels in front of the start (rounded root)
    local along = (x - p[1]) * tx + (y - p[2]) * ty
    if not (bi == 1 and along < -0.5) then
      m:set(x, y)
      local k = K(x, y)
      local sn = max(-0.96, min(0.96, s))
      -- keel: compressed section, dorsal ridge sits at s = -0.35
      local nz = sqrt(1 - sn * sn)
      n[k] = { px * sn, py * sn, nz }
      T[k], SN[k] = t, s
    end
  end
end end
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], SN[k]
  local i = 1
  for j, cu in ipairs(cuts) do if v[k] >= cu then i = j + 1 end end
  -- growth striations along the length (constant s), broken
  for _, g in ipairs{ -0.15, 0.4 } do
    if abs(s - g) < 0.12 and t > 0.12 and t < 0.85 and X.hash(floor(t * 60), 0, 3) > 0.3 then i = i - 1 end
  end
  local tt = t + (X.hash(x, y, 7) - 0.5) * 0.08
  local sh = floor(min(1, tt / 0.8) * 3.99)
  c:put(x, y, KER[max(1, min(9, max(1, min(6, i)) + sh))])
end)
-- specular streak along the keel, broken in two
m:each(function(x, y)
  local k = K(x, y) local t, s = T[k], SN[k]
  if s > -0.62 and s < -0.38 and ((t > 0.2 and t < 0.36) or (t > 0.42 and t < 0.6)) then
    c:put(x, y, (t > 0.48 and t < 0.54) and SPEC or KER[8])
  end
end)
-- cool reflected light on the ventral edge
m:edge():each(function(x, y) local k = K(x, y) if SN[k] > 0.7 and T[k] > 0.25 and T[k] < 0.9 then c:put(x, y, BOUNCE) end end)

-- open root: hollow ellipse at the base end
local bx, by = bez(0)
local hol = c:ellipse(bx - 3, by, 1, 3):clip(m)
c:fillMask(c:ellipse(bx - 2, by, 1, 4):clip(m):cut(hol), KER[6])
c:fillMask(hol, KER[1])

-- quirk: badger hair tuft (white / black / white strands) coming out of the root
c:paint({
  "aa.........",
  "..aaa......",
  "c....aaa...",
  ".bbbb...a..",
  "c....bbbbb.",
  ".bbbb...b..",
  "a....aaa...",
  "..aaa......",
  "aa.........",
}, 3, 18, { a = "#ece6dc", b = "#4a4352", c = "#6d6577" })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
