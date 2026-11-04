-- egg-fried-rice (Opus single pass). A slim-walled porcelain rice bowl (cool white glaze, cobalt wave band, foot
-- ring, ground shadow) heaped with golden fried rice: dome lit per pixel, each grain a lit 2x1 with dark gaps,
-- scrambled-egg curds (yellow, cream lit edge, orange shade), peas with a glint, spring-onion rings, carrot dice.
-- A pair of slim lacquered chopsticks rests across the heap (AO row + contact shadow on the rice).
-- quirk: one runaway rice grain stuck on the outside of the bowl.
local NAME = "egg-fried-rice"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local RICE = { "#7a4a2c", "#a86e36", "#d1994a", "#e9bd62", "#f7da8c", "#fff1c4" }
local POR  = { "#3e4870", "#6a7aa4", "#9cabc9", "#c6d1e2", "#e4eaf2", "#f7f8fb" }
local BLUE = { "#1f3a7a", "#2f5bb0", "#5a88d6" }
local EGG  = { "#c0661e", "#f0a020", "#ffd23e", "#fff0a0" }
local PEA  = { "#245a2c", "#3f8f3c", "#7cc35a", "#c4e07a" }
local ONI  = { "#3a7a3a", "#8cc862", "#e0f2b8" }
local CAR  = { "#b2401f", "#ee6c22", "#ffb070" }
local STK  = { "#4a1f22", "#7a2e2a", "#b5463a", "#e77a5c" }

local CX, RIM = 32, 33
-- ground shadow (2-tone, 3 px)
G.shadow(c, CX + 1, 53, 13, 1.6, "#9a8f8a", "#b9b0a8")

-- bowl body: lower half-ellipse + foot ring
local bowl = HP.mask()
for y = RIM, 50 do for x = 8, 56 do
  local dx, dy = (x - CX + 0.5) / 21.5, (y - RIM + 1) / 17.5
  if dx * dx + dy * dy <= 1 then bowl:set(x, y) end
end end
local foot = HP.rect(CX - 8, 49, CX + 7, 52)
bowl:add(foot)
local bn = {}
bowl:each(function(x, y)
  local nx = (x - CX + 0.5) / 22
  local ny = min(0.9, (y - RIM) / 20)
  bn[K(x, y)] = { G.norm(nx, ny * 0.9 + 0.15, sqrt(max(0.05, 1 - nx * nx))) }
end)
local ptok = { r = { name = "bowl" } }
local bias = {}
-- foot ring AO where it meets the body
for x = CX - 8, CX + 7 do bias[K(x, 49)] = -2 bias[K(x, 50)] = -1 end
local pidx = G.shade(c, bowl, bn, POR, { 0.2, 0.36, 0.52, 0.68, 0.86 }, { amb = 0.15, wrap = 0.35, bias = bias, tok = ptok })
-- foot ring lip: lit top-left edge, dark under
for x = CX - 8, CX + 7 do c:put(x, 52, POR[2], ptok) end
c:put(CX - 8, 50, POR[4], ptok) c:put(CX - 8, 51, POR[4], ptok)
-- cobalt wave band around the body
bowl:each(function(x, y)
  if y > 50 then return end
  local wy = 41 + floor(1.3 * sin((x - 8) * 0.55) + 0.5)
  if y == wy then
    local i = (pidx[K(x, y)] or 3) >= 4 and 3 or ((pidx[K(x, y)] or 3) >= 2 and 2 or 1)
    c:put(x, y, BLUE[i], ptok)
  elseif y == 38 or y == 44 then
    if (pidx[K(x, y)] or 3) >= 3 then c:put(x, y, POR[3], ptok) end
  end
end)
-- glaze specular streak (vertical, upper left)
for _, q in ipairs{ { 15, 36 }, { 15, 37 }, { 16, 38 }, { 16, 39 } } do c:put(q[1], q[2], POR[6], ptok) end
c:put(17, 36, "#fdfcf6", ptok)
-- rim: thick lip seen as a band, cool shade toward the right
for x = CX - 21, CX + 21 do
  local u = (x - CX + 0.5) / 21.5
  c:put(x, RIM, u < -0.3 and POR[6] or (u < 0.5 and POR[5] or POR[4]), ptok)
  c:put(x, RIM + 1, u < 0.6 and POR[3] or POR[2], ptok)
end

-- rice dome
local dome = HP.mask()
for y = 12, RIM - 1 do for x = 10, 54 do
  local dx, dy = (x - CX + 0.5) / 20.5, (y - RIM + 0.5) / 18.5
  local bump = 0.06 * sin(x * 0.9) + 0.05 * cos(y * 1.3 + x * 0.4)
  if dx * dx + dy * dy <= 1 + bump then dome:set(x, y) end
