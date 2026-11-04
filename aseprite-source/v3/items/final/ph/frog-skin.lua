-- frog-skin (aB32_5, Opus single pass). A flat, splayed frog pelt seen from above: slim body and head, thin bent
-- arms with three toes each, long folded back legs with webbed feet and round toe pads. Wet skin: pillow-lit with a
-- glossy rim, warty bumps (lit top + shadow foot), dark irregular blotches, two pale dorsal ridges, closed eyelid domes,
-- an ambient seam where limbs meet the body.
-- quirk: a single round water bead still sits on its back.
local NAME = "frog-skin"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new(NAME)
local FR = { "#1d4a40", "#2a6a46", "#3d8c48", "#5fae4e", "#94cd5e", "#d0ea8c" }
local PAD = { "#6e8a3a", "#a6b84e", "#d8d870", "#f2eca0" }
local SEA = { "#2a4a7a", "#3a86b0", "#7fd2dc", "#c8f4ec" }

local function mirror(p) local q = {} for i, v in ipairs(p) do q[i] = { 64 - v[1], v[2] } end return q end
-- limbs: {path, w0, w1, toes{ {dx,dy} ... }}
local limbs = {
  { { { 28, 24 }, { 21, 26 }, { 16, 23 }, { 13, 17 } }, 1.9, 1.3 },
  { { { 28, 39 }, { 20, 40 }, { 13, 44 }, { 15, 52 } }, 2.6, 1.5 },
}
local legs = HP.mask()
local toes = {}
local function addLimb(p, w0, w1)
  local m = A.tube(p, function(t) return w0 + (w1 - w0) * t end)
  legs:add(m)
  return p[4]
