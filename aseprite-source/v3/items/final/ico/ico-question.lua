-- ico-question (Opus single pass). A bold, slim-stroked question mark in glossy teal enamel: ball terminal at the
-- start of the hook, the stroke swelling over the arch and tapering into a short stem; separate round dot.
-- Material: per-pixel tube light (6-tone teal, cool-violet shade), a cream specular streak running along the lit
-- side of the arch, cool reflected light on the lower-right edges, AO where the ball terminal tucks under the
-- arch and a contact shadow on the dot under the stem.
-- quirk: a two-leaf sprout has grown out of the top of the arch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA8_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = A.new("ico-question")
local TEAL = { "#1f2f5e", "#244c7e", "#2a75a0", "#3aa0b8", "#6cccc8", "#b4f0dc" }
local LEAF = { "#173f36", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local BOUNCE = "#5a6ab8"
local ttok = { r = { name = "teal" } }

-- stroke: start (upper-left, just right of the ball) -> over the arch -> down to the stem
local curves = {
  { { 20, 26 }, { 20, 17 }, { 28, 13.5 }, { 34, 13.5 } },
  { { 34, 13.5 }, { 41, 13.5 }, { 46, 18 }, { 45.5, 24 } },
  { { 45.5, 24 }, { 45, 30 }, { 34, 31 }, { 34, 38 } },
  { { 34, 38 }, { 34, 39.5 }, { 34, 41 }, { 34, 42 } },
}
local function hw(t)
  if t < 0.12 then return 3.3 + t / 0.12 * 0.5 end
  if t < 0.55 then return 3.8 + 0.4 * sin((t - 0.12) / 0.43 * pi) end
  return 3.8 - (t - 0.55) / 0.45 * 0.6
end
local m, n, T, S, sm, L = A.tubeN(curves, hw)
-- ball terminal (sits slightly in front-left of the stroke start)
local ball = c:ellipse(19.5, 27.5, 4.5, 4.5)
local bn = X.sphere(19.1, 27.1, 4.5, ball)
-- stroke first (ball overlaps it)
local bias = {}
m:each(function(x, y) local k = K(x, y)
  if ball:grow(1):has(x, y) and not ball:has(x, y) then bias[k] = -1 end end)  -- AO under the ball
local sidx = A.tone(c, m, n, TEAL, { amb = 0.05, wrap = 0.2, bias = bias, tok = ttok, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 } })
-- dot first-class sphere, separated from the stem by air
local dot = c:ellipse(34, 53, 4.2, 4.2)
local dn = X.sphere(33.6, 52.6, 4.2, dot)
local dbias = {}
dot:each(function(x, y) if y <= 49 and abs(x - 34) < 2 then dbias[K(x, y)] = -1 end end)  -- stem casts on dot top
local didx = A.tone(c, dot, dn, TEAL, { amb = 0.05, wrap = 0.2, bias = dbias, tok = ttok, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 } })
local btok = { r = { name = "tealball" } }
local bidx = A.tone(c, ball, bn, TEAL, { amb = 0.05, wrap = 0.2, tok = btok, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 } })
-- separation line where the ball meets the stroke (same colour family)
ball:edge():each(function(x, y)
  for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 }, { 0, -1 } } do
    if m:has(x + d[1], y + d[2]) and not ball:has(x + d[1], y + d[2]) then c:put(x, y, TEAL[2], btok) break end end end)

-- reflected cool light: lower-right grazing edges of stroke, ball and dot
local function bounce(mask, nn, tok)
  local r = X.rim(nn)
  mask:edge():each(function(x, y) local k = K(x, y) if r[k] and r[k] > 0.72 then c:put(x, y, BOUNCE, tok) end end)
end
local stroke = m:copy():cut(ball)
bounce(stroke, n, ttok) bounce(dot, dn, ttok)
-- specular streak along the lit side of the arch (follows the tube), plus one glint
for i, s in ipairs(sm) do
  if s.t > 0.16 and s.t < 0.46 then
    local x = floor(s.x - s.px * s.w * 0.38 + .5) local y = floor(s.y - s.py * s.w * 0.38 + .5)
    if stroke:has(x, y) then c:put(x, y, (s.t > 0.22 and s.t < 0.36) and A.SPEC or TEAL[6], ttok) end
  end
end
c:put(17, 25, A.SPEC, btok) c:put(18, 25, TEAL[6], btok) c:put(17, 26, TEAL[6], btok)
c:put(32, 51, A.SPEC, ttok) c:put(33, 51, TEAL[6], ttok)

-- quirk: sprout out of the top of the arch (stalk 1 px, two leaves)
local ltok = { r = { name = "sprout" } }
A.paintMap(c, {
  "kLLl...ll.",
  ".kLLl.lLLk",
  "..kks.LLk.",
  "....sk....",
  "....s.....",
}, 29, 5, { L = LEAF[4], l = LEAF[5], k = LEAF[2], s = LEAF[3] }, ltok)
A.save(c)
