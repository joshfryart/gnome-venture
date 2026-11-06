-- ico-feather (final, Opus). One slim, gently curved jay feather on the diagonal (quill lower-left, tip upper-right):
-- a narrow leading vane and a wider trailing vane, bright blue with bold navy bars, soft grey down at the base and a
-- bare horn quill cut to a nib.
-- Material: per-pixel cupped-vane light (each half tilts off the shaft) snapped to 6-tone ramps, barb grooves angled
-- toward the tip, a lit shaft (ivory, dark edge on the shade side), one split in the trailing vane with a stray barb,
-- fluffy ragged down, horn quill with a bright rim and a pale core, AO where the vane meets the shaft.
-- quirk: the nib has been dipped: a dark ink tip with one drop about to fall.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("ico-feather")
local BL = { "#1c2c6a", "#2a49a4", "#3270cf", "#4a9be8", "#7cc6f5", "#c4ecff" }
local BAR = { "#100f26", "#17163a", "#211f4e", "#2e2d64", "#403f7e", "#575a9a" }
local DN = { "#55506e", "#7d7894", "#a7a1b8", "#cbc5d4", "#e6e0e6", "#fbf5ee" }
local QU = { "#6b5050", "#9c8070", "#c8b090", "#e6d6b2", "#f7edd2", "#fffbe6" }
local vtok, qtok = A.tok("vane"), A.tok("quill")

local P = { { 14, 52 }, { 22, 40 }, { 35, 22 }, { 51, 10 } }
-- samples along the shaft
local N = 200
local sm, LEN = {}, 0
for i = 0, N do
  local t = i / N
  local x, y = A.bez(P, t)
  local x2, y2 = A.bez(P, min(1, t + 0.002))
  local x1, y1 = A.bez(P, max(0, t - 0.002))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  if i > 0 then LEN = LEN + sqrt((x - sm[i].x) ^ 2 + (y - sm[i].y) ^ 2) end
  sm[i + 1] = { x = x, y = y, t = t, tx = tx, ty = ty, px = px, py = py, L = LEN }
end
local T0 = 0.21          -- vane starts here; below is bare quill
local function prof(t)   -- 0..1 vane width profile: rounded base, full belly, rounded pointed tip
  if t < T0 then return 0 end
  local u = (t - T0) / (1 - T0)
  local a = min(1, u / 0.18) ^ 0.6
  local b = (1 - u) ^ 0.45
  return a * b
end
local WL, WR = 7.6, 10.6  -- leading (upper-left, s<0) and trailing (lower-right, s>0) max half-widths

local vm, vn, VT, VS, VA = HP.mask(), {}, {}, {}, {}
for y = 2, 61 do for x = 2, 61 do
  local best, bs = 1e9, nil
  for _, s in ipairs(sm) do local q = (x - s.x) ^ 2 + (y - s.y) ^ 2 if q < best then best, bs = q, s end end
  local rx, ry = x - bs.x, y - bs.y
  local along = rx * bs.tx + ry * bs.ty
  local sd = rx * bs.px + ry * bs.py
  local t = bs.t
  if not (t >= 0.999 and along > 0.4) then
    local w = prof(t) * (sd < 0 and WL or WR)
    if t < 0.37 then w = w * (0.86 + 0.22 * sin((bs.L + along) * 1.9 + (sd < 0 and 1.3 or 0))) end -- fluffy scallops
    if w > 0.3 and abs(sd) <= w then
      vm:set(x, y)
      local k = K(x, y)
      local f = sd / (w + 0.5)
      -- cupped vane: tilts away from the shaft, edges curl back slightly
      local tilt = (sd < 0 and -0.3 or 0.2) + f * 0.22
      vn[k] = { A.norm(bs.px * tilt, bs.py * tilt, 1) }
      VT[k], VS[k], VA[k] = t, sd, bs.L + along
    end
  end
