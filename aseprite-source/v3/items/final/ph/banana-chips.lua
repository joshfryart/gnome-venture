-- banana-chips (aR3_3, final single pass). A shallow, slim woven palm-leaf bowl heaped with golden fried banana
-- chips. Bowl: vertical-cylinder light, brick-weave strands (each strand lit on top, dark groove under), a twisted
-- rope rim with diagonal twist marks, dark inner back rim, 2-tone ground shadow. Chips: flat tilted discs with a
-- 1.5 px bevel, caramel fried edge, pale crisp centre with the three-lobed seed star and faint radial fibres, AO +
-- contact shadow where chips overlap, one sugar glint.
-- quirk: one chip at the front has a neat bite taken out of it and leans against the rim.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../_helpers/_aR3_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local NAME = "banana-chips"
local c = G.new2(NAME)

local WEAVE = { "#2e1c2a", "#4a2a30", "#683c34", "#87553c", "#a8724a", "#c89462" }
local DYE   = { "#1e2a40", "#244a5e", "#2f6e78", "#3f9290", "#62b4a4", "#94d4bc" }
local ROPE  = { "#4e3a34", "#7a6048", "#a08660", "#c2a87a", "#dcc69a", "#efe2bc" }
local CHIP  = { "#6e3426", "#a85a2a", "#d48c34", "#ecb44a", "#f8d474", "#fff0b0" }
local SEED, SEED2, SPEC = "#5e3428", "#8a5530", "#fffbe2"
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }

local CX, RY0 = 32, 37            -- rim centre line
local RX, RRY = 19, 4             -- rim ellipse
local BOT = 52
c:groundShadow(CX, BOT + 1, 15, 2)

-- bowl body: below the rim ellipse, sides curving in to a narrow foot
local body = HP.mask()
for y = RY0 - RRY, BOT do
  local u = (y - RY0) / (BOT - RY0)
  local w = RX * sqrt(max(0, 1 - max(0, u) ^ 2.2)) + 0.3
  if u > 0.8 then w = min(w, 10.5) end
  for x = floor(CX - w + 0.5), floor(CX + w - 0.5) do
    local dx = (x + 0.5 - CX) / RX
    local ytop = RY0 + RRY * sqrt(max(0, 1 - dx * dx)) * 0.0
    if y >= RY0 - 1 then body:set(x, y) end
  end
end
-- back inner wall (dark) visible above the rim line
local inner = c:ellipse(CX, RY0 - 1, RX - 1, RRY)
local btok = { r = { name = "bowl" } }
inner:each(function(x, y) c:put(x, y, (y < RY0 - 2) and WEAVE[2] or WEAVE[1], btok) end)
inner:each(function(x, y) if y <= RY0 - 3 and (x * 2 + y) % 5 == 0 then c:put(x, y, WEAVE[1], btok) end end)

-- chips: {cx, cy, rx, ry, angle, tiltx, tilty}
local chips = {
  { 22, 32, 5.6, 4.0, 0.25, -0.15, -0.55 },
  { 33, 30, 5.8, 4.2, -0.1, 0.1, -0.6 },
  { 43, 32, 5.4, 3.8, -0.35, 0.3, -0.5 },
  { 27, 27, 5.4, 4.6, 0.5, -0.2, -0.3 },
  { 39, 26, 5.6, 4.4, -0.45, 0.2, -0.35 },
  { 32, 22, 5.6, 5.0, 0.15, -0.1, -0.15 },
  { 17, 36, 4.8, 3.2, 0.4, -0.4, -0.7 },
  { 47, 36, 4.8, 3.2, -0.5, 0.4, -0.7 },
}
local function chipMask(ch)
  local m = HP.mask()
  local ca, sa = cos(ch[5]), sin(ch[5])
  for y = floor(ch[2] - 7), floor(ch[2] + 7) do for x = floor(ch[1] - 7), floor(ch[1] + 7) do
    local dx, dy = x - ch[1], y - ch[2]
    local a = (dx * ca + dy * sa) / (ch[3] + 0.4)
    local b = (-dx * sa + dy * ca) / (ch[4] + 0.4)
    if a * a + b * b <= 1 then m:set(x, y) end
  end end
  return m
