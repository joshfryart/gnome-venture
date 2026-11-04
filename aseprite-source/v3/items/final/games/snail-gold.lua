-- snail-gold (final, Opus single pass). A rare golden snail gliding left, head lifted high as if admiring itself:
-- a tall turreted spire shell of five stacked whorls (narrowing to a fine apex, leaning back), riding a slim foot.
-- Material: shell = polished metal, per-pixel light per whorl (6-tone gold), a dark horizon reflection band under
-- the bright streak on every whorl, deep suture grooves with AO above them and a lit lip below, a cool reflected
-- edge lower-right, bright specular streaks + one cream sparkle; body = 6-tone peach skin with tubercle grooves,
-- wet sheen, sole frill, AO where the shell sits; slime trail.
-- quirk: it has dropped a tiny gold coin in its slime trail and hasn't noticed.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs
local c = A.new("snail-gold")
local GLD = { "#5a2a1c", "#93481e", "#cc7a1e", "#f0a828", "#ffd65c", "#fff2b0" }
local SKN = { "#56303e", "#86545a", "#b47c6a", "#d8a482", "#efc89c", "#fde4bc" }
local SLM = { "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local BOUNCE = "#a77ab8"
local tokS, tokB, tokE = { r = { name = "shell" } }, { r = { name = "body" } }, { r = { name = "stalk" } }

-- slime trail + the dropped coin (quirk)
for x = 45, 53 do c:put(x, 51, (x % 4 == 1) and SLM[3] or SLM[1]) end
for x = 49, 54 do if x % 3 ~= 1 then c:put(x, 50, SLM[2]) end end
A.map(c, { ".hbb.", "hbddb", "bdbbd", ".ddd." }, 53, 47, { h = GLD[6], b = GLD[4], d = GLD[2] })
c:put(54, 47, A.CREAM)

local function stalk(pts, w)
  return A.stem(c, pts, function(t) return w - 0.4 * t end, SKN, { tok = tokE, amb = 0.12, wrap = 0.3 })
end
-- far eye stalk behind the head
stalk({ {16, 32}, {17, 28}, {18, 24}, {20, 20} }, 1.2)
-- foot + neck + raised head (tail at right)
local P = { {52, 50}, {36, 50}, {20, 50}, {14, 35} }
local function hw(t)
  if t < 0.42 then return 0.5 + 2.9 * (t / 0.42) ^ 0.7 end
  if t < 0.86 then return 3.4 + (t - 0.42) * 0.6 end
  return 3.66 + sin((t - 0.86) / 0.14 * pi * 0.5) * 0.5
end
local bm = A.tube(P, hw)
bm:add(c:ellipse(14, 34.5, 3.8, 3.6))
bm:each(function(x, y) if y > 51 then bm.s[K(x, y)] = nil end end)
local nb = X.pillow(bm, 3.2)
local bias = {}
bm:each(function(x, y) local k = K(x, y) if x > 23 and x < 49 then if y <= 47 then bias[k] = -2 elseif y == 48 then bias[k] = -1 end end end)
local bidx = A.shade(c, bm, nb, SKN, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokB })
bm:each(function(x, y) if y == 51 or (y == 50 and not bm:has(x, y + 1)) then c:put(x, y, (x % 3 == 1) and SKN[1] or SKN[2], tokB) end end)
bm:each(function(x, y) local k = K(x, y)
  if (x * 3 + y * 2) % 7 == 0 and A.hash(x, y, 9) < 0.55 and bm:has(x - 1, y) and bm:has(x, y + 1) and y < 50 then
    c:put(x, y, SKN[max(1, (bidx[k] or 3) - 1)], tokB) end end)
