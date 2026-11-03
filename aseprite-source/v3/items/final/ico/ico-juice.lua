-- ico-juice (final, Opus). A slim, slightly tapered tumbler of orange juice standing on a short shadow, a red and
-- cream striped bendy straw leaning right, and an orange wheel slit onto the left rim.
-- Material: glass = bright left rim, pale cool core above the juice, darker right wall, thick lens-like base with a
-- bright core line; juice = per-pixel vertical cylinder (6-tone orange, cool-violet shade), lit meniscus ellipse,
-- pulp flecks, a vertical glass glint over the juice, straw seen bent (refracted) below the surface; orange wheel =
-- rind ring, pale pith, segment membranes. AO where the wheel and straw meet the glass.
-- quirk: one pip sinks slowly, trailing two tiny bubbles.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, atan = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.atan
local c = A.new("ico-juice")
local OJ = { "#7a2a2c", "#b8452a", "#e0661f", "#f58f26", "#ffb640", "#ffd77a" }
local GL = { "#3a6f9a", "#5d9fbe", "#8cc9d6", "#b8e8e4", "#dcf8f2", "#f4fffb" }
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local CRM = { "#d8c6b0", "#f3e6cc", "#fff4d6" }
local RIND = { "#8f3a1f", "#d0621c", "#f58f26", "#ffb640" }
local gtok, jtok, stok, otok = { r = { name = "glass" } }, { r = { name = "juice" } }, { r = { name = "straw" } }, { r = { name = "orange" } }

local CX, TOP, BOT = 31.5, 17, 51
local function halfW(y) return 9.6 - (y - TOP) / (BOT - TOP) * 2.0 end
c:groundShadow(31, 52, 12, 2)

-- straw behind/above first (glass front wall paints over the part inside)
local sp1 = { { 35, 44 }, { 36, 34 }, { 38, 22 }, { 40.5, 12 } }
local sm1, sn1, ST1, SS1 = A.tube(sp1, function() return 1.35 end)
local sm2, sn2, ST2, SS2 = A.tube({ { 40.5, 12 }, { 41.3, 9.2 }, { 43, 8 }, { 48, 7.4 } }, function() return 1.35 end)
local function strawPaint(m, T, S, tlen, off)
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    local stripe = floor((T[k] * tlen + (s * 1.2) + off) / 2.5) % 2 == 0
    if stripe then c:put(x, y, s < -0.4 and RED[4] or s < 0.35 and RED[3] or RED[2], stok)
    else c:put(x, y, s < -0.4 and CRM[3] or s < 0.35 and CRM[2] or CRM[1], stok) end
  end)
end
strawPaint(sm1, ST1, SS1, 33, 0)
strawPaint(sm2, ST2, SS2, 9, 0.8)
-- bend corrugation: two dark rings at the elbow
sm1:each(function(x, y) if y <= 13 and y >= 12 then c:put(x, y, RED[1], stok) end end)

-- glass body
local glass = HP.mask()
for y = TOP, BOT do
  local w = halfW(y)
  if y > BOT - 2 then w = w - (y - (BOT - 2)) * 1.1 end
  for x = floor(CX - w + 0.5), floor(CX + w - 0.5) do glass:set(x, y) end
end
local inner = HP.mask()
for y = TOP + 1, BOT - 5 do
  local w = halfW(y) - 2
  if y > BOT - 7 then w = w - (y - (BOT - 7)) * 0.8 end
  for x = floor(CX - w + 0.5), floor(CX + w - 0.5) do inner:set(x, y) end
end
local SURF = 23
local juice = HP.mask()
inner:each(function(x, y) if y >= SURF then juice:set(x, y) end end)

-- walls + base
glass:each(function(x, y)
  local w = halfW(y)
  local fx = (x + 0.5 - CX) / w           -- -1 left .. 1 right
  local col
  if y >= BOT - 4 then                    -- thick base
    col = (fx < -0.55) and GL[5] or (fx > 0.55) and GL[2] or GL[3]
    if y == BOT - 3 and abs(fx) < 0.6 then col = GL[6] end
    if y == BOT then col = (fx < 0) and GL[3] or GL[2] end
  elseif fx < -0.82 then col = GL[6]
  elseif fx < -0.62 then col = GL[4]
  elseif fx > 0.84 then col = GL[2]
  elseif fx > 0.62 then col = GL[3]
  else col = (fx < -0.3) and GL[5] or GL[4] end
  c:put(x, y, col, gtok)
end)
-- pale core above the juice: faint vertical streaks
inner:each(function(x, y) if y < SURF then
  local fx = (x + 0.5 - CX) / (halfW(y) - 2)
  c:put(x, y, fx < -0.4 and GL[6] or fx > 0.55 and GL[3] or GL[5], gtok)
end end)

