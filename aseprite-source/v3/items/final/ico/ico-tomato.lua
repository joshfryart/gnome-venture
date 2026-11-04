-- ico-tomato (final pass, Opus). A ripe tomato, slightly wider than tall with five soft lobes at the shoulders and a
-- sunken stem cup; a slim star calyx of five curling sepals and a short stem that runs on into a snip of vine.
-- Material: per-pixel light from a lobed height field (6-tone red, cool-violet shade), lobe grooves fading down the
-- fruit, waxy bloom on the lit shoulder, a cream window specular, a cool reflected light low right, a warm
-- orange ripening blush round the stem cup, AO + cast shadow of the calyx; sepals 6-tone with a midrib, stem with
-- a pale cut end.
-- quirk: the stem keeps a snip of vine with one small serrated tomato leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt, atan, exp = math.floor, math.abs, math.max, math.min, math.sin,
  math.cos, math.pi, math.sqrt, math.atan, math.exp
local c = A.new("ico-tomato")
local RED  = { "#561634", "#8e1f33", "#c52c2e", "#e94631", "#ff7550", "#ffb07c" }
local BLUSH = { "#6a2630", "#a3402c", "#d6602c", "#f2823a", "#ffa65a", "#ffcf88" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#24504a", "#3f7a4a", "#5f9c50", "#8cc066", "#c2df8e" }
local BOUNCE, SPEC = "#a8476a", "#fff4d6"
local ftok = { r = { name = "fruit" } }
local ltok = { r = { name = "calyx" } }

-- fruit: lobed height field
local CX, CY, RX, RY = 32, 37, 20.5, 17
local TOPY = CY - RY + 3                        -- stem cup centre
local function lobe(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - TOPY
  local th = atan(dy, dx)
  return cos(5 * (th + 0.3))
end
local function q(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local up = max(0, -dy / RY)                     -- lobes stronger toward the top
  local Rm = 1 + 0.035 * lobe(x, y) * (0.4 + up)
  local qq = (dx / (RX * Rm))^2 + (dy / (RY * Rm))^2
  return qq
end
local fm = HP.mask()
for y = floor(CY - RY - 3), floor(CY + RY + 2) do for x = floor(CX - RX - 3), floor(CX + RX + 3) do
  if q(x, y) <= 1 then fm:set(x, y) end
end end
local function H(x, y)
  local qq = q(x, y)
  local h = sqrt(max(0, 1 - min(qq, 1))) * RY
  local dx, dy = x + 0.5 - CX, y + 0.5 - TOPY
  local r2 = dx * dx + dy * dy * 2.2
  h = h - 5.5 * exp(-r2 / 38)                     -- sunken stem cup
  local near = exp(-r2 / 260)
  h = h - 1.4 * (0.5 - 0.5 * lobe(x, y)) * near * 2  -- lobe grooves fading down the fruit
  return h
end
local n = A.hfield(fm, H)
local bias = {}
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
-- calyx masks first (for AO / shadow)
local sepals = {}
local cm = HP.mask()
local ang0 = { -2.9, -2.0, -0.35, 0.45, 1.75 }
local SCX, SCY = CX + 0.5, TOPY + 0.5
for i, a in ipairs(ang0) do
  local L = (i == 5) and 7 or 10
  local ux, uy = cos(a), sin(a) * 0.62
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local bx, by = SCX + ux * L, SCY + uy * L + 2.5
  local mx, my = SCX + ux * L * 0.55, SCY + uy * L * 0.55 - 1.2
  local m, sn, T, Sd = A.blade(SCX, SCY, mx, my, bx, by, function(t)
    if t > 0.97 then return -1 end
    return 2.5 * (1 - t) ^ 0.75 * min(1, 0.6 + t * 4)
  end, { fold = 0.5 })
  sepals[i] = { m = m, n = sn, T = T, S = Sd }
  cm:add(m)
end
-- blush toward the cup, cast shadow + AO under the calyx
local useBlush = {}
fm:each(function(x, y)
  local k = K(x, y)
  local dx, dy = x + 0.5 - SCX, y + 0.5 - SCY
  if dx * dx + dy * dy * 2.4 < 70 then useBlush[k] = true end
end)
A.cast(bias, fm, cm, 1, 2, -1)
X.ao(bias, fm, cm, 1, -1)
-- tone with two ramps
local idx = {}
fm:each(function(x, y)
  local k = K(x, y)
  local val = v[k] or 0
  local i = 1
  for j, t in ipairs{ 0.2, 0.36, 0.52, 0.72, 0.9 } do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  c:put(x, y, (useBlush[k] and BLUSH or RED)[i], ftok)
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
fm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and y > CY and x > CX - 4 then c:put(x, y, BOUNCE, ftok) end end)
-- waxy bloom: a soft pale arc on the lit shoulder (tone +1), then a window specular
local sp = X.spec(n, 9)
fm:each(function(x, y) local k = K(x, y)
  if sp[k] > 0.55 and idx[k] >= 4 and idx[k] < 6 and not cm:has(x, y) then A.step(c, idx, RED, x, y, 1, ftok) end end)
local wx, wy = CX - 11, CY - 7
for _, p in ipairs{ { 0, 0, SPEC }, { 1, 0, SPEC }, { 0, 1, SPEC }, { 2, 0, RED[6] }, { -1, 2, RED[6] }, { 0, 2, RED[6] } } do
  if fm:has(wx + p[1], wy + p[2]) then c:put(wx + p[1], wy + p[2], p[3], ftok) end
end

-- vine snip + leaf (behind the stem), then stem, then sepals on top
local vine = { { 33.5, TOPY - 4 }, { 35, TOPY - 7 }, { 38, TOPY - 8.5 }, { 42, TOPY - 8 } }
local vm, vn = A.tube(vine, function(t) return 1.6 end)
A.shade(c, vm, vn, STEM, { tok = ltok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- small serrated leaf hanging off the vine end
local lm, ln, LT, LS = A.blade(42, TOPY - 8, 49, TOPY - 11, 52, TOPY - 3, function(t)
  local w = 3.6 * sin(pi * min(1, t * 1.05)) ^ 0.8
  if t > 0.15 and t < 0.9 and floor(t * 9) % 2 == 0 then w = w + 0.7 end   -- serration
  return w
end, { fold = 0.6 })
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.18 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, LEAF[2], ltok) end end)
-- stem: short, slightly bent, pale cut end on top
local stem = { { SCX, SCY }, { SCX - 0.2, SCY - 2 }, { SCX + 0.2, SCY - 3.5 }, { SCX + 1, SCY - 5 } }
local sm, sn = A.tube(stem, function(t) return 2.1 - 0.2 * t end)
local sidx = A.shade(c, sm, sn, STEM, { tok = ltok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- sepals
for i, s in ipairs(sepals) do
  local sbias = {}
  local id = A.shade(c, s.m, s.n, LEAF, { tok = ltok, bias = sbias, amb = 0.1 })
  s.m:each(function(x, y) local k = K(x, y)
    if abs(s.S[k]) < 0.2 and s.T[k] > 0.15 and s.T[k] < 0.8 then c:put(x, y, LEAF[min(6, (id[k] or 3) + 1)], ltok) end
    if s.T[k] < 0.12 then c:put(x, y, LEAF[2], ltok) end
  end)
end
-- dark heart where sepals meet the stem
for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { -1, 0 } } do c:put(floor(SCX) + p[1], floor(SCY) + p[2] + 1, LEAF[1], ltok) end
-- pale cut end of the stem
local tx, ty = floor(SCX + 1 + 0.5), floor(SCY - 5 + 0.5)
c:put(tx - 1, ty - 1, STEM[5], ltok) c:put(tx, ty - 1, STEM[5], ltok) c:put(tx + 1, ty - 1, STEM[4], ltok)

A.save(c, "ico-tomato")
