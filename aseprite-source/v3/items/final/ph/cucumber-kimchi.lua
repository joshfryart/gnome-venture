-- cucumber-kimchi (final, Opus single pass). Oi-sobagi: three short, slim cucumber segments standing in a dark glazed
-- onggi bowl of red brine. Each segment is cross-cut at the top and slit down the side, stuffed with chili-red radish
-- and green chive ends; striped bumpy skin, pale lime flesh ring, sesame on the stuffing. The bowl has a lit rim,
-- a finger-drawn wave in the glaze, a specular streak, a foot ring and a ground shadow.
-- quirk: a bead of red brine has run over the lip and is dripping down the bowl's front.
local NAME = "cucumber-kimchi"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SKIN = { "#10301f", "#184a2a", "#226634", "#33843e", "#55a448", "#8cc865" }
local FLESH = { "#5f8a3c", "#9cc35c", "#cde68a", "#eef8c0" }
local RED = { "#5a1424", "#8c1f2a", "#bd3328", "#e0512e", "#f5813f", "#ffb366" }
local GLAZE = { "#24141c", "#3c2022", "#5a3226", "#7a482e", "#9c6438", "#c48a52" }
local CHIVE = { "#2c6a2a", "#4f9a3a", "#86c656" }
local SES = "#f3e2b0"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

local BX, BY, RX, RY = 32, 40, 19, 4.2
c:groundShadow(32, 56, 16, 2)
-- inside: brine surface (back half visible, pieces stand in it)
local inner = c:ellipse(BX, BY, RX - 2, RY - 1.2)
local btok = A.tok("brine")
inner:each(function(x, y)
  local i = (y < BY - 1) and 2 or (y < BY + 1) and 3 or 4
  if x > BX + 10 then i = i - 1 end
  c:put(x, y, RED[max(1, i)], btok)
end)

