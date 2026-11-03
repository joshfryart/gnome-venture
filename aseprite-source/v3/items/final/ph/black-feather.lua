-- black-feather (final, Opus single pass). One slim, gently S-curved crow flight feather: narrow leading vane on the
-- lit side, wide trailing vane, barbs swept toward the tip (alternating tone rows), a blue-violet-teal sheen on the lit
-- vane, two natural splits in the vane edge, downy afterfeather wisps at the base, and a pale hollow quill (calamus)
-- with a bright rim. quirk: the quill has been cut into a pen nib and is stained with blue ink, one drop hanging off it.
local NAME = "black-feather"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_3.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = R.new(NAME)
local F = { "#0e0a15", "#191427", "#272038", "#35304e", "#454468", "#5f6288" }
local SHEEN = { "#2f4f74", "#3f7c98", "#62aeb6" }      -- teal-blue iridescence on the lit vane
local VIO = "#5b4790"
local QUILL = { "#6e6258", "#a49378", "#d6c7a2", "#f2e8cc" }
local INK = { "#1d2a6a", "#2f47a8", "#5a7ee0" }
local DOWN = { "#3a3550", "#5c5874", "#827e98" }

local pts = { { 14, 55 }, { 18, 43 }, { 30, 28 }, { 49, 11 } }
local T0 = 0.15                         -- vane starts here (below = bare quill)
local function wl(t) if t < T0 then return 0 end local u = (t - T0) / (1 - T0) return 3.2 * sin(pi * min(1, u * 0.93 + 0.05)) ^ 0.55 end
local function wr(t) if t < T0 then return 0 end local u = (t - T0) / (1 - T0) return 6.2 * sin(pi * min(1, u * 0.9 + 0.08)) ^ 0.6 * (1 - 0.25 * u) end
local m, n, T, S, smp = R.tube(pts, function(t) return max(wl(t), wr(t), 0.01) + 0.5 end)
-- arc length (for barb spacing)
local len = 0
for i = 2, #smp do len = len + sqrt((smp[i].x - smp[i-1].x)^2 + (smp[i].y - smp[i-1].y)^2) end
-- keep the asymmetric vane: S<0 is the lit (upper-left) side
local vane = HP.mask()
local SD = {}
m:each(function(x, y) local k = K(x, y) local t = T[k]
  local w = max(wl(t), wr(t), 0.01) + 1.0
  local sd = S[k] * w
  SD[k] = sd
  local lim = sd < 0 and wl(t) or wr(t)
  if t >= T0 and abs(sd) <= lim + 0.3 then vane:set(x, y) end
end)
-- natural splits: thin V gaps raking toward the tip
local function split(t0, side, depth)
  vane:each(function(x, y) local k = K(x, y) local t, sd = T[k], SD[k]
    if (sd > 0) == (side > 0) then
      local a = abs(sd)
      local lim = side > 0 and wr(t) or wl(t)
      local dt = (t - t0) * len - a * 0.9
      if a > lim * (1 - depth) and dt > -0.6 and dt < 0.6 then vane.s[k] = nil end
    end
  end)
end
split(0.5, 1, 0.8) split(0.7, -1, 0.75) split(0.34, 1, 0.45)

-- shade the vane: gentle cupped light + barb rows + sheen
local tok = { r = { name = "vane" } }
local nv = {}
vane:each(function(x, y) local k = K(x, y) local sd = SD[k]
  local lim = sd < 0 and wl(T[k]) or wr(T[k])
  local u = sd / max(lim, 1)                  -- -1..1 across
  local cup = sd < 0 and -0.55 or 0.35 + u * 0.3
  local tx, ty = 0.7, -0.7
  local px, py = 0.7, 0.7
  nv[k] = { R.norm(px * cup, py * cup, 1) }
end)
local v = X.light(nv, { amb = 0.05, wrap = 0.35 })
vane:each(function(x, y) local k = K(x, y) local t, sd = T[k], SD[k]
  local i = 1
  for j, ct in ipairs{ 0.3, 0.45, 0.58, 0.7, 0.82 } do if v[k] >= ct then i = j + 1 end end
  -- barbs: rows swept toward the tip
  local ph = (t * len - abs(sd) * 1.1) / 2.2
  if (floor(ph) % 2) == 1 then i = i - 1 end
  -- trailing vane darkens toward the edge
  if sd > 0 and sd > wr(t) - 1.3 then i = i - 1 end
  i = max(1, min(6, i))
  local col = F[i]
  -- iridescent sheen band on the lit leading vane and inner trailing vane
  if sd < -0.6 and i >= 4 and t > 0.25 and t < 0.85 then col = (floor(ph) % 2 == 0) and SHEEN[2] or SHEEN[1] end
  if sd > 0.6 and sd < 2.6 and t > 0.3 and t < 0.75 and (floor(ph) % 2 == 0) then col = VIO end
  c:put(x, y, col, tok)
end)
-- one sheen spec
do local x, y = R.bez(pts, 0.55) c:put(floor(x - 1.5), floor(y - 0.5), SHEEN[3], tok) c:put(floor(x - 2.5), floor(y + 0.5), SHEEN[3], tok) end

-- afterfeather: downy wisps at the vane base
local dtok = { r = { name = "down" } }
for _, w in ipairs{ { 0.15, -1, 4 }, { 0.17, 1, 5 }, { 0.13, 1, 4 }, { 0.19, -1, 3 } } do
  local x, y = R.bez(pts, w[1])
  local x1, y1 = R.bez(pts, w[1] + 0.01)
  local tx, ty = x1 - x, y1 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = 0.7071 * w[2], 0.7071 * w[2]
  px, py = -ty * w[2], tx * w[2]
  if px + py < 0 == (w[2] > 0) then px, py = -px, -py end
  for s = 1, w[3] do
    local xx = x + px * s + tx * s * 0.6 + (s == w[3] and -tx or 0)
    local yy = y + py * s + ty * s * 0.6 + (s == w[3] and -ty or 0)
    c:put(floor(xx + .5), floor(yy + .5), s == 1 and DOWN[1] or (s == w[3] and DOWN[3] or DOWN[2]), dtok)
  end
end

-- rachis + quill: pale shaft; darker as it runs into the vane
local qtok = { r = { name = "quill" } }
for i = 0, 200 do
  local t = i / 200
  local x, y = R.bez(pts, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  if t < T0 + 0.01 then
    c:put(xi, yi, QUILL[3], qtok) c:put(xi + 1, yi, QUILL[2], qtok)
    if t > 0.03 and t < 0.12 then c:put(xi - 1, yi, QUILL[4], qtok) c:put(xi + 2, yi, QUILL[1], qtok) end
  elseif t < 0.93 then
    c:put(xi, yi, t < 0.5 and QUILL[2] or F[5], qtok)
  end
end
-- quirk: pen nib cut at the quill tip, inked blue, one drop
local x0, y0 = R.bez(pts, 0)
x0, y0 = floor(x0 + .5), floor(y0 + .5)
local itok = { r = { name = "ink" } }
c:put(x0, y0, INK[1], itok) c:put(x0 + 1, y0, INK[2], itok) c:put(x0, y0 - 1, INK[2], itok) c:put(x0 + 1, y0 - 1, INK[3], itok)
c:put(x0 - 1, y0 - 2, INK[2], itok) c:put(x0 + 2, y0 - 2, INK[1], itok)
c:put(x0 + 1, y0 - 3, QUILL[1], itok)   -- nib slit
c:put(x0 - 1, y0 + 2, INK[2], itok) c:put(x0 - 1, y0 + 3, INK[1], itok)   -- falling drop (detached, 1px air)
R.finish(c)
