-- bat-down (ph, Opus single pass, aR3_5). A small bundle of soft brown echo-bat down: three slim S-curved locks fanning
-- up and right from a gathered base, each modelled as a soft tube (per-pixel light, cool violet bounce on the shade
-- side), combed with strand grooves and lit hairs along the curve, splitting into fine wisps at the tips; AO and a dark
-- separation where the locks overlap. The base is bound with a twist of violet thread (diagonal twist marks) above a
-- darker clipped stub.
-- quirk: a tiny gold crescent-moon charm dangles from the binding on a loose thread.
local NAME = "bat-down"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local FUR  = { "#26161c", "#3e2526", "#5a3830", "#7a5038", "#9c6c48", "#c4946a" }
local HAIR, BOUNCE = "#e2b88a", "#54425a"
local THR  = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- locks: bezier, max half-width; drawn back to front. The main lock is a slim comma-shaped plume whose tip curls over.
local locks = {
  { p = { { 21, 50 }, { 31, 47 }, { 41, 44 }, { 52, 35 } }, w = 3.4, sp = 3.4, hs = { 1 } },
  { p = { { 20, 49 }, { 24, 42 }, { 33, 35 }, { 41, 27 } }, w = 3.0, sp = 3.0, hs = {} },
  { p = { { 19, 49 }, { 13, 33 }, { 26, 18 }, { 44, 12 } }, w = 5.6, sp = 2.6, hs = { -1 } },
}
local all = HP.mask()
for li, L in ipairs(locks) do
  local wf = function(t)
    if t > 0.985 then return -1 end
    return max(0.6, L.w * (0.45 + 0.55 * sin(pi * min(1, t * 1.25 + 0.05)) ^ 0.8) * (1 - t ^ 2.2 * 0.8))
  end
  local m, n, T, S, sm = G.tube(L.p, wf)
  -- downy edge: short hairs flicking out of both flanks, swept toward the tip
  local hairs = HP.mask()
  local hl = {}
  for i = 6, #sm - 8, 5 do
    local q = sm[i]
    for _, side in ipairs(L.hs) do
      if X.hash(i, side + 2, li) > 0.25 then
        local ox, oy = q.x + q.px * side * (q.w + 0.3), q.y + q.py * side * (q.w + 0.3)
        local ux, uy = q.px * side * 0.55 + q.tx * 0.85, q.py * side * 0.55 + q.ty * 0.85
        local nl = 1 + floor(X.hash(i, side, 9) * 1.6)
        for j = 1, nl do
          local x, y = floor(ox + ux * j + 0.5), floor(oy + uy * j + 0.5)
          if not m:has(x, y) then hairs:set(x, y) hl[K(x, y)] = side end
        end
      end
    end
  end
  local tok = { r = { name = "lock" .. li } }
  local sep = {}
  m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if all:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then sep[k] = true end end end)
  local v = X.light(n, { amb = 0.1, wrap = 0.35 })
  local idx = X.tone(c, m, v, FUR, { cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 }, tok = tok })
  local rim = X.rim(n)
  -- combed strands: grooves along the length that drift slightly across, lit hairs on the light side
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    local ph = s * L.sp + sin(t * 9 + li) * 0.18 + t * 0.8
    local f = ph - floor(ph)
    local i = idx[k]
    if f < 0.22 then i = i - 1 elseif f < 0.3 then i = i - 2 elseif f > 0.5 and f < 0.64 and s < 0.25 then i = i + 1 end
    if t < 0.1 then i = i - 1 end
    if rim[k] > 0.6 and i <= 3 then c:put(x, y, BOUNCE, tok) return end
    c:put(x, y, FUR[max(1, min(6, i))], tok)
  end)
  hairs:each(function(x, y) c:put(x, y, (hl[K(x, y)] < 0) and FUR[5] or FUR[3], tok) end)
  -- sheen: a soft 1 px highlight run on the lit flank of the swell
  for _, q in ipairs(sm) do
    if q.t > 0.22 and q.t < 0.55 then
      local x, y = floor(q.x - q.px * q.w * 0.5 + 0.5), floor(q.y - q.py * q.w * 0.5 + 0.5)
      if m:has(x, y) then c:put(x, y, (q.t > 0.3 and q.t < 0.45) and HAIR or FUR[6], tok) end
    end
  end
  for k in pairs(sep) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, FUR[1], tok) end
  -- wisp tip: the lock ends in one fine hair flicking up
  local tx, ty = G.bez(L.p, 0.94)
  local ex, ey = G.bez(L.p, 1)
  local dx, dy = ex - tx, ey - ty
  local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
  for wi, a in ipairs{ 0.35 } do
    local ux, uy = G.rot(dx, dy, a)
    for j = 1, 2 do
      local x, y = floor(ex + ux * j + 0.5), floor(ey + uy * j + 0.5)
      if not m:has(x, y) then c:put(x, y, (j < 3) and FUR[4] or FUR[5], tok) hairs:set(x, y) end
    end
  end
  all:add(m) all:add(hairs)
end

-- clipped stub below the binding (darker cut ends) ------------------------------------------------------------------
local stub = c:poly{ { 15, 52 }, { 22, 52 }, { 21, 57 }, { 16, 57 } }
local stok = { r = { name = "stub" } }
stub:each(function(x, y)
  local i = (x < 18) and 3 or 2
  if (x + y) % 3 == 0 then i = i - 1 end
  if y == 57 then i = (x % 2 == 0) and 4 or 2 end                 -- cut ends: paler tips
  c:put(x, y, FUR[max(1, i)], stok)
end)
-- binding: a twist of violet thread around the gathered base -----------------------------------------------------------
local band = c:poly{ { 14.5, 47 }, { 23.5, 48 }, { 23, 53 }, { 14, 52 } }
local btok = { r = { name = "thread" } }
band:each(function(x, y)
  local tt = (x - 14) / 9
  local i = tt < 0.25 and 3 or tt < 0.75 and 2 or 1
  if (x + y * 2) % 4 == 0 then i = i + 1 elseif (x + y * 2) % 4 == 2 then i = i - 1 end   -- diagonal twist
  if y == 47 or (y == 48 and x > 21) then i = i + 1 end
  c:put(x, y, THR[max(1, min(4, i))], btok)
end)
c:put(16, 49, THR[4], btok) c:put(17, 49, THR[4], btok)
-- ambient row where fur meets the binding
for x = 15, 23 do if all:has(x, 46) and not band:has(x, 46) then c:put(x, 46, FUR[1], { r = { name = "ao" } }) end end

-- quirk: crescent-moon charm on a loose thread ----------------------------------------------------------------------
local qt = { r = { name = "charm" } }
for _, q in ipairs{ { 13, 52 }, { 12, 53 }, { 11, 53 } } do c:put(q[1], q[2], THR[2], qt) end
local moon = c:ellipse(10, 56, 2.6, 2.6):cut(c:ellipse(11.6, 55.0, 2.0, 2.0))
moon:each(function(x, y)
  local i = (x + y < 64) and 3 or 2
  if x <= 8 then i = 3 end
  if y >= 58 or (x >= 11 and y >= 57) then i = 2 end
  c:put(x, y, GOLD[i], qt)
end)
c:put(8, 55, GOLD[4], qt) c:put(9, 58, GOLD[1], qt)

G.save2(c, NAME)
