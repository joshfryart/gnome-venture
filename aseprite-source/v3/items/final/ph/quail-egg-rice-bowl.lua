-- quail-egg-rice-bowl (D10 final, Sonnet high). A cobalt-glazed bowl with a cream wave band and foot ring, heaped with
-- steaming sticky rice (individual lit grains), two halved soft-boiled quail eggs with jammy orange yolks, a glossy nori
-- sail standing at the back, scallion rings and sesame. Glaze: specular streak, cool bounce, lip highlight.
-- quirk: a whole speckled quail egg sits on top of the rice with a zigzag crack and one chip of shell missing.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("quail-egg-rice-bowl")

local BOWL = { "#1b2757", "#2a428a", "#3a62b0", "#5a8cd0", "#8cbce8", "#c8e6fa" }
local RICE = { "#8f84a6", "#b4a8c0", "#d6ccd2", "#ece4dc", "#fbf3e2", "#fffbee" }
local EGG  = { "#a9a0b8", "#c9c1cf", "#e4dfe2", "#f4f0ea", "#fffaf0", "#fffdf4" }
local YOLK = { "#a8541a", "#d9801e", "#f3a42a", "#ffc23e", "#ffdd6a", "#fff0a8" }
local SHELL = { "#6e4630", "#9a6a40", "#c4965c", "#e2bc84", "#f4dcae", "#fff0cc" }
local NORI = { "#0e1a1a", "#16292a", "#203a38", "#2e5148", "#46705c", "#6e9a80" }
local GRN  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CREAM = "#fff4d6"

c:groundShadow(32, 60, 17, 2.3)

