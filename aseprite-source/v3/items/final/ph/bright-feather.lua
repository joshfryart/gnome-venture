-- bright-feather (Opus single pass, aB10_4). A long, slim flight feather on the diagonal, bowed toward the upper
-- left: scarlet vane, a chevron gold band and a cobalt tip (the colour borders follow the barb angle). Material:
-- per-pixel light with a V fold at the rachis, barb lines swept toward the tip, a glossy sheen streak on the lit
-- side, ivory rachis (lit/shade split), a translucent amber quill with a pale core, peach afterfeather fluff at the
-- base and a dark row (AO) where the vane meets the quill.
-- quirk: one split in the lower vane where the barbs came unzipped, with a single stray barb poking out.
local NAME = "bright-feather"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local RED  = { "#4e1430", "#861d38", "#bf2c3a", "#e6463a", "#ff7550", "#ffb07a" }
local GOLD = { "#6a3a1c", "#a8601e", "#d98a22", "#f5bc2e", "#ffdb5e", "#fff2a6" }
local BLUE = { "#1a2058", "#22378a", "#2c5cbc", "#3f8ce0", "#6cbff2", "#b2e8ff" }
local DOWN = { "#7a4a62", "#b07a8c", "#dca6a8", "#f6cbbd", "#ffe2d2", "#fff0e4" }
local QUILL = { "#6a4a38", "#a07a5a", "#d0b08a", "#f2dcb4", "#fff2d8" }
local RACH = { "#b89470", "#e8d2a8", "#fff2d4" }

-- vane
local m, n, T, S, len = G.blade(17, 49, 25, 21, 52, 9, function(t)
  if t > 0.99 then return -1 end
  local w = 6.0 * sin(pi * min(1, t * 0.86 + 0.12)) ^ 0.62
  if t < 0.17 then w = w + 0.9 * sin(t * 90) end      -- fluffy afterfeather edge
  return max(0.8, w)
end, { fold = 0.42 })

local function U(k) return T[k] * len - abs(S[k]) * 4.2 end  -- barb coordinate (chevron toward the tip)
-- leading edge (upper-left) narrower than the trailing edge, like a real flight feather
local cut = {}
m:each(function(x, y) local k = K(x, y)
  if S[k] < -0.78 and T[k] > 0.22 and T[k] < 0.92 then cut[#cut + 1] = k end
  -- quirk: unzipped split in the trailing vane
  local u0 = 0.5 * len
  if S[k] > 0.28 and abs(U(k) - u0 + (S[k] - 0.28) * 2.2) < 0.75 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do m.s[k] = nil end

local v = X.light(n, { amb = 0.1, wrap = 0.28 })
local tok = { r = { name = "vane" } }
m:each(function(x, y) local k = K(x, y)
  local t, s, u = T[k], S[k], U(k)
  local i = G.q(v[k], { 0.18, 0.36, 0.54, 0.7, 0.86 })
  local ramp
  if t < 0.17 then ramp = DOWN
  elseif u < 0.68 * len then ramp = RED
  elseif u < 0.745 * len then ramp = GOLD
  else ramp = BLUE end
  -- barb gaps: dark line every 2.6 px along the barb coordinate
  local ph = u / 2.6
  if abs(s) > 0.17 and t > 0.17 and (ph - floor(ph)) < 0.34 then i = i - 1 end
  -- sheen streak on the lit vane
  if s < -0.3 and s > -0.52 and t > 0.3 and t < 0.66 and (ph - floor(ph)) > 0.6 then i = i + 1 end
  -- ragged downy edge: paler wisps
  if t < 0.17 and abs(s) > 0.6 then i = min(6, i + 1) end
  -- AO: vane base where it meets the quill
  if t < 0.05 then i = i - 1 end
  c:put(x, y, ramp[max(1, min(6, i))], tok)
end)
-- split edges: deep tone on the cut faces so the gap reads
m:each(function(x, y) local k = K(x, y)
  if S[k] > 0.2 and T[k] > 0.3 and T[k] < 0.7 then
    for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } } do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) then
        local kk = K(nx, ny)
        -- neighbour cut by the split (inside the blade's span), not the outer edge
        if T[kk] and S[kk] and S[kk] > 0.2 and S[kk] < 0.9 then c:put(x, y, RED[2], tok) end
      end
    end
  end
end)
-- rachis: ivory, lit/shade split, tapering out before the tip
m:each(function(x, y) local k = K(x, y)
  if abs(S[k]) < 0.12 and T[k] < 0.95 then c:put(x, y, (S[k] <= 0 and T[k] < 0.8) and RACH[3] or RACH[2], tok) end
end)

-- stray barb poking out of the split (quirk)
do
  local best
  m:each(function(x, y) local k = K(x, y)
    if S[k] > 0.8 and abs(T[k] - 0.53) < 0.03 and (not best or x + y > best[1] + best[2]) then best = { x, y } end end)
  if best then
    c:put(best[1] + 1, best[2] + 1, RED[4], tok)
    c:put(best[1] + 2, best[2] + 1, RED[3], tok)
  end
end

-- quill (calamus): translucent amber tube, pale core, one glint
local qm, qn, QT, QS = G.tube({ { 10, 58 }, { 12, 55 }, { 14, 52 }, { 17, 49 } }, function(t) return 0.8 + 0.5 * t end)
qm:cut(m)
local qtok = { r = { name = "quill" } }
local qidx = X.tone(c, qm, X.light(qn, { amb = 0.15, wrap = 0.3 }), QUILL, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = qtok })
qm:each(function(x, y) local k = K(x, y)
  if abs(QS[k]) < 0.25 and QT[k] > 0.2 and QT[k] < 0.85 then c:put(x, y, QUILL[4], qtok) end
  if QT[k] > 0.88 then c:put(x, y, QUILL[2], qtok) end          -- AO under the vane
end)
do local x, y = G.bez({ { 10, 58 }, { 12, 55 }, { 14, 52 }, { 17, 49 } }, 0.45) c:put(floor(x), floor(y), QUILL[5], qtok) end

-- one bright specular on the cobalt tip + one cream sparkle on the sheen
do
  local best
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.8 and T[k] < 0.9 and S[k] < -0.25 and S[k] > -0.55 and (not best or x + y < best[1] + best[2]) then best = { x, y } end end)
  if best then c:put(best[1], best[2], "#f0fbff", tok) c:put(best[1] + 1, best[2], BLUE[6], tok) end
end

G.save2(c, NAME)