end
for _, ch in ipairs(chips) do ch.m = chipMask(ch) end
-- keep chips above the front rim only (they sit inside the bowl)
local frontRim = HP.mask()
for x = CX - RX - 1, CX + RX + 1 do
  local dx = (x + 0.5 - CX) / (RX + 0.5)
  if abs(dx) <= 1 then
    local yc = RY0 + RRY * sqrt(1 - dx * dx) * 0.5
    for y = floor(yc - 1 + 0.5), floor(yc + 1 + 0.5) do frontRim:set(x, y) end
  end
end
local function paintChip(ch, later, i)
  local tok = { r = { name = "chip" .. i } }
  local m = ch.m
  local n0 = X.pillow(m, 1.6)
  local n = {}
  for k, nn in pairs(n0) do
    local x, y, z = nn[1] + ch[6] * nn[3], nn[2] + ch[7] * nn[3], nn[3]
    n[k] = { G.norm(x, y, z) }
  end
  local bias = {}
  if later then X.ao(bias, m, later, 1, -1) G.cast(bias, m, later, -1, -1, -1) end
  local d = X.dist(m)
  -- fried caramel edge: outer ring one step darker
  m:each(function(x, y) local k = K(x, y) if d[k] < 1.0 then bias[k] = (bias[k] or 0) - 1 end end)
  local idx = X.tone(c, m, X.light(n, { amb = 0.18, wrap = 0.3 }), CHIP, { cuts = CUTS, bias = bias, tok = tok })
  -- pale crisp core (chip space r < 2.4) and three small seed dots around the centre
  local ca, sa = cos(ch[5]), sin(ch[5])
  local function at(a, r)  -- polar in chip space
    local u, v = cos(a) * r * ch[3] / 5.5, sin(a) * r * ch[4] / 5.5
    return floor(ch[1] + u * ca - v * sa + 0.5), floor(ch[2] + u * sa + v * ca + 0.5)
  end
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - ch[1], y - ch[2]
    local u = (dx * ca + dy * sa) / ch[3] * 5.5
    local v = (-dx * sa + dy * ca) / ch[4] * 5.5
    if u * u + v * v < 2.4 * 2.4 and not bias[k] then c:put(x, y, CHIP[min(6, (idx[k] or 4) + 1)], tok) end
    if d[k] < 1.0 and not (later and later:has(x, y)) then c:put(x, y, (idx[k] or 3) <= 3 and CHIP[2] or CHIP[3], tok) end
  end)
  for j = 0, 2 do
    local a = ch[5] + j * 2 * pi / 3 + i * 0.7
    local x, y = at(a, 1.3) if m:has(x, y) and not bias[K(x, y)] then c:put(x, y, SEED2, tok) end
  end
  return idx, n, tok
end
local all = HP.mask()
for i = #chips, 1, -1 do all:add(chips[i].m) end
local order = { 6, 4, 5, 2, 1, 3, 7, 8 }
for oi, i in ipairs(order) do
  local later = HP.mask()
  for oj = oi + 1, #order do later:add(chips[order[oj]].m) end
  later:add(frontRim) later:add(body:copy():cut(inner))
  chips[i].m:cut(body:copy():cut(inner):cut(frontRim))
  chips[i].idx, chips[i].n, chips[i].tok = paintChip(chips[i], later, i)
end
-- glint on the top chip
do local ch = chips[6] local bx, by = G.specAt(ch.m, ch.n, 30) c:put(bx, by, SPEC, ch.tok) c:put(bx + 1, by, CHIP[6], ch.tok) end

