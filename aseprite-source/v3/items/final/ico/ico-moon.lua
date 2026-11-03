-- ico-moon (Opus single pass). Slim crescent, horns up-right and down-right, read as a bevelled sphere slice:
-- per-pixel light (pillow bevel blended with sphere normals) on a 6-tone pale-gold ramp with cool-violet shade,
-- three craters (shadowed upper-left wall, lit lower-right wall, bright lip), maria blotches one tone down,
-- cool reflected light along the inner (concave) edge, one specular on the outer limb + a cream sparkle.
-- quirk: a little gold star dangles on a thread from the top horn, like a mobile over a crib.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-moon")
local MN = { "#64467a", "#b0846c", "#d1a24e", "#efc657", "#ffe08a", "#fff2c0" }
local BOUNCE = "#9aa6dc"

local OX, OY, OR = 30, 32, 22
local CX, CY, CRr = 40.5, 30, 20.5
local outer = c:ellipse(OX, OY, OR, OR)
local cut = c:ellipse(CX, CY, CRr, CRr)
local m = outer:copy():cut(cut)
-- normals: pillow bevel + sphere
local pn = X.pillow(m, 5)
local sn = X.sphere(OX - 1, OY - 1, OR, m)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local a, b = pn[k], sn[k]
  local nx, ny, nz = a[1] + b[1] * 0.7, a[2] + b[2] * 0.7, a[3] + b[3] * 0.7
  local l = sqrt(nx*nx + ny*ny + nz*nz)
  n[k] = { nx / l, ny / l, nz / l }
end)
local bias = {}
-- maria: soft blotches one tone down (hash-free, two ellipses)
for _, e in ipairs{ { 13, 31, 2, 5 } } do
  c:ellipse(e[1], e[2], e[3], e[4]):each(function(x, y) if m:has(x, y) then bias[K(x, y)] = -1 end end)
end
-- craters
local craters = { { 17, 22, 2 }, { 15, 40, 3 }, { 28, 49, 2 } }
for _, q in ipairs(craters) do
  local cx, cy, r = q[1], q[2], q[3]
  local cm = c:ellipse(cx, cy, r, r * 0.85)
  cm:each(function(x, y) if m:has(x, y) then
    local d = (x - cx) + (y - cy)
    bias[K(x, y)] = (d < -0.5) and -2 or ((d > 1) and 1 or -1)
  end end)
  -- lip just outside: lit on lower-right, shaded upper-left
  cm:grow(1):cut(cm):each(function(x, y) if m:has(x, y) then
    local d = (x - cx) + (y - cy)
    if d > 0 then bias[K(x, y)] = (bias[K(x, y)] or 0) + 1 end
  end end)
end
local tok = { r = { name = "moon" } }
local idx = A.litN(m, n, MN, { amb = 0.04, wrap = 0.2, bias = bias, tok = tok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 } })
-- cool reflected light along the concave inner edge (pixels touching the cut disc, lower half)
m:each(function(x, y)
  local touches = cut:has(x + 1, y) or cut:has(x, y + 1) or cut:has(x + 1, y + 1)
  if touches and y > 37 and y < 46 then c:put(x, y, BOUNCE, tok) end
end)
-- specular on the upper-left outer limb + sparkle
c:put(15, 18, MN[6], tok) c:put(16, 17, MN[6], tok) c:put(14, 19, A.CR, tok) c:put(14, 20, MN[6], tok)
-- quirk: star on a thread from the top horn
local tip
m:each(function(x, y) if (not tip or y < tip[2] or (y == tip[2] and x > tip[1])) then tip = { x, y } end end)
local tx = tip[1]
local THR = "#b8743a"
for y = tip[2] + 1, tip[2] + 14 do c:px(tx, y, THR) end
local sx, sy = tx, tip[2] + 18
local star = {
  "...s...",
  "..sSs..",
  "sssShss",
  ".sSHSd.",
  "..sSd..",
  ".sd.dd.",
  "sd...dd",
}
A.bmp(star, sx - 3, sy - 3, { s = "#f5b82e", S = "#ffd85c", h = "#fff2c0", H = "#ffe8a0", d = "#c9772a" })
A.done()
