-- horseradish (final, Opus single pass). A slim, knobbly cream taproot on a gentle diagonal (crown top, fine tip
-- lower-right), with three long wavy-edged dock-like leaves on pale petioles fanning up from a dark sunken crown.
-- Material: per-pixel cylinder light (6-tone cream-tan, cool-violet shade), many fine transverse wrinkles (dark groove
-- + lit lip), brown lenticel dashes, a shoulder specular, cool reflected light on the lower-right edge, AO at the crown.
-- Leaves: 6-tone V-fold light, pale midrib, side veins, cool shade margin, a dark line where leaves overlap.
-- quirk: one rootlet has curled itself into a neat pigtail.
local NAME = "horseradish"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local ROOT = { "#4e3236", "#7c5a4a", "#a8845e", "#cdac7e", "#e7cc9e", "#f8ebc4" }
local BOUNCE, SPEC = "#8f8098", "#fff4d6"
local L = A.LEAF

-- leaves, back to front
local CX, CY = 29, 26
local l1 = A.wavyLeaf(c, { CX - 1, CY }, { 20, 18 }, { 11, 9 }, 3.4, { freq = 32, per = 4.0 })
local l2 = A.wavyLeaf(c, { CX + 1, CY }, { 38, 17 }, { 47, 10 }, 3.2, { freq = 28, per = 4.0 })
local l3 = A.wavyLeaf(c, { CX, CY }, { 29, 17 }, { 26, 6 }, 3.8, { freq = 34, per = 4.4, pet = 0.22 })
A.sep(c, l3, l1, L[1]) A.sep(c, l3, l2, L[1])

-- root
local p = { { CX, CY + 1 }, { 30, 37 }, { 35, 47 }, { 41, 57 } }
local function hw(t)
  if t < 0.06 then return 3.4 + (t / 0.06) * 1.5 end
  return (4.9 * ((1 - t) / 0.94) ^ 0.72) * (1 + 0.07 * sin(t * 38)) + 0.3
end
local rm, rn, RT, RS, samp = A.tube(p, hw)
local rtok = { r = { name = "root" } }
local bias = {}
rm:each(function(x, y) local k = K(x, y) if RT[k] < 0.05 then bias[k] = -1 end end)
local v = X.light(rn, { amb = 0.08, wrap = 0.24 })
local idx = X.tone(c, rm, v, ROOT, { cuts = { 0.18, 0.34, 0.5, 0.67, 0.86 }, bias = bias, tok = rtok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- fine transverse wrinkles (partial, staggered)
local rings = { { 0.14, -0.7, 0.5 }, { 0.22, -0.3, 0.85 }, { 0.3, -0.75, 0.2 }, { 0.38, -0.2, 0.85 }, { 0.47, -0.7, 0.45 },
  { 0.56, -0.4, 0.85 }, { 0.65, -0.75, 0.3 }, { 0.74, -0.3, 0.8 }, { 0.84, -0.6, 0.6 } }
rm:each(function(x, y) local k = K(x, y)
  local t, s = RT[k], RS[k]
  for _, r in ipairs(rings) do
    local d = (t - r[1]) * LEN + s * s * 1.2
    if s > r[2] and s < r[3] then
      local cur = idx[k] or 3
      if d > -0.5 and d < 0.5 then c:put(x, y, ROOT[max(1, cur - 2)], rtok)
      elseif d >= -1.5 and d <= -0.5 and s < 0.2 and cur >= 3 then c:put(x, y, ROOT[min(6, cur + 1)], rtok) end
    end
  end
end)
-- lenticels: short brown dashes across the root
for _, q in ipairs{ { 0.18, 0.3 }, { 0.34, -0.45 }, { 0.43, 0.4 }, { 0.6, -0.2 }, { 0.7, 0.35 } } do
  local s = samp[floor(q[1] * 160) + 1]
  for d = -0.5, 0.5, 0.5 do
    local x, y = floor(s.x + s.px * s.w * q[2] + s.tx * 0 + s.px * d + .5), floor(s.y + s.py * s.w * q[2] + s.py * d + .5)
    if rm:has(x, y) then c:put(x, y, ROOT[2], rtok) end
  end
end
-- cool reflected light lower-right edge
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.7 and RS[k] > 0.75 and RT[k] > 0.1 and RT[k] < 0.82 then c:put(x, y, BOUNCE, rtok) end end)
-- shoulder specular streak + glint
for _, q in ipairs{ { 0.09, -0.5 }, { 0.12, -0.5 }, { 0.15, -0.48 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), ROOT[6], rtok)
end
do local s = samp[floor(0.1 * 160) + 1] c:put(floor(s.x + s.px * s.w * -0.5 + .5), floor(s.y + s.py * s.w * -0.5 + .5), SPEC, rtok) end
-- sunken crown with cut petiole bases
local crown = A.rell(CX, CY + 1.2, 0.0, 1.0, 1.4, 3.0)
crown:each(function(x, y) if rm:has(x, y) then c:put(x, y, ROOT[1], rtok) end end)
c:put(CX - 2, CY, "#5b9a52") c:put(CX - 1, CY, "#2e6a44") c:put(CX, CY, "#8cc066") c:put(CX + 1, CY, "#2e6a44") c:put(CX + 2, CY, "#5b9a52")
-- dark AO row on leaves just above the crown
for x = CX - 2, CX + 2 do if c:get(x, CY - 1) then c:put(x, CY - 1, L[2]) end end

-- rootlets: a short straight one on the left, a pigtail on the right (quirk)
local function edgePt(t, side)
  local s = samp[floor(t * 160) + 1]
  local w = s.w + 0.6
  return floor(s.x + s.px * w * side + .5), floor(s.y + s.py * w * side + .5)
end
local ltok = { r = { name = "rootlet" } }
do local x, y = edgePt(0.62, -1)
  A.line(c, { { x, y }, { x - 2, y + 2 }, { x - 3, y + 4 } }, ROOT[3], ltok) c:put(x, y, ROOT[4], ltok) end
do local x, y = edgePt(0.36, 1)
  A.line(c, { { x, y }, { x + 2, y }, { x + 4, y - 1 } }, ROOT[3], ltok)
  local cx, cy, r = x + 7.5, y + 1.5, 3.3
  local pts = {}
  for i = 0, 20 do local a = -pi * 0.85 + i / 20 * 2 * pi * 0.92 pts[#pts + 1] = { cx + r * cos(a), cy + r * sin(a) } end
  for i, q in ipairs(pts) do
    local col = (q[2] < cy and q[1] < cx + 1) and ROOT[4] or ROOT[2]
    c:put(floor(q[1] + .5), floor(q[2] + .5), col, ltok)
  end
end
-- whisker at the tip
do local s = samp[#samp] A.line(c, { { s.x, s.y }, { s.x + 1.5, s.y + 1.5 } }, ROOT[3], ltok) end

A.save(c, NAME)