-- bowl body (in front): vertical cylinder light + brick weave
local bodyF = body:copy():cut(inner)
local bn = {}
bodyF:each(function(x, y)
  local u = (y - RY0) / (BOT - RY0)
  local w = RX * sqrt(max(0.02, 1 - max(0, u) ^ 2.2))
  local s = max(-0.97, min(0.97, (x + 0.5 - CX) / (w + 0.5)))
  local ny = 0.35 + u * 0.4
  bn[K(x, y)] = { G.norm(s, ny * sqrt(1 - s * s), sqrt(1 - s * s)) }
end)
local bias = {}
X.ao(bias, bodyF, all, 1, -1)
bodyF:each(function(x, y) local k = K(x, y)
  local dx = (x + 0.5 - CX) / RX
  local yr = y - (RY0 + RRY * sqrt(max(0, 1 - dx * dx)) * 0.5)
  local row = floor(yr / 3)
  local ph = yr - row * 3
  local col = floor((x + (row % 2) * 2.5) / 5)
  local cx = (x + (row % 2) * 2.5) - col * 5
  if ph < 1 then bias[k] = (bias[k] or 0) - 2           -- groove between rows
  elseif cx < 1 then bias[k] = (bias[k] or 0) - 1       -- strand gap
  elseif ph < 2 then bias[k] = (bias[k] or 0) + 1 end    -- lit strand top
end)
local bidx = G.toneN(c, bodyF, bn, WEAVE, { tok = btok, bias = bias, amb = 0.12, wrap = 0.35, cuts = CUTS })
-- one dyed band of teal strands (two rows below the rim)
bodyF:each(function(x, y) local k = K(x, y)
  local dx = (x + 0.5 - CX) / RX
  local yr = y - (RY0 + RRY * sqrt(max(0, 1 - dx * dx)) * 0.5)
  if yr >= 4 and yr < 6 and not ((x + 2.5) % 5 < 1) then c:put(x, y, DYE[min(6, (bidx[k] or 3) + 1)], btok) end
end)
-- foot ring: darker underside rows
bodyF:each(function(x, y) if y >= BOT - 1 then c:put(x, y, WEAVE[1], btok) end end)

-- twisted rope rim across the front
local rtok = { r = { name = "rope" } }
local rn = {}
local RCY = {}
frontRim:each(function(x, y)
  local dx = (x + 0.5 - CX) / (RX + 0.5)
  local yc = RY0 + RRY * sqrt(max(0, 1 - dx * dx)) * 0.5
  local s = max(-0.95, min(0.95, (y - yc) / 2))
  rn[K(x, y)] = { G.norm(dx * 0.5, s, sqrt(1 - s * s)) }
  RCY[K(x, y)] = yc
end)
local rb = {}
frontRim:each(function(x, y) local k = K(x, y)
  local ph = (x + (y - RCY[k]) * 1.2) % 4
  if ph < 1 then rb[k] = -2 elseif ph < 2 then rb[k] = 1 end
end)
G.toneN(c, frontRim, rn, ROPE, { tok = rtok, bias = rb, amb = 0.15, wrap = 0.35, cuts = CUTS })

-- quirk: bitten chip leaning on the front rim
do
  local ch = { 25, 41, 4.6, 4.8, 0.2, -0.45, -0.1 }
  local m = chipMask(ch)
  m:cut(c:ellipse(29.5, 37.5, 2.2, 2.2)):cut(c:ellipse(27, 36.4, 1.6, 1.6))
  ch.m = m
  local idx, n, tok = paintChip(ch, nil, 9)
  -- contact shadow on the bowl right under the leaning chip
  m:shift(1, 1):each(function(x, y) if bodyF:has(x, y) and not m:has(x, y) then c:put(x, y, WEAVE[1], btok) end end)
  -- bite edge: crumbly pale broken face
  m:edge():each(function(x, y) if (x - 28.5) ^ 2 + (y - 37) ^ 2 < 10 then c:put(x, y, CHIP[5], tok) end end)
end
G.save2(c, NAME)