-- cucumber segments
local function piece(cx, top, bot, hw, name, chive)
  local tok = A.tok(name)
  local body = HP.rect(cx - hw, top, cx + hw, bot)
  local n = {}
  body:each(function(x, y)
    local nx = max(-0.95, min(0.95, (x - cx) / (hw + 0.6)))
    n[K(x, y)] = { norm(nx, 0.05, sqrt(1 - nx * nx)) }
  end)
  local bias = {}
  body:each(function(x, y) if y >= BY - 2 then bias[K(x, y)] = -1 end end)   -- ambient where it sinks into brine
  local idx = A.shade(c, body, n, SKIN, { tok = tok, bias = bias, amb = 0.1, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  body:each(function(x, y) local k = K(x, y)
    local i = idx[k]
    if (x - cx + hw) % 3 == 1 and y > top + 2 then i = i + 1 end                         -- pale stripes
    if X.hash(x, y, 3) > 0.86 and y > top + 2 and abs(x - cx) < hw then i = i + 2 end     -- warts
    c:put(x, y, SKIN[max(1, min(6, i))], tok)
  end)
  -- cut top: flesh ring with skin edge
  local cap = c:ellipse(cx, top, hw, 1.4)
  cap:each(function(x, y)
    local d = ((x - cx) / (hw + .5))^2 + ((y - top) / 1.9)^2
    local col = d > 0.7 and SKIN[3] or (x < cx and FLESH[4] or FLESH[3])
    c:put(x, y, col, tok)
  end)
  -- side slit, stuffed
  local sl = floor(top + (bot - top) * 0.6)
  for y = top + 1, sl do
    c:put(cx - 1, y, RED[3], tok) c:put(cx, y, RED[2], tok)
    if y < sl then c:put(cx - 2, y, SKIN[2], tok) end
  end
  c:put(cx - 1, top + 2, RED[5], tok)
  -- stuffing mound on top
  local mound = c:ellipse(cx, top - 1.5, hw - 1.2, 1.8)
  local mn = X.sphere(cx - 0.4, top - 1.6, hw - 1, mound)
  A.shade(c, mound, mn, RED, { tok = tok, amb = 0.15, wrap = 0.3 })
  -- sesame specks
  c:put(cx - 1, floor(top - 2), SES, tok) c:put(cx + 1, floor(top - 1), SES, tok)
  -- chive ends poking up
  for j, ch in ipairs(chive) do
    for s = 0, ch[3] do c:put(cx + ch[1] + floor(s * ch[2] + .5), floor(top - 2.5) - s, CHIVE[(j % 2 == 0) and 1 or (s < 1 and 1 or 2)], tok) end
    c:put(cx + ch[1] + floor(ch[3] * ch[2] + .5), floor(top - 2.5) - ch[3] - 1, CHIVE[3], tok)
  end
  return body
end
local pa = piece(24, 22, 42, 4, "pieceA", { { -1, -0.4, 4 }, { 1, 0.2, 5 } })
local pb = piece(40, 25, 42, 4, "pieceB", { { 0, 0.4, 4 }, { -2, -0.2, 3 } })
-- AO on the back pieces where the front piece will stand
local pc = piece(32, 30, 43, 3.5, "pieceC", { { 0, -0.3, 3 }, { 2, 0.3, 2 } })
for _, side in ipairs{ { 27, -1 }, { 28, -1 }, { 36, 1 } } do
  for y = 32, 40 do local x = side[1] if pa:has(x, y) or pb:has(x, y) then c:put(x, y, SKIN[1], A.tok("ao")) end end
end

-- bowl body (covers the pieces' feet outside the opening)
local gtok = A.tok("bowl")
local body = HP.mask()
for y = floor(BY), BY + 12 do for x = BX - RX - 1, BX + RX + 1 do
  local dx, dy = (x - BX) / (RX + .5), (y - BY) / 12.5
  if dx * dx + dy * dy <= 1 and not inner:has(x, y) then body:set(x, y) end
end end
body:add(c:ellipse(BX, BY, RX, RY):cut(inner))
local foot = HP.rect(24, 51, 40, 54)
local fn = {}
foot:each(function(x, y) local nx = max(-.95, min(.95, (x - 32) / 9)) fn[K(x, y)] = { norm(nx, 0.3, sqrt(1 - nx * nx)) } end)
A.shade(c, foot, fn, GLAZE, { tok = gtok, amb = 0.08, wrap = 0.2 })
for x = 25, 39 do c:put(x, 51, GLAZE[1], gtok) end
local bn = {}
body:each(function(x, y)
  local nx = (x - BX) / (RX + 1)
  local ny = max(-0.3, (y - BY) / 14)
  local q = 1 - nx * nx - ny * ny
  bn[K(x, y)] = { norm(nx, ny, sqrt(max(q, 0.04))) }
end)
local gidx = A.shade(c, body, bn, GLAZE, { tok = gtok, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- rim ring: lit lip
local rim = c:ellipse(BX, BY, RX, RY):cut(inner)
rim:each(function(x, y)
  local i = (y < BY) and 5 or 6
  if x > BX + 9 then i = i - 1 end
  if y < BY - 2 then i = 3 end           -- back lip, seen from above, darker
  c:put(x, y, GLAZE[i], gtok)
end)
-- finger-drawn wave around the belly
for x = BX - 16, BX + 16 do
  local y = floor(BY + 6.5 + 1.3 * sin((x - BX) * 0.55) + .5)
  if body:has(x, y) and body:has(x, y + 1) then
    local i = (gidx[K(x, y)] or 3) + 1
    c:put(x, y, GLAZE[min(6, i)], gtok) c:put(x, y + 1, GLAZE[max(1, i - 3)], gtok)
  end
end
-- ambient row under the lip
for x = BX - RX + 1, BX + RX - 1 do
  local y = floor(BY + RY * sqrt(max(0, 1 - ((x - BX) / (RX + .5))^2)) + 1.5)
  if body:has(x, y) and not rim:has(x, y) then c:put(x, y, GLAZE[max(1, (gidx[K(x, y)] or 3) - 1)], gtok) end
end
-- specular streak on the glaze, left
for _, q in ipairs{ { 17, 43 }, { 17, 44 }, { 18, 45 }, { 18, 46 } } do c:put(q[1], q[2], "#e6c49a", gtok) end
c:put(17, 42, A.CREAM, gtok)
-- brine gloss
c:put(29, 39, RED[6], btok) c:put(30, 39, RED[5], btok)

-- quirk: brine drip over the front lip
local dtok = A.tok("drip")
for _, q in ipairs{ { 36, 44, 4 }, { 36, 45, 3 }, { 36, 46, 3 }, { 36, 47, 2 }, { 35, 48, 3 }, { 36, 48, 3 }, { 35, 49, 2 }, { 36, 49, 1 } } do c:put(q[1], q[2], RED[q[3]], dtok) end
c:put(35, 48, RED[5], dtok)
A.save(c, NAME)
