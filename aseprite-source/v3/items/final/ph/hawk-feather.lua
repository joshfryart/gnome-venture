-- hawk-feather (aC11_2 final, Opus single pass). Slim flight feather on the diagonal, quill lower-left, tip
-- upper-right, gentle S curve. Narrow leading vane (upper-left), wider trailing vane (lower-right), rounded tip with a
-- pale cream tip band. Russet vane with dark chevron bars, fine barb lines angled toward the tip, one split in the
-- trailing vane, soft downy afterfeather at the base, bare horn quill (calamus) with a hard specular.
-- Light: flattened cylinder normals (6 tones), shaft = cream ridge with a shade line, AO where vane meets shaft.
-- quirk: a single dewdrop sits on the trailing vane (glass: bright rim, pale core, sparkle).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.pi, math.sqrt
local c = A.new("hawk-feather")

local VANE = { "#4a2224", "#77352a", "#a14e2e", "#c46a36", "#de8c4c", "#f0b47a" }
local BAR  = { "#2e1820", "#45242a", "#5e3230", "#764636" }
local TIP  = { "#b7a08a", "#e6d2b4", "#fbecd0" }
local DOWN = { "#8f7c78", "#bfaea2", "#e4d8c8" }
local QUILL = { "#7a6650", "#b8a07c", "#e2d0a8", "#fbf0d4" }
local DROP = { "#3a86b0", "#8fd0e0", "#d8f6f4" }
local vtok, stok, dtok, qtok = A.tok("vane"), A.tok("shaft"), A.tok("down"), A.tok("drop")

-- shaft path (bezier), quill at p1, tip at p4
local P = { { 13, 54 }, { 22, 40 }, { 34, 26 }, { 51, 10 } }
local N = 200
local sm = {}
for i = 0, N do
  local t = i / N
  local x, y = A.bez(P, t)
  local x2, y2 = A.bez(P, min(1, t + 0.003))
  local x1, y1 = A.bez(P, max(0, t - 0.003))
  local tx, ty = x2 - x1, y2 - y1
  local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  if px + py < 0 then px, py = -px, -py end              -- +side = lower-right (trailing vane)
  sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py }
end
local LEN = 0
for i = 2, #sm do LEN = LEN + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end

-- vane widths per side (t from quill); vane starts at t0
local T0 = 0.2
local function wTrail(t)
  if t < T0 then return -1 end
  local u = (t - T0) / (1 - T0)
  local w = 5.6 * math.min(1, (u / 0.18)) ^ 0.6
  if u > 0.78 then w = w * sqrt(max(0, 1 - ((u - 0.78) / 0.22) ^ 2)) end
  return w
end
local function wLead(t)
  if t < T0 + 0.03 then return -1 end
  local u = (t - T0) / (1 - T0)
  local w = 3.0 * math.min(1, (u / 0.2)) ^ 0.7
  if u > 0.75 then w = w * sqrt(max(0, 1 - ((u - 0.75) / 0.25) ^ 2)) end
  return w
end

local vm, sd, TT = HP.mask(), {}, {}
for y = 2, 62 do for x = 2, 62 do
  local best, bs
  for _, s in ipairs(sm) do
    local q = (x - s.x)^2 + (y - s.y)^2
    if not best or q < best then best, bs = q, s end
  end
  local d = (x - bs.x) * bs.px + (y - bs.y) * bs.py
  local along = abs((x - bs.x) * -bs.py + (y - bs.y) * bs.px)
  local w = d >= 0 and wTrail(bs.t) or wLead(bs.t)
  if along < 0.75 and w > 0 and abs(d) <= w + 0.15 then
    vm:set(x, y) sd[K(x, y)] = d TT[K(x, y)] = bs.t
  end
end end

-- barb coordinate: distance along the shaft, swept back toward the quill away from the shaft
local function barb(k) return TT[k] * LEN - abs(sd[k]) * 0.9 end
-- split in the trailing vane
local SPLIT = 0.6 * LEN
vm:each(function(x, y) local k = K(x, y)
  local b = barb(k)
  if sd[k] > 1.6 and abs(b - SPLIT) < 0.55 then vm.s[K(x, y)] = nil end
end)

