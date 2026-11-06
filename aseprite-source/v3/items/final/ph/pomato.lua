-- pomato (D10 final, Sonnet high). The grafted tomato-potato: a plump tomato (green ripening to a golden-orange blush on the
-- shade side) sitting on, and half hiding, a knobby russet potato tuber. Tomato: ellipsoid light on 6-tone green and 6-tone
-- orange ramps with a hard-edged noisy ripeness border, faint rib grooves, waxy specular, five-sepal calyx star, slim stalk
-- carrying a serrated leaf. Tuber: lumpy normals, lenticel flecks, three deep eyes with brows; AO + cast shadow where the
-- tomato overlaps it. quirk: one potato eye has already sprouted a lilac shoot with two tiny leaflets.
local NAME = "pomato"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GRN = { "#2c5a36", "#4b8a3e", "#78b44a", "#a6d05a", "#cfe678", "#f0f6b0" }
local ORG = { "#6a2418", "#9c3a1e", "#cc5a22", "#ec8128", "#fcab3a", "#ffd56c" }
local CAL = { "#17402e", "#245c3a", "#357e45", "#4f9e50", "#78c060", "#aee084" }
local POT = { "#3e2a22", "#5e4130", "#85603f", "#a8814f", "#c9a468", "#e8cb90" }
local LIL = { "#7a4a86", "#b27cb8", "#e0b0dc", "#f8dcf0" }
local ttok, ptok, ctok = { r = { name = "tomato" } }, { r = { name = "potato" } }, { r = { name = "calyx" } }
local CX, CY, RX, RY = 26, 35, 15, 13.5

-- potato first (behind): lumpy union of ovals
local pm = c:ellipse(41, 46.5, 9, 7.5)
pm:add(c:ellipse(36, 51, 8, 4.5)):add(c:ellipse(47, 43.5, 5.5, 5)):add(c:ellipse(46, 50, 6, 4))
local tom = c:ellipse(CX, CY, RX, RY)
pm:cut(tom)
local pn = X.pillow(pm, 4)
local pbias = {}
X.ao(pbias, pm, tom, 3, -1)
A.cast(pbias, pm, tom, 1, 1, -1)
A.cast(pbias, pm, tom, 2, 2, -1)
for k, nn in pairs(pn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local ox, oy = (X.hash(x // 2, y // 2, 4) - 0.5) * 0.45, (X.hash(x // 2, y // 2, 8) - 0.5) * 0.45
  pn[k] = { A.norm(nn[1] + ox, nn[2] + oy, nn[3]) }
  local h = X.hash(x, y, 9)
  if h < 0.08 then pbias[k] = (pbias[k] or 0) - 2 elseif h > 0.94 then pbias[k] = (pbias[k] or 0) + 1 end
end
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.08, wrap = 0.3 }), POT, { cuts = A.CUTS6, bias = pbias, tok = ptok })
-- cool-warm bounce on the lower-right rim
local prim = X.rim(pn)
pm:each(function(x, y) local k = K(x, y)
  if prim[k] > 0.8 and pidx[k] and pidx[k] < 4 and not tom:has(x + 1, y) then c:put(x, y, "#9a7a4a", ptok) end end)
-- eyes: a dark dent with a lit brow
local eyes = { { 44, 51 }, { 49, 47 }, { 37, 53 }, { 40, 44 } }
for _, e in ipairs(eyes) do
  if pm:has(e[1], e[2]) then
    c:put(e[1], e[2], POT[1], ptok) c:put(e[1] + 1, e[2], POT[2], ptok)
    c:put(e[1] - 1, e[2] - 1, POT[5], ptok) c:put(e[1], e[2] - 1, POT[5], ptok)
  end
end

-- sprout from the eye at (49,47) (quirk), drawn before tomato for layering
local spm, spn = A.tube({ { 49, 46 }, { 49, 43 }, { 50, 41 }, { 51, 39 } }, function(t) return 1.0 - 0.15 * t end)
X.tone(c, spm, X.light(spn, { amb = 0.2, wrap = 0.3 }), LIL, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "shoot" } } })
local function tiny(cx, cy, ang)
  local m = A.rell(cx, cy, cos(ang), sin(ang), 2.6, 1.5)
  X.tone(c, m, X.light(X.pillow(m, 1.4), { amb = 0.12, wrap = 0.25 }), GRN, { cuts = A.CUTS6, tok = ctok })
  A.pline(c, { { floor(cx - cos(ang) * 1.5 + .5), floor(cy - sin(ang) * 1.5 + .5) }, { floor(cx + cos(ang) * 1.5 + .5), floor(cy + sin(ang) * 1.5 + .5) } }, GRN[5], ctok)
end
tiny(48, 39, -2.7) tiny(54, 38, -0.4)
c:put(51, 38, LIL[4], { r = { name = "shoot" } })

-- tomato body
local n = {}
tom:each(function(x, y)
  local nx, ny = (x - CX) / (RX + 0.5), (y - CY) / (RY + 0.5)
  local q = 1 - nx * nx - ny * ny
  n[K(x, y)] = { A.norm(nx, ny, sqrt(max(q, 0.03))) }
end)
local v = X.light(n, { amb = 0.06, wrap = 0.28 })
local bias = {}
-- shallow stem dimple (AO) + rib grooves
X.ao(bias, tom, c:ellipse(CX, 22.5, 4, 1), 2, -1)
for _, phi in ipairs{ -0.55, 0.45 } do
  for yy = -11, 11 do
    local ny = yy / (RY + 0.5)
    local xx = CX + (RX + 0.5) * sin(phi) * sqrt(1 - ny * ny) * 1.0
    local px, py = floor(xx + 0.5), floor(CY + yy + 0.5)
    local k = K(px, py)
    if tom:has(px, py) and yy % 4 ~= 1 then bias[k] = (bias[k] or 0) - 1 end
  end
