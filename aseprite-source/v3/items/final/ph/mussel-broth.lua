-- mussel-broth (final, Opus). A shallow teal-glazed bowl on a short foot (round body lit per pixel, a white
-- specular streak, cream glazed rim with a bright near lip, darker inner wall), filled with golden saffron broth
-- (glossy oil beads, herb flecks, a shade line under the far rim). Two mussels stand in it: an open one showing
-- orange meat inside a pearly lip, and a closed blue-black one with growth rings and a glint.
-- quirk: an empty half-shell hangs hooked over the right rim, pearly nacre side out.
local NAME = "mussel-broth"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLZ = { "#1e2c4e", "#2a4a7a", "#3a6ea0", "#4f94bf", "#7cbfd6", "#c0ecec" }
local RIM = { "#8a8090", "#b8b0b0", "#ded4c4", "#f4ead2", "#fff4d6" }
local BRO = { "#8a5a2a", "#b9803a", "#d9a64e", "#ecc56a", "#f7de94", "#fff0c0" }
local SHL = { "#14121e", "#1f1d33", "#2c2c4c", "#3e4368", "#5c6690", "#8a98c0" }
local NAC = { "#6a6aa0", "#9a9ac8", "#c8c4e4", "#ece8f6" }
local MEAT = { "#8a3a1e", "#c25a24", "#e8812e", "#f8a446", "#ffcb7a", "#ffe6b0" }
local HERB = { "#24544a", "#3f9150", "#7cc35a" }

local CX, CY = 30, 36
c:groundShadow(CX, 55, 13, 1.5)

-- foot
local foot = c:poly{ { 23, 49 }, { 37, 49 }, { 39, 53 }, { 21, 53 } }
-- bowl body (lower half ellipse below the rim line)
local body = HP.mask()
c:ellipse(CX, CY, 22, 14):each(function(x, y) if y >= CY then body:set(x, y) end end)
foot:cut(body)
local ftok = { r = { name = "foot" } }
foot:each(function(x, y)
  local i = 3
  if x < 26 then i = 4 end
  if x > 34 then i = 2 end
  if y == 49 or y == 50 then i = max(1, i - 1) end         -- AO under the bowl
  if y == 53 then i = max(1, i - 1) end
  c:put(x, y, GLZ[i], ftok)
end)
local bn = {}
body:each(function(x, y)
  local nx, ny = (x - CX) / 22.5, (y - CY) / 14.5
  local q = 1 - nx * nx - ny * ny
  bn[K(x, y)] = { A.norm(nx, ny * 0.8 + 0.15, sqrt(max(q, 0.03))) }
end)
local btok = { r = { name = "bowl" } }
local bidx = A.shade(c, body, bn, GLZ, { amb = 0.08, wrap = 0.25, tok = btok })
-- cool reflected light on the lower-right
body:edge():each(function(x, y) if x > CX + 6 and y > CY + 6 then c:put(x, y, GLZ[3], btok) end end)
-- specular streak, ceramic
for _, q in ipairs{ { 13, 40, 6 }, { 13, 41, 6 }, { 14, 42, 6 }, { 14, 43, 5 }, { 15, 44, 5 }, { 12, 39, 5 } } do c:put(q[1], q[2], GLZ[q[3]], btok) end
c:put(17, 46, RIM[5], btok)
-- a thin glaze band (darker) just under the rim
for x = CX - 21, CX + 21 do local y = CY + 2 if body:has(x, y) then c:put(x, y, GLZ[max(1, (bidx[K(x, y)] or 3) - 1)], btok) end end

-- rim ring (top ellipse), inner wall, broth
local outer = c:ellipse(CX, CY, 22, 5)
local innerE = c:ellipse(CX, CY, 20, 4)
local rim = outer:copy():cut(innerE)
local rtok = { r = { name = "rim" } }
rim:each(function(x, y)
  local i = 3
  if y > CY then i = 4 end                 -- near lip faces up toward the light
  if y > CY and x < CX then i = 5 end
  if y < CY and x > CX + 8 then i = 2 end
  if y >= CY + 4 then i = (x < CX) and 4 or 3 end
  c:put(x, y, RIM[i], rtok)
end)
local broth = c:ellipse(CX, CY + 1, 19, 3)
broth:clip(innerE)
local wall = innerE:copy():cut(broth)
wall:each(function(x, y) c:put(x, y, (x < CX - 6) and GLZ[2] or GLZ[3], { r = { name = "wall" } }) end)

-- mussel masks (for broth AO)
local function shell(P, w0, w1)
  return A.tube(P, function(t) return w0 + w1 * sin(pi * (0.08 + 0.42 * t)) end)
