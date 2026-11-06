-- _aC23_2.lua: private helpers for mexican-sunflower-seed, meyer-lemon, meyer-lemon-marmalade, meyer-lemon-seed.
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib hp/hpx). Adds seed shapes, torn scraps, glints.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt, max, min, cos, sin = math.floor, math.abs, math.sqrt, math.max, math.min, math.cos, math.sin
local A = setmetatable({}, { __index = G })

-- seed body along an axis: u in [0,1] from tip (u=0) to the round end (u=1); prof(u) = half width (px)
-- returns mask, U, V (V signed across, -1..1, V<0 = upper-left/lit side)
function A.seed(cx, cy, len, prof, ang)
  local ca, sa = cos(ang), sin(ang)
  local px, py = -sa, ca
  local flip = (px + py) < 0 and -1 or 1
  local m, U, V = HP.mask(), {}, {}
  local R = len / 2 + 4
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local a = dx * ca + dy * sa
    local b = (dx * px + dy * py) * flip
    local u = a / len + 0.5
    if u >= -0.02 and u <= 1.02 then
      local w = prof(max(0, min(1, u)))
      if w > 0 and abs(b) <= w + 0.2 then
        m:set(x, y)
        local k = K(x, y) U[k] = u V[k] = max(-1, min(1, b / (w + 0.4)))
      end
    end
  end end
  return m, U, V
end

-- jagged tear: cut pixels of a blade near t=t0 end (t0 = 0 or 1); returns mask of the new torn edge
function A.tear(m, T, S, len, atStart, depth, seed)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local d = atStart and T[k] * len or (1 - T[k]) * len
    local j = 1.2 + depth * (0.5 + 0.5 * sin(S[k] * 7.3 + (seed or 0))) + X.hash(x, y, seed or 3) * 1.6
    if d < j then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local gone = HP.mask() for _, k in ipairs(cut) do gone.s[k] = true end
  local edge = HP.mask()
  m:each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if gone:has(x + d[1], y + d[2]) then edge:set(x, y) break end
    end
  end)
  return edge
end

-- serrate a blade margin: notch every per px along the edge
function A.serrate(m, T, S, len, per, t0, t1, lim)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t > t0 and t < t1 then
      local ph = (t * len + (s > 0 and per / 2 or 0)) / per
      local f = ph - floor(ph)
      if abs(s) > (lim or 0.82) and f < 0.42 then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
end

-- paint a list of {x,y,hex}
function A.dots(c, list, tok) for _, p in ipairs(list) do c:put(p[1], p[2], p[3], tok) end end

-- cool reflected light: edge pixels facing lower-right
function A.bounce(c, m, n, hex, tok, thr, filt)
  local r = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if r[k] and r[k] > (thr or 0.62) and (not filt or filt(x, y, k)) then c:put(x, y, hex, tok) end end)
end
return A
