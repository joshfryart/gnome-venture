-- nav-games (final pass, Opus). A slim-edged ivory die in three-quarter view: front face shows five, right face
-- three, top face one. Bevelled rounded edges (pillow normals per face, faces tilted to the light), 6-tone ivory,
-- pips sunk in (dark rim upper-left, lit lip lower-right), a polished specular on the top-front bevel, ambient
-- dark where the faces meet, ground shadow.
-- quirk: the single pip on top is a tiny red gnome hat standing upright.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, sqrt = math.abs, math.max, math.min, math.sqrt
local c = A.new("nav-games")
local IV  = { "#5b3b52", "#8e6a78", "#c2a3a0", "#e2cbb6", "#f3e3c8", "#fff4d6" }
local PIP = { "#4a1630", "#6e2038", "#a3283c", "#d23f3c", "#f06a4a", "#ff9a6a" }
local tok = { r = { name = "die" } }

c:groundShadow(33, 53, 21, 2)
-- geometry: front square + top and right parallelograms (oblique depth 9,-9)
local F0, S, D = { 12, 21 }, 30, { 9, -9 }
local function rounded(r) return function(u, v)
  if u < 0 or u > 1 or v < 0 or v > 1 then return false end
  local cu, cv = max(0, abs(u - 0.5) - (0.5 - r)), max(0, abs(v - 0.5) - (0.5 - r))
  return cu * cu + cv * cv <= r * r end end
local front = A.face(F0, { S, 0 }, { 0, S }, rounded(0.12))
local top   = A.face(F0, { S, 0 }, D, rounded(0.16)):cut(front)
local right = A.face({ F0[1] + S, F0[2] }, D, { 0, S }, rounded(0.16)):cut(front):cut(top)

local idxT = A.shade(c, top, A.slab(top, 2.2, 0, -1.25, 0.8), IV, { tok = tok, amb = 0.1 })
local idxR = A.shade(c, right, A.slab(right, 2.2, 1.2, 0.1, 0.8), IV, { tok = tok, amb = 0.08 })
local bias = {}
X.ao(bias, front, top, 1, 0) -- keep top seam crisp
local idxF = A.shade(c, front, A.slab(front, 3, 0, 0, 1), IV, { tok = tok, amb = 0.1 })
-- ambient seams: darker pixel where faces meet (inside the far faces)
top:each(function(x, y) if front:has(x, y + 1) then A.step(c, idxT, IV, x, y, -1, tok) end end)
right:each(function(x, y) if front:has(x - 1, y) or top:has(x, y - 1) then A.step(c, idxR, IV, x, y, -1, tok) end end)
-- worn bevel highlight: bright edge along front-top rim (left half) + specular
for x = 15, 26 do A.step(c, idxF, IV, x, F0[2] + 1, 1, tok) end
c:put(17, 23, IV[6], tok) c:put(18, 23, IV[6], tok) c:put(16, 24, IV[6], tok)

-- sunk pips: mask, dark upper-left inner rim, lit lower-right lip
local function pip(m)
  local d = {}
  m:each(function(x, y) d[#d + 1] = { x, y } end)
  local cx, cy = 0, 0
  for _, p in ipairs(d) do cx, cy = cx + p[1], cy + p[2] end
  cx, cy = cx / #d, cy / #d
  local rr = sqrt(#d / math.pi)
  m:each(function(x, y)
    local nx, ny = (x - cx) / (rr + 0.5), (y - cy) / (rr + 0.5)
    local q = max(0.05, 1 - nx * nx - ny * ny)
    -- concave: normal points inward
    local nn = { A.norm(-nx, -ny, sqrt(q)) }
    local L = X.L
    local v = max(0, nn[1] * L[1] + nn[2] * L[2] + nn[3] * L[3])
    local i = max(1, min(6, math.floor(v * 5) + 1))
    if not m:has(x - 1, y) or not m:has(x, y - 1) then i = 1 end
    c:put(x, y, PIP[i], { r = { name = "pip" } })
  end)
  -- lit lip on the die just outside the lower-right edge
  m:grow(1):cut(m):each(function(x, y)
    if x >= cx and y >= cy and (front:has(x, y) or right:has(x, y)) then
      local idx = front:has(x, y) and idxF or idxR
      A.step(c, idx, IV, x, y, 1, tok)
    end
  end)
  c:put(math.floor(cx + 0.5), math.floor(cy + 0.5), PIP[6], { r = { name = "pip" } })
end
local function fpip(u, v) return A.face(F0, { S, 0 }, { 0, S }, function(a, b) return (a - u) ^ 2 + (b - v) ^ 2 <= 0.012 end) end
for _, p in ipairs{ { 0.25, 0.25 }, { 0.75, 0.25 }, { 0.5, 0.5 }, { 0.25, 0.75 }, { 0.75, 0.75 } } do pip(fpip(p[1], p[2])) end
local RO = { F0[1] + S, F0[2] }
for _, p in ipairs{ { 0.28, 0.24 }, { 0.5, 0.5 }, { 0.72, 0.76 } } do
  pip(A.face(RO, D, { 0, S }, function(a, b) return ((a - p[1]) * 12) ^ 2 + ((b - p[2]) * 30) ^ 2 <= 7 end))
end

-- quirk: tiny red gnome hat as the top pip (stands up out of the top face)
local hx, hy = 31, 20
local HAT = { K = "#2b1c26", h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038", g = "#f5b82e", G = "#d98322", s = "#5b3b52" }
A.map(c, {
  "....R..",
  "...hR..",
  "...hRr.",
  "..hRRr.",
  "..hRrr.",
  ".gggGG.",
  "..sss..",
}, hx - 3, hy - 9, HAT, { r = { name = "hat" } })

A.save(c, "nav-games")
