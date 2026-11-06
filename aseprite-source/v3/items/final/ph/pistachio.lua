-- pistachio (aC35_1, Opus single pass). One tall pistachio in its shell, tipped to the upper right, the shell
-- split open along its seam from the tip: a V notch at the top, the green kernel showing in the gap with its
-- red-violet papery skin at the gap edges, a cream cut edge on the lit half, AO on the shade half, a dark seam line
-- down the closed lower end and a rosy blush near the tip. A shelled kernel lies beside it (green, mottled with
-- violet skin, one specular).
-- quirk: a flake of violet skin curls up off the loose kernel.
local NAME = "pistachio"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SHELL = { "#5c4038", "#8a684e", "#b8946a", "#d9bb8c", "#efd9ae", "#fff1d2" }
local BLUSH = { "#6a3440", "#9a5258", "#c47a72", "#dea088", "#f0c0a4", "#ffdcc4" }
local KER = { "#1f4a2a", "#2f6a34", "#4a8c3c", "#72b048", "#a0d05e", "#d0ec96" }
local SKIN = { "#3c1a36", "#5e2448", "#88345a", "#b04e6a", "#d07a88", "#eeaab0" }
local COOL = "#7c7a8c"

-- ---- shell ----
local SCX, SCY, RA, RB, ANG = 25, 31, 16, 10, -1.12
local sm, sn = G.oval(SCX, SCY, RA, RB, ANG, 1.1)
local ca, sa = cos(ANG), sin(ANG)
local function uv(x, y)
  local dx, dy = x - SCX, y - SCY
  return (dx * ca + dy * sa) / (RA + .45), (-dx * sa + dy * ca) / (RB + .45)
end
-- seam: v=0. tip is u -> +1 (upper right). gap opens for u > 0.05
local function gw(u) if u < 0.05 then return -1 end return 0.04 + 0.26 * ((u - 0.05) / 0.95) ^ 1.1 end
local gap, notch, kern = HP.mask(), HP.mask(), HP.mask()
sm:each(function(x, y) local u, v = uv(x, y)
  local w = gw(u)
  if w > 0 and abs(v) < w then
    if u > 0.8 then notch:set(x, y) else gap:set(x, y) end
  end
end)
sm:cut(notch)
local half = sm:copy():cut(gap)
local bias = {}
-- AO on the shell next to the gap (shade half deeper), blush near tip
half:each(function(x, y) local u, v = uv(x, y) local k = K(x, y)
  local w = gw(u)
  if w > 0 and abs(v) < w + 0.13 then bias[k] = (v > 0) and -2 or 0 end
  if w < 0 and abs(v) < 0.06 and u > -0.9 then bias[k] = -2 end -- closed seam line
end)
local stok = { r = { name = "shell" } }
local sidx = X.tone(c, half, X.light(sn, { amb = 0.08, wrap = 0.3 }), SHELL, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = bias, tok = stok })
-- blush toward the tip + faint pores
half:each(function(x, y) local u, v = uv(x, y) local k = K(x, y)
  local i = sidx[k]
  if u > 0.42 + 0.12 * X.hash(x, y, 2) then c:put(x, y, BLUSH[i], stok) end
  if X.hash(x, y, 7) < 0.06 and i > 2 then c:put(x, y, (u > 0.42 and BLUSH or SHELL)[i - 1], stok) end
end)
-- cut edge of the shell: cream lip on the lit half (v<0 side faces up-left)
half:each(function(x, y) local u, v = uv(x, y)
  local w = gw(u)
  if w > 0 and v < 0 and v > -(w + 0.11) and u > 0.12 then c:put(x, y, SHELL[6], stok) end
end)
-- cool reflected light on the lower right rim
half:edge():each(function(x, y) local u, v = uv(x, y)
  if v > 0.55 and u < 0.3 and u > -0.75 then c:put(x, y, COOL, stok) end end)
-- specular on the lit shoulder
c:put(17, 27, SHELL[6], stok) c:put(18, 26, SHELL[6], stok)
c:put(17, 26, "#fff4d6", stok)

-- kernel in the gap: skin at the edges, green core, darker deep in
local ktok = { r = { name = "kernel" } }
gap:each(function(x, y) local u, v = uv(x, y)
  local w = gw(u)
  local r = abs(v) / w
  local d = (u < 0.25) and 1 or 0
  if r > 0.55 then c:put(x, y, SKIN[(v < 0 and 5 or 3) - d], ktok)
  else c:put(x, y, KER[(v < 0.0 and 6 or 4) - d - ((u > 0.7) and 1 or 0)], ktok) end
end)

-- ---- loose kernel ----
local KX, KY = 47, 47
local km, kn = G.oval(KX, KY, 8, 4.3, 0.42, 0.9)
local kb = {}
local kv = X.light(kn, { amb = 0.1, wrap = 0.3 })
local kidx = X.tone(c, km, kv, KER, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, bias = kb, tok = ktok })
local kca, ksa = cos(0.42), sin(0.42)
km:each(function(x, y) local k = K(x, y)
  local dx, dy = x - KX, y - KY
  local u, v = (dx * kca + dy * ksa) / 8.5, (-dx * ksa + dy * kca) / 4.8
  local p = sin(u * 6.5 + 0.8) * cos(v * 3.2 - 0.5) + 0.35 * sin(u * 13 + v * 5)
  local rimv = u * u + v * v
  if p > 0.45 or (rimv > 0.62 and X.hash(x, y, 5) < 0.55) or (u > 0.7) then
    c:put(x, y, SKIN[max(1, min(6, kidx[k]))], ktok)
  end
end)
-- groove along the kernel's back
for i = -4, 4 do
  local x, y = floor(KX + i * kca - 1.3 * (-ksa) + .5), floor(KY + i * ksa - 1.3 * kca + .5)
  if km:has(x, y) then c:put(x, y, KER[max(1, (kidx[K(x, y)] or 3) - 2)], ktok) end
end
-- specular
local spx, spy = G.specAt(km, kn, 30)
c:put(spx, spy, "#fff4d6", ktok) c:put(spx + 1, spy, KER[6], ktok)
-- quirk: curled skin flake lifting off the kernel's upper end
local ftok = { r = { name = "flake" } }
for _, q in ipairs{ {52, 41, 5}, {53, 40, 5}, {54, 40, 4}, {55, 41, 3}, {55, 42, 2}, {54, 43, 3} } do c:put(q[1], q[2], SKIN[q[3]], ftok) end

G.save2(c, NAME)