-- straw seen through the clear glass above the juice
do local m = HP.mask() sm1:each(function(x, y) if y < SURF and y >= TOP and inner:has(x, y) then m:set(x, y) end end)
  strawPaint(m, ST1, SS1, 33, 0) end
-- juice: vertical cylinder light
local jn = {}
juice:each(function(x, y)
  local w = halfW(y) - 1.6
  local fx = max(-0.96, min(0.96, (x + 0.5 - CX) / w))
  jn[K(x, y)] = { fx, 0.05, sqrt(1 - fx*fx) }
end)
local bias = {}
juice:each(function(x, y) if y >= BOT - 7 then bias[K(x, y)] = -1 end end)   -- AO toward the base
local jIdx = A.shade(c, juice, jn, OJ, { tok = jtok, amb = 0.1, wrap = 0.35, bias = bias, cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 } })
-- meniscus: lit ellipse surface with a dark back lip
for x = floor(CX - 7), floor(CX + 7) do
  if juice:has(x, SURF) then c:put(x, SURF, OJ[6], jtok) end
  if juice:has(x, SURF + 1) then c:put(x, SURF + 1, (x < CX + 3) and OJ[5] or OJ[4], jtok) end
end
-- straw below the surface: refracted (shifted left), dim
for y = SURF + 2, BOT - 8 do
  local sx = floor(35 + (BOT - 8 - y) * 0.06 - 1.5)
  for dx = 0, 2 do if juice:has(sx + dx, y) then
    local on = floor((y + 1) / 2.5) % 2 == 0
    c:put(sx + dx, y, on and (dx == 0 and RED[3] or RED[2]) or (dx == 0 and OJ[5] or OJ[4]), stok)
  end end
end
-- pulp flecks
for _, p in ipairs{ { 28, 29 }, { 33, 33 }, { 27, 38 }, { 31, 42 }, { 36, 37 }, { 34, 28 } } do
  if juice:has(p[1], p[2]) then A.step(c, jIdx, OJ, p[1], p[2], 1, jtok) end
end
-- glass glint over the juice (left) + small cream spec
for y = SURF + 3, BOT - 9 do c:put(floor(CX - halfW(y) + 3.5), y, (y < SURF + 9) and OJ[6] or OJ[5], gtok) end
c:put(floor(CX - halfW(SURF + 4) + 3.5), SURF + 4, A.CREAM, gtok)

-- rim: back rim (upper arc) darker, front rim bright
for x = floor(CX - 9.6 + 0.5), floor(CX + 9.6 - 0.5) do
  c:put(x, TOP - 1, (x < CX) and GL[5] or GL[3], gtok)
end

-- quirk: a sinking pip with two bubbles
A.map(c, { ".p.", "pPq", ".q." }, 29, 33, { p = "#f2d7a0", P = "#e0b878", q = "#a87a4a" }, jtok)
c:put(30, 31, OJ[6], jtok) c:put(31, 28, OJ[6], jtok) c:put(32, 28, OJ[5], jtok)

-- orange wheel slit onto the left rim
local OCX, OCY, OR = 22, 17, 6.6
local wheel = A.ell(OCX, OCY, OR, OR)
local wIdx = {}
wheel:each(function(x, y)
  local dx, dy = x - OCX, y - OCY
  local r = sqrt(dx*dx + dy*dy)
  local ang = atan(dy, dx)
  local col
  local lit = (dx + dy) < -1
  local shade = (dx + dy) > 3
  if r > OR - 0.6 then col = lit and RIND[3] or shade and RIND[1] or RIND[2]
  elseif r > OR - 1.6 then col = lit and RIND[4] or shade and RIND[2] or RIND[3]
  elseif r > OR - 2.2 then col = shade and CRM[2] or CRM[3]
  elseif r < 1.1 then col = CRM[2]
  else
    local seg = (ang / (2 * pi) * 8) % 1
    if seg < 0.13 then col = CRM[2]
    else col = lit and OJ[5] or shade and OJ[3] or OJ[4] end
  end
  c:put(x, y, col, otok)
end)
-- the slit: wheel is pushed onto the glass wall; glass wall AO under it
glass:each(function(x, y) if wheel:grow(1):has(x, y) and not wheel:has(x, y) and y > OCY then c:put(x, y, GL[2], gtok) end end)
-- juicy sparkle on the wheel
c:put(OCX - 3, OCY - 2, A.CREAM, otok)
A.save(c, "ico-juice")