end
-- open mussel (left): dark back valve + front valve showing meat
local backP = { { 24, 38 }, { 23, 34 }, { 21, 30 }, { 18, 26 } }
local back, bkn, BT, BS = shell(backP, 0.4, 3.2)
local frontP = { { 23, 39 }, { 21, 36 }, { 18, 33 }, { 14, 30 } }
local front, frn, FT, FS = shell(frontP, 0.4, 3.0)
-- closed mussel (right)
local cP = { { 38, 38 }, { 40, 34 }, { 42, 30 }, { 45, 26 } }
local cm, cn, CT, CS = shell(cP, 0.4, 3.3)
local all = back:copy():add(front):add(cm)

local bb = {}
broth:each(function(x, y) if not innerE:has(x, y - 2) or not innerE:has(x - 2, y - 1) then bb[K(x, y)] = -1 end end)
X.ao(bb, broth, all, 1, -1)
A.cast(bb, broth, all, 1, 1, -1)
local bnn = X.pillow(broth, 2)
local otok = { r = { name = "broth" } }
A.shade(c, broth, bnn, BRO, { amb = 0.4, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.62, 0.86 }, bias = bb, tok = otok })
-- oil beads + herb flecks
for _, q in ipairs{ { 30, 37 }, { 34, 38 }, { 27, 39 } } do c:put(q[1], q[2], BRO[6], otok) c:put(q[1] + 1, q[2], BRO[3], otok) end
for _, q in ipairs{ { 32, 36, 2 }, { 26, 37, 3 }, { 36, 37, 1 }, { 44, 37, 2 }, { 15, 37, 2 }, { 37, 39, 3 } } do
  if broth:has(q[1], q[2]) then c:put(q[1], q[2], HERB[q[3]], otok) end end

-- shells
local function darkShell(m, n, T, tok)
  local idx = A.shade(c, m, n, SHL, { amb = 0.08, wrap = 0.3, tok = tok })
  m:each(function(x, y) local k = K(x, y) local t = T[k]
    -- growth rings: darker arcs across the shell
    if (t > 0.42 and t < 0.47) or (t > 0.66 and t < 0.7) or (t > 0.86 and t < 0.9) then c:put(x, y, SHL[max(1, idx[k] - 1)], tok) end
  end)
  local gx, gy = A.specAt(m, n, 30)
  if gx then c:put(gx, gy, NAC[4], tok) c:put(gx, gy + 1, SHL[6], tok) end
  return idx
end
darkShell(back, bkn, BT, { r = { name = "back" } })
-- front valve: pearly lip, orange meat inside
local ftk = { r = { name = "front" } }
front:cut(c:ellipse(0, 0, 0, 0))
local lip = front:copy():cut(front:shrink(1))
local meat = front:shrink(1)
lip:each(function(x, y) local s = FS[K(x, y)] c:put(x, y, (s and s < 0) and NAC[3] or NAC[2], ftk) end)
c:put(14, 30, SHL[3], ftk)
local mn = X.pillow(meat, 2)
local mb = {}
X.ao(mb, meat, lip, 1, 0)
local midx = A.shade(c, meat, mn, MEAT, { amb = 0.12, wrap = 0.3, tok = ftk })
-- frilly mantle edge: darker scallop along the meat's shade side
meat:each(function(x, y) local s = FS[K(x, y)] if s and s > 0.25 and (x + y) % 2 == 0 then c:put(x, y, MEAT[2], ftk) end end)
local gx, gy = A.specAt(meat, mn, 30)
if gx then c:put(gx, gy, MEAT[6], ftk) end
-- closed mussel
darkShell(cm, cn, CT, { r = { name = "closed" } })

-- quirk: empty half-shell hooked over the right rim, nacre side out
local qP = { { 50, 34 }, { 52, 37 }, { 53, 41 }, { 54, 46 } }
local qm, qn, QT, QS = shell(qP, 0.4, 2.8)
local qtok = { r = { name = "hook" } }
local qlip = qm:copy():cut(qm:shrink(1))
local qin = qm:shrink(1)
qlip:each(function(x, y) c:put(x, y, SHL[(QS[K(x, y)] or 0) < 0 and 4 or 2], qtok) end)
local qi = A.shade(c, qin, X.pillow(qin, 2), NAC, { amb = 0.2, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = qtok })
qin:each(function(x, y) local t = QT[K(x, y)] if t > 0.55 and t < 0.6 then c:put(x, y, NAC[2], qtok) end end)
c:put(52, 40, NAC[4], qtok)

A.save(c, NAME)
