-- scorpion-stinger (final, artist D14_3, Sonnet high). The last hand's-length of a scorpion tail, cut off at the base:
-- a slim beaded tail of five barrel segments that taper as they rise and curl, each lit as its own bead (ambient joints,
-- a bright ring, lengthwise keel ridges), a glossy red-brown telson bulb, and a long dark curved barb with a bright
-- edge. The cut end shows a pale hollow ring.
-- quirk: a fat green venom drop hangs from the barb tip on a thread.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_aD14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min, pi = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scorpion-stinger" }

local TAIL  = A.ramp("#c97a2c")
local TELS  = A.ramp("#b0502a")
local BARB  = A.ramp("#4e2c34")
local FLESH = A.ramp("#ecd2a0")
local VEN   = A.ramp("#6cc84a")
local CREAM, SPEC = "#fff4d6", "#ffe9b0"
local tk = { r = { name = "tail" } }

local P = { { 15, 50 }, { 12, 35 }, { 22, 14 }, { 38, 12 } }
local NSEG = 5
local function wfn(t)
  local u = (t * NSEG) % 1
  local bead = .64 + .36 * sin(pi * u) ^ .55
  return (5.1 - 1.8 * t) * bead
end
local m, n, T, S, sm = A.tube(P, wfn, { steps = 260 })

-- cut base: pale hollow ring under the tail (drawn first)
do
  local cx, cy = 15, 50.5
  local ring = c:ellipse(cx, cy, 4.8, 2.2)
  local rn = X.pillow(ring, 2.2, .8)
  A.paint(c, ring, rn, FLESH, { amb = .1, wrap = .4 })
  local hole = c:ellipse(cx, cy + .4, 2.6, 1.0)
  A.fillMask = nil
  hole:each(function(x, y) c:px(x, y, (y == floor(cy + .4) - 1) and "#6a3a3a" or "#2f1a22") end)
  c:px(cx - 1, floor(cy + .4), "#5a2a30")
end

-- the beaded tail
local N = #sm - 1
local vfield, nn = {}, {}
m:each(function(x, y)
  local k = K(x, y)
  local t = T[k]
  local sample = sm[floor(t * N) + 1]
  local u = (t * NSEG) % 1
  local nz = n[k][3]
  local tilt = .55 * cos(pi * u) * (1 - .0)
  local nx, ny, nzz = n[k][1] - sample.tx * tilt * nz, n[k][2] - sample.ty * tilt * nz, nz
  local l = sqrt(nx * nx + ny * ny + nzz * nzz)
  nn[k] = { nx / l, ny / l, nzz / l }
end)
A.paint(c, m, nn, TAIL, { amb = .06, wrap = .22, tok = tk, cuts = { .22, .4, .56, .72, .87 }, adj = function(x, y, i)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local u = (t * NSEG) % 1
  local d = 0
  -- ambient rows at the joints, brighter ring just after
  if u < .12 and t > .02 then d = d - 3 elseif u > .9 and t < .98 then d = d - 1 end
  if u > .2 and u < .34 then d = d + 1 end
  -- keel ridges: dashed lines running along the tail
  if abs(s + .5) < .13 and u > .12 and u < .88 and A.hash(x, y, 4) > .12 then d = d + 1 end
  if abs(s - .42) < .12 and u > .12 and u < .88 and A.hash(x, y, 5) > .12 then d = d - 1 end
  -- granules
  if (x * 3 + y * 5) % 11 == 0 and abs(s) < .8 then d = d - 1 end
  return i + d
end })
-- cool bounce on the lower right edge
local rim = X.rim(nn)
m:edge():each(function(x, y)
  local k = K(x, y)
  if (rim[k] or 0) > .75 and S[k] and S[k] > .7 then c:px(x, y, "#a090c8") end
end)
-- polished streaks on each bead's lit shoulder
for _, t0 in ipairs{ .08, .28, .48, .68 } do
  for tt = t0 + .02, t0 + .13, .008 do
    local sample = sm[floor(tt * N) + 1]
    local w = wfn(tt)
    local x, y = floor(sample.x - sample.px * w * .5 + .5), floor(sample.y - sample.py * w * .5 + .5)
    if m:has(x, y) then c:px(x, y, SPEC) end
  end
end

-- telson bulb at the end of the tail
local last = sm[#sm]
local tcx, tcy = last.x + last.tx * 3.2, last.y + last.ty * 3.2
local bulb = A.rell(tcx, tcy, last.tx, last.ty, 5.2, 4.2)
local bn = X.sphere(tcx - .8, tcy - 1, 5, bulb)
A.paint(c, bulb, bn, TELS, { amb = .06, wrap = .2, cuts = { .22, .4, .56, .72, .87 }, adj = function(x, y, i)
  if (x * 3 + y * 7) % 10 == 0 then return i - 1 end
end })
-- ambient where bulb meets the last segment
for _, p in ipairs(sm) do
  if p.t > .97 then
    for k = -5, 5 do
      local x, y = floor(p.x + p.px * k + .5), floor(p.y + p.py * k + .5)
      if m:has(x, y) and not bulb:has(x, y) and (k + 5) % 3 ~= 0 then c:px(x, y, TAIL[1]) end
    end
  end
end
c:px(floor(tcx - 2), floor(tcy - 2), CREAM) c:px(floor(tcx - 1), floor(tcy - 2), SPEC) c:px(floor(tcx - 2), floor(tcy - 1), SPEC)

-- the barb: long dark curved spike with a bright upper edge
local bx0, by0 = tcx + last.tx * 3.5, tcy + last.ty * 3.5
local B = { { bx0, by0 }, { bx0 + 8, by0 - 1.5 }, { bx0 + 11, by0 + 8.5 }, { bx0 + 5.5, by0 + 16 } }
local bm, bnn, bT, bS, bsm = A.tube(B, function(t) return max(.4, 3.5 * (1 - t) ^ .75 + .3) end, { steps = 200 })
-- keep barb off the bulb interior (bulb drawn on top of the root)
bm:cut(bulb)
A.paint(c, bm, bnn, BARB, { amb = .05, wrap = .15, cuts = { .25, .42, .58, .74, .88 }, adj = function(x, y, i)
  local k = K(x, y)
  if bT[k] and bT[k] < .08 then return i - 1 end
end })
-- bright edge along the lit side of the barb
local tipx, tipy
for _, p in ipairs(bsm) do
  local tt = p.t
  if tt > .12 and tt < .9 then
    local w = p.w
    local x, y = floor(p.x - p.px * w * .55 + .5), floor(p.y - p.py * w * .55 + .5)
    if bm:has(x, y) then c:px(x, y, (tt < .5) and "#f0c8b0" or "#c89080") end
  end
  tipx, tipy = p.x, p.y
end
c:px(floor(B[1][1] + 3.5), floor(B[1][2] - 1), SPEC)

-- venom: a thin thread and a fat glossy drop
local dx, dy = floor(tipx + .5), floor(tipy + .5)
c:px(dx, dy + 1, VEN[3]) c:px(dx, dy + 2, VEN[4]) c:px(dx, dy + 3, VEN[4])
local drop = c:ellipse(dx, dy + 6, 2.3, 2.8)
local dn = X.sphere(dx - .5, dy + 5.5, 2.8, drop)
A.paint(c, drop, dn, VEN, { amb = .06, wrap = .25 })
c:px(dx - 1, dy + 5, CREAM) c:px(dx - 1, dy + 6, "#d8f6b0")
c:px(dx + 1, dy + 8, "#2f8a4a")

A.fin(c, "scorpion-stinger")