-- light: flattened cupped vane
local n = {}
vm:each(function(x, y) local k = K(x, y)
  local s = sd[k]
  local w = s >= 0 and max(1, wTrail(TT[k])) or max(1, wLead(TT[k]))
  local sn = max(-0.9, min(0.9, s / (w + 0.5))) * 0.75
  -- lean the whole vane slightly toward the light so the lead side is lit
  local i = (sm[floor(TT[k] * N) + 1])
  n[k] = { A.norm(i.px * sn, i.py * sn, sqrt(1 - sn * sn)) }
end)
local v = X.light(n, { amb = 0.18, wrap = 0.35 })
vm:each(function(x, y) local k = K(x, y)
  local i = floor(v[k] * 5.99) + 1
  local b = barb(k)
  local s = sd[k]
  -- fine barb lines every 2.5 px, darker one step on the mid tones
  if (b % 2.5) < 0.8 and abs(s) > 1.2 then i = i - 1 end
  -- AO beside the shaft
  if abs(s) < 1.3 then i = i - 1 end
  -- frayed lighter edge on the leading vane
  if s < 0 and not vm:has(x - 1, y) and not vm:has(x, y - 1) then i = i + 1 end
  i = max(1, min(6, i))
  local col = VANE[i]
  -- chevron bars (dark), skipped near the tip band
  local bar = (b % 7.2)
  if bar < 2.2 and TT[k] > T0 + 0.05 and TT[k] < 0.9 then col = BAR[max(1, min(4, i - 1))] end
  -- pale tip band
  if TT[k] > 0.92 then col = TIP[i >= 5 and 3 or i >= 3 and 2 or 1] end
  c:put(x, y, col, vtok)
end)

-- downy afterfeather: soft wisps around the base of the vane
local wisps = {
  { 0.17, 1, 4.5, 0.5 }, { 0.19, -1, 3.5, -0.4 }, { 0.15, 1, 3.2, 0.9 }, { 0.21, -1, 4.2, 0.2 }, { 0.13, -1, 2.6, 0.6 },
}
for _, wv in ipairs(wisps) do
  local s = sm[floor(wv[1] * N) + 1]
  local tx, ty = -s.py * -1, s.px    -- along shaft (toward tip is -? compute from neighbours)
  local s2 = sm[floor(wv[1] * N) + 6]
  tx, ty = s2.x - s.x, s2.y - s.y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  for j = 1, floor(wv[3] * 2) do
    local f = j / 2
    local cx = s.x + s.px * wv[2] * f - tx * f * 0.6 + wv[4] * sin(f * 1.7)
    local cy = s.y + s.py * wv[2] * f - ty * f * 0.6
    local xi, yi = floor(cx + .5), floor(cy + .5)
    if not vm:has(xi, yi) then
      c:put(xi, yi, f < wv[3] * 0.5 and DOWN[2] or (wv[2] < 0 and DOWN[3] or DOWN[1]), dtok)
    end
  end
end

-- shaft: rachis in the vane (cream lit, shade line on the trailing side), bare quill below
for i = 0, N do
  local s = sm[i + 1]
  local t = s.t
  local xi, yi = floor(s.x + .5), floor(s.y + .5)
  if t < T0 + 0.01 then
    -- calamus: 2 px wide horn quill
    c:put(xi, yi, t < 0.03 and QUILL[1] or QUILL[3], stok)
    local ox, oy = floor(s.x + s.px * 0.9 + .5), floor(s.y + s.py * 0.9 + .5)
    if t < 0.15 and (ox ~= xi or oy ~= yi) then c:put(ox, oy, QUILL[2], stok) end
  elseif t < 0.97 then
    c:put(xi, yi, t < 0.9 and QUILL[3] or QUILL[2], stok)
    local ox, oy = floor(s.x + s.px * 0.9 + .5), floor(s.y + s.py * 0.9 + .5)
    if t < 0.6 and (ox ~= xi or oy ~= yi) and vm:has(ox, oy) then c:put(ox, oy, VANE[2], vtok) end
  end
end
-- quill specular + hollow dark tip
do local s = sm[floor(0.08 * N) + 1] c:put(floor(s.x + .5), floor(s.y + .5), QUILL[4], stok)
   local s0 = sm[1] c:put(floor(s0.x + .5), floor(s0.y + .5), QUILL[1], stok) end

-- quirk: dewdrop on the trailing vane
do
  local s = sm[floor(0.7 * N) + 1]
  local cx, cy = floor(s.x + s.px * 3.4 + .5), floor(s.y + s.py * 3.4 + .5)
  A.map(c, {
    ".ab.",
    "abcb",
    "abbb",
    ".bb.",
  }, cx - 1, cy - 1, { a = DROP[3], b = DROP[2], c = DROP[3] }, qtok)
  c:put(cx + 2, cy + 1, DROP[1], qtok) c:put(cx + 1, cy + 2, DROP[1], qtok)
  c:put(cx, cy, A.CREAM, qtok)
  -- contact shadow under the drop on the vane
  A.putIn(c, vm, cx + 2, cy + 3, BAR[1], vtok) A.putIn(c, vm, cx + 3, cy + 2, BAR[1], vtok)
end

A.save(c, "hawk-feather")
