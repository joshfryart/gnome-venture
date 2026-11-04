-- dried-mushrooms (Opus single pass). Two dried "flower" shiitake: a tall one standing, cap tilted, on a slim
-- curving fibrous stem; a small one lying at its foot, upside down, showing its gill disc and cut stem.
-- Material: per-pixel dome light on a 6-tone cocoa-brown ramp, cream crackle network over the cap (the cracked
-- "flower" pattern), inrolled lit rim, cream gills with radial lines and a dark throat where the stem joins,
-- fibre streaks down the stem, paler end grain on the cut stem, cool reflected light, 2-tone ground shadow.
-- quirk: a tiny yellow birch leaf has dried stuck to the big cap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, atan, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.atan, math.sqrt, math.max, math.min
local c = A.new("dried-mushrooms")
local CAP   = { "#2a1616", "#46261e", "#673a28", "#8a5234", "#ac7046", "#cc925e" }
local CRK   = { "#a88a66", "#d2b88c", "#eedcb2" }
local GILL  = { "#6a5444", "#8e7660", "#b29a7e", "#cfba98", "#e6d6b2", "#f8eed0" }
local SPEC, BOUNCE = "#fff4d6", "#6a5c80"

c:groundShadow(36, 52, 17, 2)

-- stem of the standing mushroom: slim, curving, fibrous
local sm, sn, ST, SS = A.tube({ { 29, 31 }, { 30, 38 }, { 33, 44 }, { 32, 51 } }, function(t) return 2.3 + t * 0.6 end)
local sb = {}
sm:each(function(x, y) local k = K(x, y)
  if ST[k] < 0.18 then sb[k] = -2 end                                   -- dark throat under the cap
  if abs(SS[k] + 0.2) < 0.12 or abs(SS[k] - 0.45) < 0.12 then sb[k] = (sb[k] or 0) - 1 end   -- fibre streaks
end)
local gtok = { r = { name = "gill" } }
A.tone(c, sm, sn, GILL, { bias = sb, amb = 0.12, wrap = 0.3, tok = gtok })
-- flared stem foot
for _, p in ipairs{ { 29, 51, 3 }, { 30, 52, 3 }, { 35, 51, 2 }, { 35, 52, 1 } } do c:put(p[1], p[2], GILL[p[3]], gtok) end

-- cap: tilted dome; gill crescent visible under the rim
local CX, CY, ANG = 28, 22, -0.22
local ca, sa = cos(ANG), sin(ANG)
local cap, gill = HP.mask(), HP.mask()
local cn, CU, CV = {}, {}, {}
for y = 4, 36 do for x = 6, 52 do
  local dx, dy = x - CX, y - CY
  local u = (dx * ca + dy * sa) / 17.5
  local v = (-dx * sa + dy * ca)
  -- dome above the rim line (v < 2), height 12
  if v <= 2.2 and u * u + ((v - 2.2) / 13.5) ^ 2 <= 1 then
    cap:set(x, y)
    local k = K(x, y)
    local h = (v - 2.2) / 13.5
    cn[k] = { A.norm(u * ca * 0.9 - h * (-sa) * 0.9, u * sa * 0.9 + h * ca * 0.9, sqrt(max(0.05, 1 - u * u - h * h))) }
    CU[k], CV[k] = u, v
  elseif v > 2.2 and v <= 6.2 and u * u + ((v - 2.2) / 4.2) ^ 2 <= 0.92 then
    gill:set(x, y) CU[K(x, y)], CV[K(x, y)] = u, v
  end
