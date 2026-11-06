-- _aC34_5.lua: private helpers for pickled-radishes, pickled-samphire, pickled-turnips, pigeon-pea (C34 slot 5, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Adds glass-jar rendering (surface-of-revolution
-- normals, brine back, glass rim + streaks + meniscus) and small lit primitives.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK = "#2b1c26"

function A.new(name) A.name = name return G.new2(name) end
function A.tint(r, hex, t) local o = {} for i, h in ipairs(r) do o[i] = G.mix(h, hex, t) end return o end
function A.lit(c, m, n, ramp, o)
  o = o or {}
  return G.toneN(c, m, n, ramp, { tok = o.tok or { r = { name = o.name or "p" } }, bias = o.bias, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
end

-- jar body from a half-width function hw(y) (centre cx, symmetric about cx), rows y0..y1
function A.jar(cx, y0, y1, hw)
  local m, n, NX = HP.mask(), {}, {}
  for y = y0, y1 do
    local h = hw(y)
    for x = floor(cx - h - 1), floor(cx + h + 1) do
      local dx = x + 0.5 - cx
      if abs(dx) <= h then
        m:set(x, y)
        local nx = max(-0.97, min(0.97, dx / (h + 0.5)))
        local nz = sqrt(1 - nx * nx)
        local dr = (hw(min(y1, y + 1)) - hw(max(y0, y - 1))) / 2
        local ny = -dr * nz * 0.9
        n[K(x, y)] = { G.norm(nx, ny, nz) }
        NX[K(x, y)] = nx
      end
    end
  end
  local J = { m = m, n = n, NX = NX, cx = cx, y0 = y0, y1 = y1, hw = hw }
  J.inner = m:shrink(1)
  return J
end

-- brine + air back fill. level = first brine row
function A.back(c, J, brine, air, level)
  J.level = level
  local bm, am = HP.mask(), HP.mask()
  J.inner:each(function(x, y) if y >= level then bm:set(x, y) else am:set(x, y) end end)
  J.brine, J.air = bm, am
  J.btok = { r = { name = "brine" } }
  A.lit(c, bm, J.n, brine, { tok = J.btok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 }, amb = 0.2, wrap = 0.5 })
  A.lit(c, am, J.n, air, { tok = J.btok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 }, amb = 0.25, wrap = 0.5 })
end

-- glass front: wall ring, thick base, highlight streaks, meniscus
function A.front(c, J, GL, o)
  o = o or {}
  local tok = { r = { name = "glass" } }
  local ring = J.m:copy():cut(J.inner)
  ring:each(function(x, y) local k = K(x, y) local nx = J.NX[k]
    local i = nx < -0.45 and 5 or (nx > 0.45 and 2 or 4)
    if y == J.y1 then i = nx < 0 and 3 or 2 end
    c:put(x, y, GL[i], tok)
  end)
  -- thick base: 2 rows above the bottom, glass tinted
  for y = J.y1 - (o.base or 2), J.y1 - 1 do
    local h = J.hw(y)
    for x = floor(J.cx - h), floor(J.cx + h) do
      if J.inner:has(x, y) then local nx = J.NX[K(x, y)]
        c:put(x, y, y == J.y1 - (o.base or 2) and GL[nx < 0 and 5 or 4] or GL[nx < 0.3 and 3 or 2], tok)
      end
    end
  end
  -- meniscus: brighter row along the level, curving up 1px at the walls
  if J.level and o.menisc then
    J.inner:each(function(x, y)
      local nx = J.NX[K(x, y)]
      if y == J.level and abs(nx) < 0.8 then c:put(x, y, o.menisc[nx < 0.35 and 1 or 2], tok) end
      if y == J.level - 1 and abs(nx) >= 0.8 and abs(nx) < 0.92 then c:put(x, y, o.menisc[2], tok) end
    end)
  end
  -- main streak (left), a short dim one (right)
  local sy0, sy1 = o.s0 or J.y0 + 3, o.s1 or J.y1 - 4
  for y = sy0, sy1 do
    if not (o.gaps and o.gaps[y]) then
      local h = J.hw(y)
      local x = floor(J.cx - h * 0.62 + 0.5)
      if J.inner:has(x, y) then c:put(x, y, GL[6], tok) end
      if y > sy0 + 1 and y < sy0 + (o.wide or 9) and J.inner:has(x + 1, y) then c:put(x + 1, y, GL[5], tok) end
    end
  end
  for y = (o.r0 or sy0 + 2), (o.r1 or sy0 + 7) do
    local x = floor(J.cx + J.hw(y) * 0.6 + 0.5)
    if J.inner:has(x, y) then c:put(x, y, GL[5], tok) end
  end
  return tok
end

-- lit sphere clipped to clip mask
function A.ball(c, cx, cy, r, ramp, clip, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  if clip then m:clip(clip) end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  A.lit(c, m, n, ramp, o)
  return m, n
end

-- straight lit rod (rounded ends) A->B half width w, clipped
function A.rod(c, ax, ay, bx, by, w, ramp, clip, o)
  o = o or {}
  local m, n, T, S = G.tube({ { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } },
    function() return w end, 60)
  if clip then m:clip(clip) end
  A.lit(c, m, n, ramp, o)
  return m, n, T, S
end

-- twisted cord band along a polyline (2 alternating tones + shade on the right)
function A.cord(c, pts, tw, tok)
  local m = c:line(pts, 1)
  m:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and tw[3] or tw[2], tok) end)
  return m
end

-- bias pixels of target near the edge of `hole` mask outside it (AO ring)
A.cast, A.ao = G.cast, X.ao
function A.fin(c) G.save2(c, A.name) end
return A
