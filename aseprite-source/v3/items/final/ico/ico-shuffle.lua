-- ico-shuffle (final, Opus). The shuffle sign as two real arrows: slim enamel-glazed shafts (sea blue and moss
-- green) run level, swap places through an S-curve and end in faceted arrowheads; feather fletching on the tails.
-- Material: per-pixel tube light (6-tone, glossy specular streak on the lit side, cool bounce underneath),
-- two-facet heads with a lit ridge, feather vanes with barb lines and a dark quill, AO + contact shadow where
-- the green arrow crosses over the blue one.
-- quirk: one pink fletching feather has come loose and is drifting away.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-shuffle")
local SEA   = { "#22335e", "#2a4a7a", "#3a76a8", "#4fa4c4", "#7fd0d8", "#c4f4e8" }
local MOSS  = { "#1c3f38", "#24544a", "#3f9150", "#62b455", "#96d468", "#d2ec96" }
local PETAL = { "#7d2c5e", "#c94f84", "#f5809f", "#ffaac0", "#ffd8e4" }
local QUILL = "#6e2038"

local function arrow(ramp, p, hy, bounce, under)
  local tok = { r = { name = ramp[3] } }
  -- fletching (drawn first, shaft over its root)
  local tx, ty = p[1][1], p[1][2]
  local ftok = { r = { name = "fletch" .. ramp[3] } }
  for _, sd in ipairs{ -1, 1 } do
    local vm = c:poly{ { tx + 9, ty + sd * 2 }, { tx + 1, ty + sd * 2 }, { tx - 2, ty + sd * 7 }, { tx + 5, ty + sd * 7 } }
    local fi = A.pil(c, vm, 1.4, PETAL, { tok = ftok })
    -- barbs: slanted lines every 2 px
    vm:each(function(x, y)
      local d = abs(y - ty)
      if (x + floor(d * 0.75)) % 3 == 0 then A.step(c, fi, PETAL, x, y, -1, ftok) end
      if d == 7 then A.step(c, fi, PETAL, x, y, sd < 0 and 1 or -1, ftok) end
    end)
  end
  -- shaft tube
  local m, n, T, S = A.tube(p, function(t) return 2.7 end)
  local bias = {}
  if under then
    X.ao(bias, m, under, 1, -1)
    A.cast(bias, m, under, 1, 2, -1)
  end
  local idx = A.shade(c, m, n, ramp, { tok = tok, bias = bias, amb = 0.06, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    if s > 0.8 and T[k] > 0.08 then c:put(x, y, bounce, tok) end
  end)
  -- glossy specular streak on the lit side (broken dashes)
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    if s > -0.6 and s < -0.2 and ((T[k] > 0.1 and T[k] < 0.26) or (T[k] > 0.76 and T[k] < 0.92)) and not (bias[k]) then
      c:put(x, y, ramp[6], tok)
    end
  end)
  -- nock at the tail end
  c:put(tx - 1, ty, QUILL, ftok) c:put(tx - 1, ty - 1, QUILL, ftok) c:put(tx - 1, ty + 1, QUILL, ftok)
  -- head: concave-backed triangle, two facets with a ridge
  local hx = p[4][1] - 1
  local hm = c:poly{ { hx, hy - 8 }, { hx + 13, hy }, { hx, hy + 8 }, { hx + 3, hy } }
  local hn = X.pillow(hm, 1.6)
  local nn = {}
  hm:each(function(x, y) local k = K(x, y) local q = hn[k]
    local f = (y < hy) and -0.55 or (y > hy and 0.55 or 0)
    nn[k] = { A.norm(q[1] * 0.8 + 0.15, q[2] * 0.6 + f, q[3]) }
  end)
  local hb = {}
  hm:each(function(x, y) if x <= hx + 1 then hb[K(x, y)] = -1 end end)
  local hi = A.shade(c, hm, nn, ramp, { tok = tok, bias = hb, amb = 0.06, wrap = 0.2 })
  for x = hx + 3, hx + 10 do if hm:has(x, hy) then c:put(x, hy, ramp[x < hx + 8 and 5 or 6], tok) end end
  c:put(hx + 5, hy - 2, ramp[6], tok)
  if hm:has(hx + 4, hy - 3) then c:put(hx + 4, hy - 3, A.SPEC, tok) end
  local all = m:copy():add(hm)
  return all
end

local blue = arrow(SEA, { { 10, 19 }, { 29, 19 }, { 31, 45 }, { 44, 45 } }, 45, "#4a5c9a")
arrow(MOSS, { { 10, 45 }, { 29, 45 }, { 31, 19 }, { 44, 19 } }, 19, "#2e6a6a", blue)

-- quirk: a loose pink feather drifting off
local ltok = { r = { name = "loose" } }
A.map(c, {
  "..ab",
  ".abb",
  "abbc",
  "qbc.",
  "q...",
}, 10, 29, { a = PETAL[5], b = PETAL[4], c = PETAL[2], q = QUILL }, ltok)

A.save(c, "ico-shuffle")