end end
-- gills: cream, radial lines converging on the stem, darker toward the throat
gill:each(function(x, y) local k = K(x, y)
  local u, v = CU[k], CV[k]
  local i = 5 - floor((v - 2.2) * 0.8)
  if u > 0.35 then i = i - 1 end
  local ph = atan(u * 6, v - 1.0) * 6.5
  if cos(ph) > 0.55 then i = i - 1 end
  if abs(u) < 0.2 and v > 4.2 then i = 1 end
  c:put(x, y, GILL[max(1, min(6, i))], gtok)
end)
-- cap tone with crackle; inrolled rim lit along the bottom edge
local cb = {}
local pts = {}
for i = 1, 22 do pts[i] = { CX - 16 + X.hash(i, 1, 41) * 32, CY - 12 + X.hash(i, 2, 41) * 15 } end
local crack = {}
cap:each(function(x, y) local k = K(x, y)
  local d1, d2 = 1e9, 1e9
  for _, p in ipairs(pts) do
    local q = sqrt((x - p[1]) ^ 2 + (y - p[2]) ^ 2)
    if q < d1 then d2 = d1 d1 = q elseif q < d2 then d2 = q end
  end
  if d2 - d1 < 0.95 and CV[k] < -1.5 and abs(CU[k]) < 0.9 then crack[k] = true end
  if CV[k] > 0.8 then cb[k] = -1 end                                     -- underside of the rim curl
  if abs(CV[k] - 0.2) < 0.6 and CU[k] < 0.4 then cb[k] = 1 end          -- lit inrolled lip
end)
local ctok = { r = { name = "cap" } }
local cidx = A.tone(c, cap, cn, CAP, { bias = cb, amb = 0.06, wrap = 0.25, tok = ctok })
for k in pairs(crack) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local i = cidx[k] or 3
  c:put(x, y, CRK[i >= 5 and 3 or (i >= 3 and 2 or 1)], ctok)
end
-- dark row where the cap rim meets the gills
gill:each(function(x, y) if cap:has(x, y - 1) then c:put(x, y, GILL[2], gtok) end end)
A.bounce(c, cap, cn, BOUNCE, 0.62, ctok)
A.glint(c, cap, cn, SPEC, CAP[6], ctok, 30)

-- quirk: tiny dried birch leaf stuck on the cap (upper right)
do
  local lx, ly = 36, 12
  local map = { ".gG.", "gGGd", "GGd.", ".s.." }
  local LC = { g = "#ffe38a", G = "#f5b82e", d = "#c47a1e", s = "#8f4a1f" }
  for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if LC[ch] then c:put(lx + xx - 1, ly + yy - 1, LC[ch], ctok) end end end
end

-- small mushroom lying upside down at the foot: gill disc facing us, brown cap rim around it, cut stem stub
local SX, SY = 45, 47
local disc = c:ellipse(SX, SY, 8, 5)
local rimm = disc:copy():cut(c:ellipse(SX - 0.5, SY - 0.5, 6, 3.5))
local dn = X.sphere(SX - 0.5, SY - 0.5, 8, disc)
local rb = {}
A.tone(c, rimm, dn, CAP, { bias = rb, amb = 0.08, tok = ctok })
local face = disc:copy():cut(rimm)
face:each(function(x, y)
  local dx, dy = (x - SX + 0.5) / 6, (y - SY + 0.5) / 3.5
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local i = 4
  if cos(a * 7) > 0.6 then i = 3 end
  if dx + dy < -0.3 then i = i + 1 end
  if dy > 0.5 then i = i - 1 end
  if r < 0.5 then i = i - 1 end
  c:put(x, y, GILL[max(1, min(6, i))], gtok)
end)
-- cut stem stub, end grain paler with a darker ring
local stub = c:ellipse(SX - 1, SY - 1, 2, 1.5)
stub:each(function(x, y) c:put(x, y, GILL[6], gtok) end)
stub:edge():each(function(x, y) if x + y > (SX - 1) + (SY - 1) then c:put(x, y, GILL[3], gtok) end end)
c:put(SX - 1, SY - 1, GILL[5], gtok)
c:put(SX + 1, SY, GILL[2], gtok)                                        -- contact shadow of the stub on the gills
A.done(c, "dried-mushrooms")