end
local ends = {}
for _, L in ipairs(limbs) do
  ends[#ends + 1] = { addLimb(L[1], L[2], L[3]), L == limbs[1] and "hand" or "foot", 1 }
  ends[#ends + 1] = { addLimb(mirror(L[1]), L[2], L[3]), L == limbs[1] and "hand" or "foot", -1 }
end
-- toes: thin rays ending in round pads; feet get a web between them
local pads = HP.mask()
for _, e in ipairs(ends) do
  local x0, y0, sd = e[1][1], e[1][2], e[3]
  local rays
  if e[2] == "hand" then rays = { { -4, -3 }, { -1, -5 }, { 2, -5 } }
  else rays = { { -5, 3 }, { -3, 6 }, { 0, 7 }, { 3, 6 } } end
  local tipPts = {}
  for _, r in ipairs(rays) do
    local tx, ty = x0 + r[1] * sd, y0 + r[2]
    legs:add(c:line({ { x0, y0 }, { tx, ty } }, 1))
    pads:add(A.disc(tx, ty, 0.9))
    tipPts[#tipPts + 1] = { tx, ty }
  end
  if e[2] == "foot" then
    local poly = { { x0, y0 } }
    for i = 1, #tipPts do local t = tipPts[i] poly[#poly + 1] = { x0 + (t[1] - x0) * 0.7, y0 + (t[2] - y0) * 0.7 } end
    legs:add(c:poly(poly))
  end
end
local body = HP.mask()
body:add(c:ellipse(32, 31, 7, 10.5))
body:add(c:ellipse(32, 16, 7, 5.5))
body:add(c:ellipse(32, 22, 5, 4))
legs:cut(body)

-- limbs first, darker in a ring around the body (ambient seam)
local lbias = {}
X.ao(lbias, legs, body, 1, -2)
local ltok = { r = { name = "frog" } }
local nl = X.pillow(legs, 1.6, 0.8)
local lidx = A.shade(c, legs, nl, FR, { tok = ltok, bias = lbias, cuts = { 0.18, 0.34, 0.52, 0.7, 0.88 } })
c:fillMask(pads:copy():cut(body), PAD[3])
pads:each(function(x, y) if not body:has(x, y) then
  local up = not pads:has(x - 1, y) or not pads:has(x, y - 1)
  local dn = not pads:has(x + 1, y) or not pads:has(x, y + 1)
  c:put(x, y, up and PAD[4] or (dn and PAD[2] or PAD[3]), ltok) end end)

-- body
local btok = { r = { name = "frog" } }
local nb, db = X.pillow(body, 3.5, 0.8)
local bidx = A.shade(c, body, nb, FR, { tok = btok, cuts = { 0.18, 0.34, 0.52, 0.7, 0.88 } })
-- dorsal ridges (pale folds from behind the eyes to the hips)
for y = 18, 39 do
  local t = (y - 18) / 21
  local dx = 4.2 + 1.6 * sin(t * 3.0) - t * 1.5
  for _, sd in ipairs{ -1, 1 } do
    local x = floor(32 + sd * dx + 0.5)
    if body:has(x, y) then c:put(x, y, sd < 0 and FR[6] or FR[5], btok)
      if body:has(x + 1, y) then c:put(x + 1, y, FR[max(1, (bidx[K(x + 1, y)] or 3) - 1)], btok) end end
  end
end
-- blotches
local all = body:copy():add(legs)
local idx = {}
for k, v in pairs(lidx) do idx[k] = v end for k, v in pairs(bidx) do idx[k] = v end
for _, s in ipairs{ { 30, 27, 1.6, 1.2 }, { 35, 32, 1.4, 1.6 }, { 29, 36, 1.8, 1.3 }, { 34, 38, 1.3, 1.1 }, { 33, 22, 1.2, 1.0 },
                    { 19, 41, 1.4, 1.1 }, { 45, 41, 1.4, 1.1 }, { 15, 47, 1.0, 1.3 }, { 49, 47, 1.0, 1.3 }, { 20, 25, 1.0, 0.9 }, { 44, 25, 1.0, 0.9 } } do
  local m = c:ellipse(s[1], s[2], s[3], s[4]):clip(all)
  m:each(function(x, y) local k = K(x, y) local i = max(1, (idx[k] or 3) - 2) idx[k] = i c:put(x, y, FR[i], btok) end)
end
-- warts: lit top, dark foot
for y = 10, 56 do for x = 10, 54 do
  local k = K(x, y)
  if all:has(x, y) and all:has(x + 1, y + 1) and all:has(x - 1, y - 1) and X.hash(x, y, 7) < 0.07 then
    A.step(c, idx, FR, x, y, 1, btok) A.step(c, idx, FR, x + 1, y + 1, -1, btok)
  end
end end
-- wet gloss: specular rim on lit edges
local sp = X.spec(nb, 18)
body:each(function(x, y) local k = K(x, y) if sp[k] and sp[k] > 0.62 then c:put(x, y, FR[6], btok) idx[k] = 6 end end)
-- closed eyelid domes with a dark slit
for _, e in ipairs{ { 28, 13 }, { 36, 13 } } do
  local d = c:ellipse(e[1], e[2], 2.5, 2)
  d:each(function(x, y) local dx, dy = x - e[1], y - e[2]
    c:put(x, y, (dx + dy < -1) and FR[6] or ((dx + dy > 1.5) and FR[3] or FR[5]), btok) end)
  for dx = -2, 2 do c:put(e[1] + dx, e[2] + 1 + (abs(dx) == 2 and -1 or 0), FR[1], btok) end
end
-- nostrils
c:put(30, 18, FR[1], btok) c:put(34, 18, FR[1], btok)

-- quirk: water bead on the back (cast shadow, cool body, cream glint)
local wx, wy = 35, 28
c:put(wx + 1, wy + 2, FR[1], btok) c:put(wx + 2, wy + 1, FR[1], btok) c:put(wx + 2, wy + 2, FR[1], btok)
for _, q in ipairs{ { 0, -1, 3 }, { -1, 0, 3 }, { 0, 0, 3 }, { 1, 0, 2 }, { 0, 1, 2 }, { 1, 1, 1 }, { -1, -1, 4 }, { 1, -1, 3 }, { -1, 1, 2 } } do
  c:put(wx + q[1], wy + q[2], SEA[q[3]], { r = { name = "bead" } })
end
c:put(wx - 1, wy - 1, A.CREAM, { r = { name = "bead" } })

A.save(c, NAME)