end end
local dn = {}
dome:each(function(x, y)
  local nx, ny = (x - CX + 0.5) / 21, (y - RIM + 0.5) / 19
  local nz = sqrt(max(0.03, 1 - nx * nx - ny * ny))
  -- per-grain bumps
  local hx, hy = X.hash(x, y, 1) - 0.5, X.hash(x, y, 2) - 0.5
  dn[K(x, y)] = { G.norm(nx + hx * 0.5, ny + hy * 0.5, nz) }
end)
local rbias = {}
-- AO where the heap meets the rim + chopstick contact shadow (set later)
dome:each(function(x, y) if y >= RIM - 1 then rbias[K(x, y)] = -1 end end)
-- chopsticks geometry (two slim sticks, upper-right to centre-left)
local sticks = {
  { { 20, 25 }, { 56, 11 }, 1.15 },
  { { 22, 29 }, { 57, 15 }, 1.15 },
}
local smasks = {}
for i, s in ipairs(sticks) do
  local a, b = s[1], s[2]
  local m, n, T, S = X.cyl(a[1], a[2], b[1], b[2], function(t) return s[3] * (0.75 + 0.25 * t) end)
  smasks[i] = { m = m, n = n, T = T, S = S }
end
for _, s in ipairs(smasks) do G.cast(rbias, dome, s.m, 1, 2, -1) X.ao(rbias, dome, s.m, 1, -1) end
local rtok = { r = { name = "rice" } }
local ridx = G.shade(c, dome, dn, RICE, { 0.22, 0.38, 0.54, 0.7, 0.85 }, { amb = 0.08, wrap = 0.3, bias = rbias, tok = rtok })
-- grain pattern: lit 2x1 grains with dark seams
dome:each(function(x, y) local k = K(x, y)
  if y >= RIM - 1 then return end
  local g = (x + 2 * y + floor(y / 2)) % 4
  local i = ridx[k] or 3
  if g == 0 and X.hash(x, y, 9) > 0.35 then c:put(x, y, RICE[max(1, i - 1)], rtok)
  elseif g == 2 and X.hash(x, y, 11) > 0.55 then c:put(x, y, RICE[min(6, i + 1)], rtok) end
end)

-- toppings
local function on(x, y) return dome:has(x, y) and y < RIM - 1 end
local ttok = { r = { name = "top" } }
local function curd(x, y, shape)
  for j, row in ipairs(shape) do for i = 1, #row do local ch = row:sub(i, i)
    local px, py = x + i - 1, y + j - 1
    if ch ~= "." and on(px, py) then
      c:put(px, py, ch == "h" and EGG[4] or ch == "b" and EGG[3] or ch == "s" and EGG[2] or EGG[1], ttok) end end end
end
curd(16, 26, { ".hb.", "hbbs", ".bss", "..d." })
curd(29, 16, { "hb.", "bbs", ".sd" })
curd(37, 22, { ".hbb", "hbbs", "bss.", ".d.." })
curd(23, 21, { "hb", "bs" })
curd(44, 28, { "hbs", "bsd" })
local function pea(x, y)
  local m = { { 0, 0, 3 }, { 1, 0, 3 }, { -1, 1, 3 }, { 0, 1, 4 }, { 1, 1, 3 }, { 2, 1, 2 }, { 0, 2, 2 }, { 1, 2, 1 }, { -1, 2, 2 } }
  for _, q in ipairs(m) do if on(x + q[1], y + q[2]) then c:put(x + q[1], y + q[2], PEA[q[3]], ttok) end end
end
pea(21, 17) pea(33, 25) pea(46, 21) pea(27, 29) pea(13, 30)
local function ring(x, y)
  for _, q in ipairs{ { 0, 0, 2 }, { 1, 0, 2 }, { -1, 1, 2 }, { 0, 1, 3 }, { 1, 1, 3 }, { 2, 1, 1 }, { 0, 2, 1 }, { 1, 2, 1 } } do
    if on(x + q[1], y + q[2]) then c:put(x + q[1], y + q[2], ONI[q[3]], ttok) end end
end
ring(31, 20) ring(18, 22) ring(41, 27) ring(36, 30)
for _, q in ipairs{ { 26, 24 }, { 41, 17 }, { 49, 26 } } do
  c:put(q[1], q[2], CAR[3], ttok) c:put(q[1] + 1, q[2], CAR[2], ttok) c:put(q[1], q[2] + 1, CAR[2], ttok) c:put(q[1] + 1, q[2] + 1, CAR[1], ttok) end

-- chopsticks (lacquer red, square-ish tips, bright lit edge + spec)
local ctok = { r = { name = "sticks" } }
for i, s in ipairs(smasks) do
  local v = X.light(s.n, { amb = 0.05, wrap = 0.2 })
  s.m:each(function(x, y) local k = K(x, y)
    local t, sn = s.T[k], s.S[k]
    local j = sn < -0.3 and 4 or (sn < 0.35 and 3 or 2)
    if t < 0.18 then j = max(1, j - 1) end           -- food-darkened tips
    if i == 1 and smasks[2].m:has(x, y) then return end
    c:put(x, y, STK[j], ctok)
  end)
end
-- second stick under the first: AO where they cross is handled by drawing order; gold band near the top end
for _, s in ipairs(smasks) do s.m:each(function(x, y) local t = s.T[K(x, y)] if t > 0.72 and t < 0.77 then c:put(x, y, "#f5b82e", ctok) end end) end
c:put(48, 15, "#fff4d6", ctok)

-- quirk: a runaway grain stuck on the bowl's outer wall
c:put(44, 39, RICE[6], ptok) c:put(45, 39, RICE[4], ptok) c:put(45, 40, RICE[2], ptok)
G.save2(c, NAME)