end
tom:each(function(x, y) local h = X.hash(x, y, 13) local k = K(x, y)
  if h < 0.05 then bias[k] = (bias[k] or 0) - 1 elseif h > 0.96 then bias[k] = (bias[k] or 0) + 1 end end)
local idx = X.tone(c, tom, v, GRN, { cuts = A.CUTS6, bias = bias, tok = ttok })
tom:each(function(x, y)
  local k = K(x, y)
  local t = (x - CX) * 0.7 + (y - CY) * 0.85 + (X.hash(x, y, 7) - 0.5) * 8
  if t > 6.5 and idx[k] then c:put(x, y, ORG[idx[k]], ttok) end
end)
-- cool reflected sky on the shade rim, warm russet bounce where the tuber touches
local rim = X.rim(n)
tom:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.8 and idx[k] and idx[k] < 5 then
    if pm:has(x + 1, y + 1) or pm:has(x, y + 1) or pm:has(x + 1, y) then c:put(x, y, "#b4642c", ttok) else c:put(x, y, "#5a8a8a", ttok) end
  end
end)
-- waxy specular + bloom specks
c:put(18, 28, "#fffbe0", ttok) c:put(19, 28, "#fffbe0", ttok) c:put(18, 29, GRN[6], ttok) c:put(20, 28, GRN[6], ttok)
c:put(21, 26, GRN[6], ttok)
for _, p in ipairs{ { 17, 33 }, { 23, 30 }, { 29, 27 } } do c:put(p[1], p[2], GRN[5], ttok) end
-- a small scar speck
c:put(33, 37, GRN[1], ttok) c:put(34, 37, GRN[2], ttok)

-- calyx: five drooping sepals from the dimple
local function sepal(p1, p2, p3, p4, w)
  local m, sn, T = A.tube({ p1, p2, p3, p4 }, function(t) return w * (1 - t) ^ 0.8 + 0.3 end)
  return m, sn, T
end
local sps = {
  { { 26, 22 }, { 22, 18 }, { 20, 17 }, { 18, 19 }, 2.0 },     -- back left
  { { 26, 22 }, { 30, 18 }, { 32, 17 }, { 34, 19 }, 2.0 },     -- back right
  { { 26, 22.5 }, { 22, 23 }, { 18, 24 }, { 15.5, 28 }, 2.2 }, -- left
  { { 26, 22.5 }, { 30, 23 }, { 34, 24 }, { 36.5, 28 }, 2.2 }, -- right
  { { 26, 22.5 }, { 26, 25 }, { 25.5, 28 }, { 26, 31 }, 2.0 }, -- front
}
c:fillMask(c:ellipse(CX, 22.5, 3, 1), CAL[1])
local prev = HP.mask()
for _, s in ipairs(sps) do
  local m, sn, T = sepal(s[1], s[2], s[3], s[4], s[5])
  m:cut(prev)
  -- contact shadow on the fruit under each sepal
  m:shift(1, 1):each(function(x, y) if tom:has(x, y) and not m:has(x, y) and not prev:has(x, y) then c:put(x, y, GRN[1], ttok) end end)
  local id = X.tone(c, m, X.light(sn, { amb = 0.1, wrap = 0.3 }), CAL, { cuts = A.CUTS6, tok = ctok })
  m:each(function(x, y) local k = K(x, y) if id[k] and T[k] > 0.1 and T[k] < 0.85 and (x + y) % 3 == 0 then c:put(x, y, CAL[min(6, id[k] + 1)], ctok) end end)
  A.touch(m, prev):each(function(x, y) c:put(x, y, CAL[1], ctok) end)
  prev:add(m)
end
c:fillMask(c:ellipse(CX, 22.5, 2, 1), CAL[2])
c:put(25, 22, CAL[4], ctok)

-- stalk with a leaf (serrated leaflet)
local sm, sn2 = A.tube({ { 26, 22 }, { 26, 17 }, { 28, 13 }, { 32, 10 } }, function(t) return 1.3 - 0.35 * t end)
X.tone(c, sm, X.light(sn2, { amb = 0.18, wrap = 0.3 }), CAL, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ctok })
local lm, ln, LT, LS, len = A.blade(30, 11, 37, 7, 44, 11, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 3.4 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7)
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local ph = LT[k] * len / 2.6 + (LS[k] > 0 and 0.4 or 0)
  local fr = ph - floor(ph)
  if LT[k] > 0.08 and abs(LS[k]) > 1 - 0.5 * fr - 0.1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
X.tone(c, lm, X.light(ln, { amb = 0.15, wrap = 0.3 }), CAL, { cuts = A.CUTS6, tok = ctok })
lm:each(function(x, y) local k = K(x, y) if abs(LS[k]) < 0.2 and LT[k] > 0.05 and LT[k] < 0.9 then c:put(x, y, LS[k] <= 0 and CAL[6] or CAL[3], ctok) end end)

A.save(c, NAME)
