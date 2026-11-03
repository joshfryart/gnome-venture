-- ico-jar (final, Opus). A slim glass jar of strawberry jam with a blue gingham cloth cap tied on with twine.
-- Material: jam lit per pixel through the glass as a 6-tone cylinder (dark thick edges), glass cues (empty headspace,
-- tall pale specular streak, bright rim on the right, thick pale glass foot); cloth woven as gingham over a lit dome
-- with a scalloped hem and an AO row where it meets the glass; twisted twine with a knot and two tails; cream paper
-- label wrapped on the cylinder with a strawberry print. Ground shadow under (it stands).
-- quirk: a drip of jam has run down over the label.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-jar")
local JAM   = { "#4a1030", "#6e1a38", "#9e2438", "#c8363a", "#e8584a", "#ff9a7a" }
local GLASS = { "#5f9ab0", "#8cc4d0", "#bfe4e6", "#e4f8f4" }
local PAPER = { "#a8846a", "#d6b894", "#eed8b4", "#faeccc", "#fff4d6" }
local CB    = { "#24306e", "#2e4a9a", "#3e6ec4", "#5e94e0", "#8cbcf2" }     -- gingham dark cells
local CM    = { "#4a5a92", "#6a80bc", "#8aa6dc", "#a8c4ee", "#c8dcfa" }     -- gingham mixed cells
local CC    = { "#9c8aa0", "#cbbcc4", "#e6dcd8", "#f6eee2", "#fff8ea" }     -- gingham cream cells
local TW    = { "#7a4a22", "#b8803e", "#e0b468", "#f8dc98" }

c:groundShadow(32, 53, 14, 2)

-- glass body
local X0, X1, Y0, Y1 = 21, 43, 21, 52
local body = c:rrect(X0, Y0, X1, Y1, 5)
local MX, HW = (X0 + X1) / 2, (X1 - X0) / 2 + 0.5
local pn = X.pillow(body, 4)
local bn = {}
body:each(function(x, y) local u = max(-0.97, min(0.97, (x - MX) / HW)) local p = pn[K(x, y)]
  bn[K(x, y)] = { A.norm(u * 0.8 + p[1] * 0.4, p[2] * 0.7, sqrt(1 - u*u) * 0.9 + p[3] * 0.2) } end)
local jtok, gtok = { r = { name = "jam" } }, { r = { name = "glass" } }
local jbias = {}
body:each(function(x, y) local u = abs((x - MX) / HW) if u > 0.86 then jbias[K(x, y)] = -1 end end)
local jidx = A.shade(c, body, bn, JAM, { amb = 0.06, wrap = 0.25, cuts = { 0.18, 0.34, 0.52, 0.72, 0.92 }, bias = jbias, tok = jtok })
-- headspace (empty glass) and meniscus
body:each(function(x, y)
  if y <= 23 then
    local u = (x - MX) / HW
    c:put(x, y, GLASS[(u < -0.5) and 4 or (u > 0.6 and 1 or (u > 0.1 and 2 or 3))], gtok)
  elseif y == 24 then c:put(x, y, JAM[min(6, (jidx[K(x, y)] or 3) + 1)], jtok) end
end)
-- thick glass foot
body:each(function(x, y) if y >= 50 then local u = (x - MX) / HW
  c:put(x, y, GLASS[y == 52 and 1 or ((u < -0.4) and 3 or 2)], gtok) end end)
for x = X0 + 2, X1 - 2 do c:put(x, 49, JAM[1], jtok) end
-- right rim (reflected light through the glass wall)
for y = 26, 47 do c:put(X1, y, JAM[4], jtok) end
for y = 29, 44 do c:put(X1 - 1, y, JAM[2], jtok) end
-- tall specular streak on the left, plus a short second one
for y = 26, 46 do c:put(24, y, GLASS[4], gtok) if y < 44 then c:put(25, y, JAM[6], jtok) end end
for y = 27, 30 do c:put(27, y, JAM[6], jtok) end