-- bowl body (surface of revolution): rim ellipse centre (32,38) rx 21 ry 5, foot at y 57
local RY, RX, Y0 = 5, 21, 38
local function hw(y) local t = (y - Y0) / 19 return 8 + 13 * sqrt(max(0, 1 - t * t)) end
local body = HP.mask()
for y = Y0, 57 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do body:set(x, y) end end
body:add(c:ellipse(32, Y0, RX, RY))
body:cut(c:rect(0, 56, 63, 63):cut(c:rect(23, 56, 40, 63)))  -- foot ring: narrow tail under the body
local foot = c:rect(23, 55, 40, 58)
body:add(foot)
local bn = {}
body:each(function(x, y) local k = K(x, y)
  local h = max(4, y > Y0 and hw(y) or RX)
  local t = max(-0.97, min(0.97, (x - 32) / (h + 0.7)))
  local ny = ((y - Y0) / 19) * 0.7
  bn[k] = { A.norm(t, ny, sqrt(1 - t * t) * 0.9) }
end)
local btok = { r = { name = "bowl" } }
local bi = A.shade(c, body, bn, BOWL, { amb = 0.1, wrap = 0.3, tok = btok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- cool bounce on the lower right edge
body:edge():each(function(x, y) if x > 38 and y > 44 and y < 55 and not foot:has(x, y) then c:put(x, y, BOWL[4], btok) end end)
-- foot ring: darker, lit lip
for x = 23, 40 do c:put(x, 55, BOWL[1], btok) end
for x = 24, 39 do c:put(x, 56, x < 30 and BOWL[3] or BOWL[2], btok) c:put(x, 57, BOWL[1], btok) end
for x = 24, 28 do c:put(x, 56, BOWL[5], btok) end
-- wave band (cream) following the curve
for row = 0, 1 do
  for x0 = 12 + row * 3, 53, 6 do
    local h0 = hw(46 + row * 3)
    if abs(x0 + 1 - 32) < h0 - 2 then
      local y = 46 + row * 3
      -- little scallop: ( ) shapes as 3 px arch
      for _, d in ipairs{ { 0, 1 }, { 1, 0 }, { 2, 0 }, { 3, 1 } } do
        local x = x0 + d[1]
        if body:has(x, y + d[2]) then c:put(x, y + d[2], x < 30 and CREAM or "#e8d9b0", btok) end
      end
    end
  end
end
for x = 12, 53 do local h = hw(44) if abs(x - 32) < h - 1 and body:has(x, 44) then c:put(x, 44, bi[K(x, 44)] and BOWL[max(1, bi[K(x, 44)] - 1)] or BOWL[2], btok) end end
-- specular streak on the glaze
for _, p in ipairs{ { 15, 43 }, { 15, 44 }, { 16, 45 }, { 16, 46 }, { 17, 47 } } do c:put(p[1], p[2], BOWL[6], btok) end
-- rim: lip ring and dark inner wall
local rimO = c:ellipse(32, Y0, RX, RY)
local rimI = c:ellipse(32, Y0, RX - 2, RY - 1.5)
local lip = rimO:copy():cut(rimI)
lip:each(function(x, y) c:put(x, y, (y > Y0) and BOWL[5] or ((x < 32) and BOWL[6] or BOWL[4]), btok) end)
rimI:each(function(x, y) c:put(x, y, (x < 30) and BOWL[2] or BOWL[1], btok) end)
local frontLip = lip:copy():clip(c:rect(0, Y0 + 1, 63, 63))
frontLip:each(function(x, y) if x > 44 then c:put(x, y, BOWL[3], btok) end end)

-- rice mound: sits in the bowl, its base cut by the front lip
local mound = HP.mask()
for y = 18, 46 do for x = 10, 54 do
  local dx, dy = (x - 32) / 17.5, (y - 33) / 14.5
  if dx * dx + dy * dy <= 1 then
    local yf = Y0 + RY * sqrt(max(0, 1 - ((x - 32) / RX) ^ 2)) - 2
    if y <= yf then mound:set(x, y) end
  end
end end
local mn = X.pillow(mound, 7, 1.1)
local mtok = { r = { name = "rice" } }
local mb = {}
X.ao(mb, mound, c:rect(0, Y0 - 1, 63, 63), 1, -1)
local mi = A.shade(c, mound, mn, RICE, { amb = 0.18, wrap = 0.35, tok = mtok, bias = mb, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } })
-- grains: 3x1 lit dashes with a shade pixel underneath
local gr = {}
mound:each(function(x, y)
  if X.hash(x, y, 5) > 0.82 and mound:has(x + 2, y) and mound:has(x, y + 1) and not gr[K(x, y)] and not gr[K(x - 1, y)] and not gr[K(x - 2, y)] then
    local i = mi[K(x, y)] or 4
    local a = ((x * 7 + y * 3) % 3 == 0)
    for dx = 0, 2 do gr[K(x + dx, y)] = true c:put(x + dx, y, RICE[min(6, i + 1)], mtok) end
    c:put(x + 1, y + 1, RICE[max(1, i - 1)], mtok) if a then c:put(x + 2, y + 1, RICE[max(1, i - 1)], mtok) end
  end
end)

-- nori sail at the back right
local nori = c:poly{ { 41, 28 }, { 45, 17 }, { 49, 19 }, { 48, 30 }, { 45, 33 } }
local nn = {}
nori:each(function(x, y) nn[K(x, y)] = { A.norm(-0.2 + (x - 45) * 0.06, -0.1, 1) } end)
local ntok = { r = { name = "nori" } }
local ni = A.shade(c, nori, nn, NORI, { amb = 0.15, wrap = 0.3, tok = ntok, cuts = { 0.25, 0.45, 0.62, 0.78, 0.9 } })
nori:each(function(x, y) if (x + y * 2) % 5 == 0 then c:put(x, y, NORI[max(1, (ni[K(x, y)] or 3) - 1)], ntok) end end)
for _, p in ipairs{ { 44, 20 }, { 45, 19 }, { 44, 21 } } do c:put(p[1], p[2], NORI[6], ntok) end
local nbias = {}
for x = 41, 46 do local y = 31 + floor((x - 41) * 0.3) if nori:has(x, y) then c:put(x, y, NORI[1], ntok) end end

-- halved quail eggs on the rice
local function half(cx, cy, ang, rx, ry)
  local ux, uy = cos(ang), sin(ang)
  local m = A.rell(cx, cy, ux, uy, rx, ry)
  local n = X.pillow(m, 2.4, 0.8)
  local tok = { r = { name = "egg" .. cx } }
  local bs = {}
  X.ao(bs, m, mound:copy():cut(m), 0, 0)
  A.shade(c, m, n, EGG, { amb = 0.2, wrap = 0.35, tok = tok, cuts = { 0.28, 0.46, 0.62, 0.78, 0.9 } })
  -- yolk
  local ym = A.rell(cx - ux * 0.2 + 0.3, cy - uy * 0.2 + 0.2, ux, uy, rx * 0.55, ry * 0.62)
  local yn = X.pillow(ym, 2.0, 0.9)
  A.shade(c, ym, yn, YOLK, { amb = 0.15, wrap = 0.3, tok = { r = { name = "yolk" .. cx } }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  local bx, by = A.specAt(ym, yn, 20)
  c:put(bx, by, "#fffbe8", tok) c:put(bx + 1, by, YOLK[6], tok)
  -- underside shade line
  m:edge():each(function(x, y) c:put(x, y, (x + y > cx + cy) and "#7a6e94" or "#a89cc0", tok) end)
  return m
end
half(24, 27, -0.3, 5.2, 3.6)
half(37, 29, 0.25, 5.2, 3.7)

-- scallion rings and sesame
for _, p in ipairs{ { 31, 23 }, { 18, 33 }, { 44, 35 }, { 29, 36 } } do
  c:put(p[1], p[2], GRN[3], mtok) c:put(p[1] + 1, p[2], GRN[4], mtok) c:put(p[1], p[2] + 1, GRN[2], mtok) c:put(p[1] + 1, p[2] + 1, GRN[2], mtok)
end
for _, p in ipairs{ { 22, 33 }, { 40, 24 }, { 33, 33 }, { 15, 38 }, { 47, 31 }, { 28, 21 } } do c:put(p[1], p[2], "#d9b56a", mtok) end

-- quirk: whole speckled quail egg on top, cracked, one chip missing
local ex, ey = 32, 17
local em = A.rell(ex, ey, 0.25, -1, 4.8, 3.3)
local en = X.pillow(em, 3.2)
local etok = { r = { name = "whole" } }
local ei = A.shade(c, em, en, SHELL, { amb = 0.14, wrap = 0.3, tok = etok, cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
em:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 9) > 0.68 then c:put(x, y, (X.hash(x, y, 4) > 0.5) and "#4a2a1e" or "#7a4a30", etok) end
end)
for _, p in ipairs{ { 29, 14 }, { 30, 15 }, { 29, 16 }, { 30, 17 }, { 31, 18 } } do if em:has(p[1], p[2]) then c:put(p[1], p[2], SHELL[1], etok) end end
for _, p in ipairs{ { 31, 14 }, { 32, 13 } } do c:put(p[1], p[2], SHELL[1], etok) end
c:put(30, 13, SHELL[6], etok) c:put(31, 13, SHELL[5], etok)
-- missing chip shows pale membrane + yolk glimpse
for _, p in ipairs{ { 33, 15 }, { 34, 15 }, { 33, 16 } } do c:put(p[1], p[2], EGG[5], etok) end
c:put(34, 16, YOLK[4], etok)
-- contact shadow of the egg on the rice
for x = 29, 35 do if mound:has(x, 22) then c:put(x, 22, RICE[1], mtok) end end
A.save(c, "quail-egg-rice-bowl")
