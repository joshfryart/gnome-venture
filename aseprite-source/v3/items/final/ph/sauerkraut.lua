-- sauerkraut (final, Opus-level single pass). A slim glass fermenting jar of pale shredded cabbage, the mouth covered
-- with a red gingham cloth and tied with twisted twine and a bow. Materials: glass (rim light, pale core, cool reflected
-- edge, vertical gleam), curled cabbage shreds with cores and dark gaps, caraway seeds, brine meniscus and bubbles, a green
-- outer leaf pressed to the glass, gingham weave on pleated cloth, twisted twine.
-- quirk: one strand of kraut has crept out from under the cloth and hangs down the outside of the jar, a brine drop on its tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("sauerkraut")
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash

local GLASS = { "#2f5c88", "#3f7fa6", "#5ea6c0", "#8acfd6", "#bcebe6", "#eefff8" }
local CAB = { "#586a2e", "#869a42", "#b2c25c", "#d2dc7c", "#eaeea2", "#fbf6cc" }
local LF = { "#244f2c", "#37722e", "#569a40", "#7cba52", "#a6d474", "#d2eea0" }
local CR = { "#a89aae", "#cfc2c4", "#eadcc8", "#fff4d6", "#fffaea" }
local RR = { "#4a1830", "#7a2038", "#a82c3e", "#d03a44", "#ec5a54", "#ff8a74" }
local TW = { "#4e3424", "#7a5a36", "#a88448", "#d0aa68", "#ecd08c" }

c:groundShadow(32, 57, 15, 2)

-- ---- glass jar ----
local glass = HP.mask()
local function hw(y)
  if y <= 29 then return 9.8 end
  if y <= 34 then return 9.8 + (y - 29) * 0.8 end
  if y <= 52 then return 13.8 end
  return 13.8 - (4 - sqrt(max(0, 16 - (y - 52) ^ 2)))
end
for y = 24, 56 do
  local w = hw(y)
  for x = floor(32 - w + 0.5), floor(31 + w + 0.5) do glass:set(x, y) end
end
local inner = glass:shrink(2)
local gn = X.pillow(glass, 3.4)
local gv = X.light(gn, { amb = 0.3, wrap = 0.4 })
X.tone(c, glass, gv, GLASS, { cuts = { 0.3, 0.45, 0.6, 0.74, 0.88 } })
-- thick glass bottom: pale band
glass:each(function(x, y) if not glass:has(x, y + 1) or not glass:has(x, y + 2) then if y > 52 then c:px(x, y, GLASS[4]) end end end)