-- label (cream paper wrapped on the cylinder)
local lab = c:rect(26, 31, 40, 42)
local ln = {}
lab:each(function(x, y) local u = max(-0.95, min(0.95, (x - MX) / HW)) ln[K(x, y)] = { A.norm(u * 0.9, (y == 31 and -0.3 or 0), sqrt(1 - u*u)) } end)
local ptok = { r = { name = "paper" } }
local lidx = A.shade(c, lab, ln, PAPER, { amb = 0.2, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ptok })
for x = 26, 40 do c:put(x, 43, JAM[1], jtok) end      -- contact shadow under label
-- print border (thin dashed rule) and strawberry
for x = 27, 39 do if x % 2 == 0 then A.step(c, lidx, PAPER, x, 32, -1, ptok) A.step(c, lidx, PAPER, x, 41, -1, ptok) end end
local SB = { r = "#e8493b", R = "#b52e3f", h = "#ff8a5c", g = "#7cc35a", G = "#3f9150", s = "#ffe38a", d = "#6e2038" }
A.map(c, {
  ".g.g.",
  "GgGgG",
  "hrrrR",
  "rsrsR",
  ".rrR.",
  "..d..",
}, 31, 34, SB, ptok)
-- quirk: a drip of jam run down from the rim over the label
local DR = { a = JAM[4], b = JAM[3], c = JAM[5], d = JAM[2] }
A.map(c, {
  "ab", "ab", "ab", "ab", "ab", "ab", "ab", "ab",
  "cb", "ab", "ab", "cab", "aab", "aab", ".d",
}, 37, 23, DR, jtok)

-- cloth cap (gingham over a dome) with a scalloped hem
local cap = c:rrect(23, 10, 41, 15, 4):add(c:poly{ { 22, 15 }, { 42, 15 }, { 45, 21 }, { 19, 21 } })
-- scallops: remove every 4th column pair at the hem
for x = 19, 45 do if (x - 19) % 5 == 4 then cap:cut(c:rect(x, 21, x, 21)) end end
cap:add(c:rect(20, 22, 21, 22)):add(c:rect(25, 22, 26, 22)):add(c:rect(30, 22, 31, 22)):add(c:rect(35, 22, 36, 22)):add(c:rect(40, 22, 41, 22))
local cn0 = X.pillow(cap, 3)
local cn = {}
cap:each(function(x, y) local p = cn0[K(x, y)] local u = max(-0.95, min(0.95, (x - 32) / 13))
  -- folds: soft vertical pleats on the skirt
  local f = (y >= 16) and 0.25 * math.sin((x - 19) * 1.25) or 0
  cn[K(x, y)] = { A.norm(p[1] * 0.5 + u * 0.6 + f, p[2] * 0.8 + (y >= 16 and 0.2 or 0), p[3]) } end)
local ctok = { r = { name = "cloth" } }
local v = X.light(cn, { amb = 0.1, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs{ 0.25, 0.45, 0.65, 0.85 } do if v[k] >= t then i = j + 1 end end
  if y >= 20 then i = max(1, i - 1) end          -- hem underside
  local a, b = ((x - 19) // 2) % 2 == 0, ((y - 10) // 2) % 2 == 0
  local R = (a and b) and CB or ((a or b) and CM or CC)
  c:put(x, y, R[i], ctok)
end)
-- twine round the neck: twisted (diagonal) with a knot and two tails
local ttok = { r = { name = "twine" } }
for x = 20, 44 do for y = 17, 18 do if cap:has(x, y) then
  local u = (x - 32) / 13
  local ph = (x + (y == 18 and 1 or 0)) % 3
  local i = (ph == 0) and 2 or 3
  if ph == 2 and u < 0.2 then i = 4 end
  if u > 0.55 then i = i - 1 end
  c:put(x, y, TW[max(1, i)], ttok) end end end
for x = 20, 44 do if cap:has(x, 19) then c:put(x, 19, (((x - 19) // 2) % 2 == 0) and CB[1] or CM[1], ctok) end end
-- bow knot on the front-left with two loops and two tails
A.map(c, {
  "c...c",
  "bc.cb",
  ".bdb.",
  ".bdb.",
  ".c.b.",
  "c...b",
  "b....",
}, 23, 15, { b = TW[2], c = TW[4], d = TW[1] }, ttok)
-- cloth pop
c:put(27, 11, "#fff8ea", ctok) c:put(28, 11, "#fff8ea", ctok)
A.save(c, "ico-jar")