-- wet sheen along the neck's lit flank
for _, p in ipairs{ {13, 40}, {14, 42}, {15, 44}, {16, 45}, {17, 46} } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], SKN[6], tokB) end end
c:put(14, 41, SLM[3], tokB)
-- near eye stalk, feelers, eyes, face
stalk({ {13, 32}, {12, 28}, {10, 24}, {8, 20} }, 1.35)
A.ln(c, 10, 35, 7, 36, SKN[4], nil, tokE) c:put(7, 36, SKN[2], tokE) c:put(9, 35, SKN[5], tokE)
local function eye(x, y) A.map(c, { ".kk.", "kgkk", "kkkk", ".kk." }, x - 1, y - 1, { k = A.INK, g = A.CREAM }, tokE) end
eye(8, 18) eye(20, 18)
c:put(13, 38, SKN[1], tokB) c:put(12, 38, SKN[1], tokB) c:put(11, 37, SKN[1], tokB)   -- smile
c:put(15, 36, "#f5809f", tokB) c:put(16, 36, "#f5809f", tokB)

-- shell: tall spire of whorls, painted top-down so each larger whorl overlaps the one above
local W = {
  { 41.0, 15.0, 2.6, 2.2 },
  { 40.0, 19.6, 4.6, 3.0 },
  { 38.8, 25.4, 6.8, 3.9 },
  { 37.4, 32.6, 9.2, 4.9 },
  { 35.8, 41.2, 11.6, 6.0 },
}
local ang = -0.16      -- helical tilt (whorl bands rise toward the right)
local ux, uy = cos(ang), sin(ang)
local all = HP.mask()
local masks = {}
for i, w in ipairs(W) do
  local m = A.rell(w[1], w[2], ux, uy, w[3], w[4])
  if i == #W then m:each(function(x, y) if y > 47 then m.s[K(x, y)] = nil end end) end
  masks[i] = m
end
for i, w in ipairs(W) do
  local m = masks[i]:copy()
  for j = i + 1, #W do m:cut(masks[j]) end
  -- normals: ellipsoid per whorl
  local n, sb = {}, {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - w[1] + 0.5, y - w[2] + 0.5
    local a = (dx * ux + dy * uy) / (w[3] + 0.6)
    local b = (-dx * uy + dy * ux) / (w[4] + 0.6)
    local q = 1 - a*a - b*b
    local nx, ny = a * ux - b * uy, a * uy + b * ux
    n[k] = { A.norm(nx, ny * 1.1, sqrt(max(q, 0.03))) }
    -- AO above the next whorl (suture)
    if i < #W and (masks[i + 1]:has(x, y + 1) or masks[i + 1]:has(x, y + 2)) then sb[k] = masks[i + 1]:has(x, y + 1) and -3 or -1 end
  end)
  local idx = A.shade(c, m, n, GLD, { amb = 0.05, wrap = 0.18, tok = tokS, bias = sb, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
  -- polished metal: dark horizon reflection band below centre, bright streak above it, cool bounce lower-right
  local rim = X.rim(n)
  m:each(function(x, y) local k = K(x, y) local nn = n[k] local i0 = idx[k]
    if nn[2] > 0.02 and nn[2] < 0.2 and nn[1] > -0.5 and nn[1] < 0.75 and not sb[k] then c:put(x, y, GLD[max(1, i0 - 2)], tokS)
    elseif nn[2] > -0.42 and nn[2] < -0.22 and nn[1] < -0.15 and nn[1] > -0.62 then c:put(x, y, GLD[6], tokS) end
    if rim[k] > 0.8 and not m:has(x + 1, y) and not m:has(x, y + 1) and not sb[k] then c:put(x, y, BOUNCE, tokS) end
  end)
  -- lit lip at the top of every whorl below the apex (catches the light at the suture)
  if i > 1 then m:each(function(x, y)
    if not m:has(x, y - 1) and masks[i - 1]:has(x, y - 1) and x < w[1] + w[3] * 0.5 then c:put(x, y, GLD[5], tokS) end end) end
  all:add(m)
end
-- aperture lip where the body leaves the shell (front, lower-left)
for _, p in ipairs{ {25, 44}, {25, 45}, {26, 46}, {26, 43} } do if all:has(p[1], p[2]) then c:put(p[1], p[2], GLD[5], tokS) end end
-- cream glints + one sparkle
c:put(33, 28, A.CREAM, tokS) c:put(31, 37, A.CREAM, tokS)
c:sparkle(44, 15)
A.save(c, "snail-gold")
