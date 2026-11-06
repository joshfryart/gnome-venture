-- broken-walking-stick (aB12_5, Opus single pass). Slim ash walking stick on the diagonal: polished round knob,
-- brass collar, gently bowed shaft (4 px) with grain dashes and a knot, brass ferrule at the foot.
-- Material: per-pixel cylinder/sphere light (6-tone wood, 6-tone brass), grain lines, specular on the knob and
-- collar, AO where collar meets knob and shaft. broken: snapped clean through mid-shaft, the lower half knocked
-- askew, pale end grain + splinter spikes on both ends; two flying splinters.
-- quirk: a tiny toadstool has sprouted from the shaft.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("broken-walking-stick")
local Wd, B = A.WOOD, A.GOLD

-- shaft
local p = { { 44, 18 }, { 38, 26 }, { 31, 36 }, { 21, 50 } }
local sm, sn, ST, SS, samp, LEN = A.tube(p, function(t) return 1.85 - t * 0.25 end)
local bias = {}
sm:each(function(x, y) local k = K(x, y)
  -- grain: dashed darker lines running along the shaft
  local s, t = SS[k], ST[k]
  local seg = floor(t * LEN / 3)
  if (abs(s + 0.4) < 0.17 and X.hash(seg, 1) > 0.3) or (abs(s - 0.35) < 0.17 and X.hash(seg, 2) > 0.45) then bias[k] = -1 end
end)
local sidx = A.tone(c, sm, sn, Wd, { bias = bias })
-- knot
local kx, ky = A.bez(p, 0.72)
c:px(floor(kx), floor(ky), Wd[1]) c:px(floor(kx) + 1, floor(ky), Wd[2]) c:px(floor(kx), floor(ky) - 1, Wd[5])
-- ferrule (brass) over the last stretch
sm:each(function(x, y) local k = K(x, y)
  if ST[k] > 0.92 then
    local s = SS[k]
    local i = s < -0.5 and 5 or s < -0.1 and 4 or s < 0.4 and 3 or 2
    if ST[k] > 0.985 then i = max(1, i - 1) end
    c:px(x, y, B[i])
  elseif ST[k] > 0.905 then c:px(x, y, Wd[1]) end
end)
-- collar ring
local cm, cn = A.tube({ { 46.5, 14.5 }, { 45.8, 15.5 }, { 45.2, 16.4 }, { 44.5, 17.5 } }, function() return 2.6 end)
local cb = {}
A.tone(c, cm, cn, B, { bias = cb })
-- knob
local km, kn = A.sphere(c, 48.5, 11.5, 4.5, A.DWOOD, { cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 } })
c:px(46, 9, A.SPEC) c:px(47, 9, Wd[6]) c:px(46, 10, Wd[6])
-- AO: knob shadow onto collar
cm:each(function(x, y) if km:grow(1):has(x, y) and not km:has(x, y) then A.step(c, x, y, B, -1) end end)

-- quirk: tiny toadstool on the lit side of the shaft (upper half)
local tx, ty = A.bez(p, 0.3)
tx, ty = floor(tx) - 4, floor(ty) - 4
A.rows(c, {
  ".rRr.",
  "rRcRr",
  "dr.rd",
  "..s..",
  "..ss.",
}, tx, ty, { r = "#e8493b", R = "#ff8a5c", c = "#fff4d6", d = "#b52e3f", s = "#f2e2c4" })

-- broken: snap at t ~ 0.52 with a jagged line; lower half knocked down-left
local function cut(k) return 0.52 + 0.045 * sin(SS[k] * 6.5) end
local low, gap = HP.mask(), HP.mask()
sm:each(function(x, y) local k = K(x, y)
  local d = ST[k] - cut(k)
  if d > 0.02 then low:set(x, y) elseif d > -0.02 then gap:set(x, y) end
end)
A.clearMask(c, gap)
A.move(c, low, 2, 5)
-- end grain + splinters on both broken ends
local EG = { "#ebbd86", "#f6d6a6" }
local ux, uy = samp[90].tx, samp[90].ty
for _, side in ipairs{ -1, 1 } do
  local base = side < 0 and 0.497 or 0.543
  local sx, sy = A.bez(p, base)
  if side > 0 then sx, sy = sx + 2, sy + 5 end
  for j = -1, 1 do
    local px, py = floor(sx + samp[90].px * j * 1.4 + .5), floor(sy + samp[90].py * j * 1.4 + .5)
    if c:get(px, py) then c:px(px, py, j < 0 and EG[2] or EG[1]) end
  end
  -- splinter spikes poking out along the axis
  local dir = side < 0 and 1 or -1
  local s1x, s1y = floor(sx + ux * dir * 2 + samp[90].px * -1 + .5), floor(sy + uy * dir * 2 + samp[90].py * -1 + .5)
  c:px(s1x, s1y, Wd[5])
  c:px(floor(sx + ux * dir * 1.2 + samp[90].px * 1 + .5), floor(sy + uy * dir * 1.2 + samp[90].py * 1 + .5), Wd[3])
end
-- flying splinters
A.rows(c, { "ab..", ".bcd" }, 22, 31, { a = Wd[6], b = Wd[5], c = Wd[3], d = Wd[2] })
A.rows(c, { "..a", ".bc", "dc." }, 41, 32, { a = EG[2], b = Wd[5], c = Wd[3], d = Wd[2] })

A.save(c)