end end
-- the split: a barb-angled wedge cut into the trailing vane
local function barbPhase(k) return VA[k] - abs(VS[k]) * 1.25 end
local splitA = 0.63
local splitPh
do local s = sm[floor(splitA * N) + 1] splitPh = s.L end
vm:each(function(x, y) local k = K(x, y)
  if VS[k] > 1.2 then
    local d = barbPhase(k) - splitPh
    if d > -0.6 and d < 0.6 + VS[k] * 0.12 then vm.s[k] = nil end
  end
end)
-- light
local v = A.val(vn, { amb = 0.08, wrap = 0.3, tilt = { 33, 31, 24, 0.08 } })
local bias = {}
vm:each(function(x, y) local k = K(x, y)
  if abs(VS[k]) < 1.6 then bias[k] = -1 end                       -- AO along the shaft
  local ph = barbPhase(k) % 4.0
  if ph < 1.0 and abs(VS[k]) > 1.5 then bias[k] = (bias[k] or 0) - 1 end  -- barb grooves
end)
-- choose ramp per pixel: down near the base, navy bars across the blue
local function rampOf(k)
  local t = VT[k]
  local ph = barbPhase(k) / LEN + 0.0
  if t < 0.36 + 0.04 * abs(VS[k]) / 6 then return DN end
  local q = barbPhase(k) / LEN
  for _, b in ipairs{ { 0.46, 0.53 }, { 0.62, 0.68 }, { 0.76, 0.81 } } do
    if q > b[1] and q < b[2] then return BAR end
    if q >= b[2] and q < b[2] + 0.025 and abs(VS[k]) > 2 then return DN end
  end
  return BL
end
local cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }
vm:each(function(x, y) local k = K(x, y)
  local R = rampOf(k)
  local i = 1
  for j, tt in ipairs(cuts) do if v[k] >= tt then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  c:put(x, y, R[i], vtok)
end)
-- stray barb sticking out of the split
do local s = sm[floor((splitA + 0.015) * N) + 1]
  for j = 3, 9 do local d = j
    local x = floor(s.x + s.px * d - s.tx * d * 0.55 + .5)
    local y = floor(s.y + s.py * d - s.ty * d * 0.55 + .5)
    if not vm:has(x, y) then c:put(x, y, BL[4], vtok) end
  end
end
-- shaft (rachis) over the vane + bare quill (calamus) below
local qm, qn, QS = HP.mask(), {}, {}
for i, s in ipairs(sm) do
  local t = s.t
  local w = t < T0 and (1.6 - (T0 - t) * 1.2) or (1.2 * (1 - t) + 0.25)
  for dy = -3, 3 do for dx = -3, 3 do
    local x, y = floor(s.x + .5) + dx, floor(s.y + .5) + dy
    local sd = (x - s.x) * s.px + (y - s.y) * s.py
    local al = (x - s.x) * s.tx + (y - s.y) * s.ty
    if abs(sd) <= w and abs(al) <= 0.6 and not (t < 0.012 and al < 0) then
      qm:set(x, y) local k = K(x, y) local f = max(-0.95, min(0.95, sd / (w + 0.5)))
      if not QS[k] or abs(f) < abs(QS[k]) then QS[k] = f qn[k] = { s.px * f, s.py * f, sqrt(1 - f * f) } end
    end
  end end
end
local qidx = A.shade(c, qm, qn, QU, { tok = qtok, amb = 0.15, wrap = 0.3, cuts = { 0.14, 0.3, 0.5, 0.7, 0.86 } })
-- pale core streak + bright rim on the bare quill
for i = floor(0.04 * N), floor(0.2 * N), 4 do local s = sm[i + 1]
  c:put(floor(s.x - s.px * 0.6 + .5), floor(s.y - s.py * 0.6 + .5), QU[6], qtok) end
-- quirk: ink-dipped nib + falling drop
local INK2 = { "#1a1030", "#2b1c4a", "#4a3a7a" }
for i = 0, floor(0.05 * N) do local s = sm[i + 1]
  for d = -2, 2 do local x, y = floor(s.x + s.px * d * 0.6 + .5), floor(s.y + s.py * d * 0.6 + .5)
    if qm:has(x, y) then c:put(x, y, d < 0 and INK2[2] or INK2[1], qtok) end end end
local s0 = sm[1]
c:put(floor(s0.x - 0.4), floor(s0.y + 0.5), INK2[3], qtok)
A.map(c, { ".d.", "dkd", "dkd", ".d." }, 8, 56, { d = INK2[1], k = INK2[3] }, qtok)
c:put(9, 57, "#8a7ac0", qtok)
A.save(c, "ico-feather")