-- ---- contents ----
local air = HP.mask() local fill = HP.mask()
inner:each(function(x, y) if y < 32 then air:set(x, y) else fill:set(x, y) end end)
air:each(function(x, y) c:px(x, y, (y == 31) and GLASS[4] or GLASS[5]) end)
local fn = {}
fill:each(function(x, y)
  local t = max(-0.95, min(0.95, (x - 31.5) / 12.5))
  local s = sqrt(1 - t * t)
  local up = max(-0.5, min(0.6, (y - 44) / 20))
  fn[K(x, y)] = { t * 0.9, up * 0.6, s }
end)
local fv = X.light(fn, { amb = 0.36, wrap = 0.5 })
local fidx = X.tone(c, fill, fv, CAB, { cuts = { 0.3, 0.44, 0.58, 0.72, 0.88 } })
-- shreds: short curled strands, lit top, dark gap beneath
local nstr = 0
for i = 1, 90 do
  local sx = 21 + floor(hash(i, 3, 5) * 22)
  local sy = 33 + floor(hash(i, 4, 6) * 21)
  local ang = (hash(i, 5, 7) - 0.5) * 1.3 + (i % 3 == 0 and 1.1 or 0)
  local L = 4 + floor(hash(i, 6, 8) * 5)
  local pts = {}
  for s = 0, L do
    local a = ang + sin(s * 0.9 + i) * 0.55
    pts[#pts + 1] = { sx + s * cos(ang) + sin(s * 0.7 + i) * 0.9, sy + s * sin(ang) + sin(s * 0.9 + i) * 0.9 }
  end
  local core = hash(i, 9, 2) > 0.8
  for j, p in ipairs(pts) do
    local x, y = floor(p[1] + 0.5), floor(p[2] + 0.5)
    if fill:has(x, y) then
      local k = K(x, y)
      local base = fidx[k] or 3
      local hi = core and 6 or min(6, base + 1 + ((j % 3 == 0) and 1 or 0))
      c:px(x, y, CAB[hi])
      if fill:has(x, y + 1) then
        -- shadow gap under the strand (only where nothing lit follows)
        c:px(x, y + 1, CAB[max(1, base - 2)])
      end
    end
  end
end
-- caraway seeds
for _, p in ipairs{ { 25, 40 }, { 36, 37 }, { 29, 48 }, { 40, 46 }, { 33, 52 } } do
  if fill:has(p[1], p[2]) then c:px(p[1], p[2], "#5a381f") c:px(p[1] + 1, p[2], "#8a5a30") end
end
-- brine meniscus, cloudy rim
fill:each(function(x, y) if y == 32 then c:px(x, y, "#f8fac8") elseif y == 33 then c:px(x, y, CAB[2]) end end)
-- green outer leaf pressed against the right glass
local lm = HP.mask()
fill:each(function(x, y) local e = 42 - 1.6 * sin((y - 34) * 0.18) if x >= e and y >= 35 and y <= 53 then lm:set(x, y) end end)
local ln = {}
lm:each(function(x, y)
  local t = max(-0.9, min(0.9, (x - 40.2) / 2.8))
  ln[K(x, y)] = { t * 0.8 - 0.25, -0.1, sqrt(1 - t * t * 0.4) }
end)
local lidx = X.tone(c, lm, X.light(ln, { amb = 0.28, wrap = 0.4 }), LF, { cuts = { 0.3, 0.45, 0.6, 0.74, 0.88 } })
lm:each(function(x, y) local e = 42 - 1.6 * sin((y - 34) * 0.18)
  if abs(x - (e + 1.6)) < 0.6 then c:px(x, y, LF[6]) end        -- vein / fold line
  if x == floor(e) then c:px(x, y, LF[2]) end end)
-- bubbles (little rings with a glint)
for _, p in ipairs{ { 23, 38 }, { 25, 46 }, { 38, 40 }, { 27, 53 } } do
  c:px(p[1], p[2], "#f4fff0") c:px(p[1] + 1, p[2], "#c8f0e0") c:px(p[1], p[2] + 1, "#a4dcc8") c:px(p[1] + 1, p[2] + 1, "#80c0b0")
end
-- glass gleams on top of everything inside
for y = 36, 51 do if y % 8 ~= 0 then c:px(21, y, GLASS[6]) end end
c:px(22, 36, GLASS[5]) c:px(22, 51, GLASS[5])
c:px(24, 30, GLASS[6]) c:px(25, 30, GLASS[5]) c:px(23, 31, GLASS[5])
for y = 40, 50 do c:px(42, y, GLASS[4]) end   -- reflected cool light
c:px(41, 52, GLASS[4]) c:px(40, 53, GLASS[3])
for x = 25, 38 do if x % 5 ~= 0 then c:px(x, 54, GLASS[4]) end end

-- ---- cloth ----
local cloth = HP.mask()
local dome = HP.mask() local skirt = HP.mask()
local rowsD = { [11] = { 26, 37 }, [12] = { 24, 39 }, [13] = { 23, 40 }, [14] = { 22, 41 }, [15] = { 21, 42 }, [16] = { 21, 42 }, [17] = { 21, 42 },
  [18] = { 21, 42 }, [19] = { 21, 42 }, [20] = { 21, 42 }, [21] = { 22, 41 } }
for y, r in pairs(rowsD) do for x = r[1], r[2] do dome:set(x, y) end end
local rowsS = { [24] = { 20, 43 }, [25] = { 19, 44 }, [26] = { 18, 45 }, [27] = { 18, 45 }, [28] = { 18, 45 } }
for y, r in pairs(rowsS) do for x = r[1], r[2] do skirt:set(x, y) end end
for x = 18, 45 do local d = floor((x - 18) / 4) % 2 if d == 0 or x % 4 == 1 then skirt:set(x, 29) end end
for x = 20, 43 do if (floor((x - 18) / 4) % 2 == 0) and x % 4 == 1 then skirt:set(x, 30) end end
local function cloth_paint(m, nfun, bias)
  local n = {}
  m:each(function(x, y) n[K(x, y)] = nfun(x, y) end)
  local v = X.light(n, { amb = 0.3, wrap = 0.5 })
  m:each(function(x, y)
    local k = K(x, y)
    local l = 1
    for j, t in ipairs{ 0.28, 0.46, 0.64, 0.82 } do if v[k] >= t then l = j + 1 end end
    l = max(1, min(5, l + (bias[k] or 0)))
    local hb = floor(y / 2) % 2 == 0
    local vb = floor(x / 2) % 2 == 0
    local hex
    if hb and vb then hex = RR[l] elseif hb or vb then hex = RR[min(6, l + 2)] else hex = CR[l] end
    c:px(x, y, hex)
  end)
end
local dn = X.pillow(dome, 5)
local dbias = {}
cloth_paint(dome, function(x, y)
  local nn = dn[K(x, y)]
  local nx = nn[1] + 0.22 * sin(x * 0.9 + y * 0.35)
  local l = sqrt(nx * nx + nn[2] * nn[2] + nn[3] * nn[3])
  return { nx / l, nn[2] / l, nn[3] / l }
end, dbias)
local sbias = {}
for x = 18, 45 do sbias[K(x, 24)] = -1 sbias[K(x, 25)] = -1 end
cloth_paint(skirt, function(x, y)
  local nx = 0.78 * sin((x - 18) * pi / 3.5)
  return { nx, 0.12, sqrt(max(0.1, 1 - nx * nx)) }
end, sbias)
-- skirt hem shadow row + crisp frill rim
skirt:each(function(x, y) if not skirt:has(x, y + 1) then c:px(x, y, RR[1]) end end)
-- fold deep lines under each pleat valley
for x = 18, 45 do if (x - 18) % 7 == 5 then for y = 25, 28 do if skirt:has(x, y) then c:px(x, y, (floor(y / 2) % 2 == 0) and RR[1] or RR[2]) end end end end
-- dome crest sheen
c:px(26, 13, CR[5]) c:px(27, 13, CR[5]) c:px(25, 14, CR[5]) c:px(26, 12, CR[5])
-- puckered dome rim row above twine: AO
for x = 22, 41 do if dome:has(x, 21) then c:px(x, 21, (floor(x / 2) % 2 == 0) and RR[1] or RR[2]) end end

-- ---- twine (two wraps, twisted) ----
for y = 22, 23 do
  for x = 21, 42 do
    local tw = ((x + y * 2) % 4) < 2
    local i
    if y == 22 then i = tw and 4 or 3 else i = tw and 3 or 2 end
    if x == 21 or x == 42 then i = 1 end
    c:px(x, y, TW[i])
  end
end
for x = 23, 40, 4 do c:px(x, 22, TW[5]) end
-- bow: knot, two loops, two tails
local function ringmask(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  return m, m:copy():cut(m:shrink(1))
end
local kx, ky = 41, 22
local l1, r1 = ringmask(44.5, 19.5, 2.8, 2.0)
local l2, r2 = ringmask(45, 24.5, 2.8, 1.9)
for _, r in ipairs{ r1, r2 } do
  r:each(function(x, y)
    local i = ((x + y * 2) % 4 < 2) and 4 or 3
    if y > 22 or x > 45 then i = i - 1 end
    c:px(x, y, TW[max(1, i)])
  end)
end
for dy = -1, 1 do for dx = -1, 1 do c:px(kx + dx + 1, ky + dy, TW[(dx + dy < 0) and 4 or 3]) end end
c:px(kx + 2, ky + 1, TW[2]) c:px(kx, ky + 1, TW[2])
-- tails hanging over the glass
local function tail(pts, w)
  local m, n, T = A.tube(pts, function(t) return w * (1 - t * 0.25) end)
  X.tone(c, m, X.light(n, { amb = 0.2, wrap = 0.4 }), TW, { cuts = { 0.25, 0.45, 0.65, 0.85 } })
  m:each(function(x, y) local k = K(x, y) if ((x + y * 2) % 4 < 2) and T[k] < 0.92 then c:px(x, y, TW[4]) end end)
  return m
end
local ta = tail({ { 42, 23 }, { 43.5, 27 }, { 44, 32 }, { 43, 35 } }, 0.95)
local tb = tail({ { 41, 24 }, { 40.2, 28 }, { 40.8, 31 }, { 39.6, 34 } }, 0.9)
-- cast shadow of the knot under the skirt
for _, p in ipairs{ { 41, 24 }, { 42, 24 } } do c:px(p[1], p[2], TW[1]) end
-- frayed ends
c:px(43, 36, TW[5]) c:px(42, 36, TW[3]) c:px(39, 35, TW[5]) c:px(40, 35, TW[3])

-- ---- quirk: a kraut strand hanging out from under the cloth ----
local sm, sn, ST = A.tube({ { 20, 29 }, { 17.4, 33 }, { 20, 38 }, { 18.2, 43 } }, function(t) return 1.2 - 0.35 * t end)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.3, wrap = 0.4 }), CAB, { cuts = { 0.25, 0.4, 0.55, 0.7, 0.86 } })
sm:each(function(x, y) local k = K(x, y) if (floor(ST[k] * 14)) % 4 == 3 and abs(sn[k][1]) < 0.4 then c:px(x, y, CAB[2]) end end)
-- the brine drop on the tip
c:px(18, 45, "#8fe0e0") c:px(19, 45, "#5ca8c8") c:px(18, 46, "#4a90b8")
c:px(17, 44, "#f4fff8")
-- cloth hem shadow on strand head
for x = 18, 22 do if sm:has(x, 30) then c:px(x, 30, CAB[1]) end end
A.save(c, "sauerkraut")
