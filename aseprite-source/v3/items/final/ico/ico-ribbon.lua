-- ico-ribbon (final pass, Opus). A satin bow: two slim swept loops (pillow-lit, 6-tone rose) with a dark inner fold
-- where each loop turns back into the knot, two diagonal crease lines with lit lips (cloth folds), a satin specular
-- streak on each upper edge; a small wrapped knot with two pinch wrinkles; two tails hanging behind with V-notched ends,
-- a turned-back underside tone and a dark ambient band where they leave the knot. Gold stitched hem on the right tail.
-- quirk: a loose thread is unravelling from the left tail's notch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-ribbon")
local ROSE = { "#4e1434", "#82224a", "#b8345e", "#e0507a", "#f9829c", "#ffc2cc" }
local KCX, KCY = 32, 24

-- tails (behind)
local ttok = { r = { name = "tail" } }
local tails = {}
local function tail(pts, side)
  local m = HP.poly(pts)
  local n = X.pillow(m, 2.5)
  -- tails twist: the outer half of each tail faces away a little
  local bias = {}
  m:each(function(x, y) if y < KCY + 7 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, ROSE, { amb = 0.1, wrap = 0.3, bias = bias, tok = ttok })
  tails[#tails + 1] = m
  return m, idx
end
local tl, il = tail({ { 29, 26 }, { 33, 28 }, { 24, 50 }, { 21, 46 }, { 16, 49 } }, -1)
local tr, ir = tail({ { 31, 28 }, { 35, 26 }, { 48, 48 }, { 43, 46 }, { 40, 51 } }, 1)
-- fold crease down each tail (cloth)
for t = 0.25, 0.9, 0.02 do
  local x, y = floor(31 + (22 - 31) * t + .5), floor(28 + (47 - 28) * t + .5)
  if tl:has(x, y) then A.step(c, il, ROSE, x, y, -1, ttok) end
  local x2, y2 = floor(33 + (44 - 33) * t + .5), floor(28 + (47 - 28) * t + .5)
  if tr:has(x2, y2) then A.step(c, ir, ROSE, x2, y2, 1, ttok) end
end
-- gold stitched hem along the right tail's outer edge (2 on, 1 off), set two pixels in
do
  local j = 0
  for y = KCY + 8, 44 do
    local mx
    for x = 30, 50 do if tr:has(x, y) then mx = x end end
    if mx then if j % 3 < 2 then c:put(mx - 1, y, "#f5b82e", ttok) end j = j + 1 end
  end
end

-- loops
local ltok = { r = { name = "loop" } }
local function loop(sx)
  local function P(x, y) return { KCX + sx * x, y } end
  local m = HP.poly{ P(1, KCY - 3), P(8, KCY - 9), P(15, KCY - 13), P(19.5, KCY - 13), P(22, KCY - 10), P(22, KCY - 6),
    P(19, KCY - 1), P(13, KCY + 3), P(7, KCY + 3), P(1, KCY + 2) }
  local np = X.pillow(m, 4)
  -- round the loop as a tube bending away from the knot: blend a sphere normal centred on the loop body
  local ns = X.sphere(KCX + sx * 14 - 1, KCY - 5, 9, m)
  local n = {}
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { A.norm(a[1] * 0.5 + b[1] * 0.5, a[2] * 0.5 + b[2] * 0.5, a[3] * 0.5 + b[3] * 0.5) } end
  local bias = {}
  -- inner fold: dark crescent where the loop turns back toward the knot (centre-side inner opening)
  local fold = HP.ellipse(KCX + sx * 6, KCY + 1, 2, 1)
  m:each(function(x, y) if fold:has(x, y) then bias[K(x, y)] = -2 end end)
  local idx = A.shade(c, m, n, ROSE, { amb = 0.08, wrap = 0.3, bias = bias, tok = ltok })
  -- crease lines fanning out from the knot: dark groove + lit lip above it
  for _, cr in ipairs{ { 0.0, -0.45, 16 }, { 0.0, 0.25, 15 } } do
    for s = 3, cr[3] do
      local x = floor(KCX + sx * s + .5)
      local y = floor(KCY - 1 + cr[2] * s + .5)
      if m:has(x, y) and not fold:has(x, y) and m:has(x, y - 1) and m:has(x, y + 1) then
        A.step(c, idx, ROSE, x, y, -2, ltok)
        if s < cr[3] - 2 then A.step(c, idx, ROSE, x, y - 1, 1, ltok) end
      end
    end
  end
  -- satin specular streak along the upper edge
  m:each(function(x, y)
    if not m:has(x, y - 2) and m:has(x, y + 1) and (idx[K(x, y)] or 0) >= 5 and abs(x - KCX) > 8 and abs(x - KCX) < 17 then
      c:put(x, y, ROSE[6], ltok) end
  end)
  return m, idx
end
local lm, lidx = loop(-1)
local rm = loop(1)
c:put(KCX - 13, KCY - 11, A.CREAM, ltok)

-- knot (front)
local ktok = { r = { name = "knot" } }
local km = HP.rrect(KCX - 3, KCY - 5, KCX + 3, KCY + 4, 2)
local kn = X.pillow(km, 3)
local kb = {} km:each(function(x, y) kb[K(x, y)] = 1 end)
local kidx = A.shade(c, km, kn, ROSE, { amb = 0.1, wrap = 0.3, tok = ktok, bias = kb })
-- pinch wrinkles
for y = KCY - 3, KCY + 2 do A.step(c, kidx, ROSE, KCX - 2, y, -1, ktok) end
for y = KCY - 2, KCY + 3 do A.step(c, kidx, ROSE, KCX + 2, y, -2, ktok) end
-- inner line where the knot meets the loops (same ramp: separate in the darker tone)
km:edge():each(function(x, y)
  if x == KCX - 3 or x == KCX + 3 then A.step(c, kidx, ROSE, x, y, -1, ktok) end
end)
c:put(KCX - 1, KCY - 3, ROSE[6], ktok) c:put(KCX, KCY - 3, ROSE[6], ktok)
-- ambient shading on the loops right next to the knot
for _, m in ipairs{ lm, rm } do
  m:each(function(x, y)
    if not km:has(x, y) and (km:has(x + 1, y) or km:has(x - 1, y)) then c:put(x, y, ROSE[1], ltok) end
  end)
end

-- quirk: loose thread curling off the left tail's notch
A.map(c, {
  "a.",
  "a.",
  ".a",
  ".a",
  "a.",
}, 16, 50, { a = ROSE[4] })
A.save(c, "ico-ribbon")
