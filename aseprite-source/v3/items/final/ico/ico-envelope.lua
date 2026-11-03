-- ico-envelope (final, Opus). A sealed letter seen from the back: slim landscape body with its four folded paper
-- flaps, the top flap closed down over the others and held by a round wax seal at its tip.
-- Material: each flap is its own gently tilted plane (left lit, right in shade, bottom mid) with a rounded 2 px
-- paper bevel on the outer edge, snapped per pixel to a 6-tone warm cream ramp; folds are creases (dark groove +
-- lit lip); the top flap casts a 2 px contact shadow on the flaps under it; sparse paper fibres. Wax: a thick
-- poured disc with three drips, pillow-bevelled, a sunken embossed ring and acorn, one specular streak + glint.
-- quirk: a little four-leaf clover pressed inside the letter pokes out from under the seal.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-envelope")
local PA = { "#5d4553", "#8f7378", "#bfa497", "#dcc4ac", "#efdcc0", "#fbf0d8" }
local WX = { "#4e1028", "#7c1a32", "#a8263a", "#d23c3f", "#f0654c", "#ff9a72" }
local LF = { "#1d4a3a", "#2e7646", "#4f9c50", "#7cc35a", "#b3dc78" }
local CREAM = "#fff4d6"
local X0, X1, Y0, Y1 = 9, 54, 17, 46
local CX = (X0 + X1) / 2
local TIPY, MIDY = 35, 30
local ptok, wtok, ltok = A.tok("paper"), A.tok("wax"), A.tok("clover")

local body = c:rrect(X0, Y0, X1, Y1, 2)
local function flapY(x) return Y0 + (TIPY - Y0) * (1 - abs(x - CX) / ((X1 - X0) / 2 + 0.5)) end
local function botY(x) return Y1 - (Y1 - MIDY) * (1 - abs(x - CX) / ((X1 - X0) / 2 + 0.5)) end
local reg = {}
local top = HP.mask()
body:each(function(x, y)
  local k = K(x, y)
  if y <= flapY(x) + 0.5 then reg[k] = "t" top:set(x, y)
  elseif y >= botY(x) then reg[k] = "b"
  elseif x < CX then reg[k] = "l" else reg[k] = "r" end
end)
local TILT = { t = { -0.12, -0.3 }, l = { -0.5, -0.12 }, r = { 0.55, 0.12 }, b = { 0.08, 0.42 } }
local pn = X.pillow(body, 2.2)
local n = {}
body:each(function(x, y) local k = K(x, y)
  local t, p = TILT[reg[k]], pn[k]
  local nx, ny, nz = t[1] + p[1] * 0.9, t[2] + p[2] * 0.9, 1
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[k] = { nx / l, ny / l, nz / l }
end)
local bias = {}
-- contact shadow under the top flap edge (on the flaps beneath)
body:each(function(x, y) local k = K(x, y)
  if reg[k] ~= "t" then
    local d = y - flapY(x)
    if d < 2.2 then bias[k] = -1 end
    if d < 1.2 then bias[k] = -2 end
  end
end)
local idx = A.shade(c, body, n, PA, { tok = ptok, amb = 0.1, wrap = 0.35, cuts = { 0.2, 0.38, 0.55, 0.7, 0.84 },
  bias = bias, tilt = { CX, 31, 26, 0.06 } })
-- creases: lower fold lines (dark groove + lit lip above)
body:each(function(x, y) local k = K(x, y)
  if reg[k] == "b" and reg[K(x, y - 1)] ~= "b" and reg[K(x, y - 1)] ~= "t" then
    c:put(x, y, PA[2], ptok) idx[k] = 2
    if reg[K(x, y + 1)] == "b" then A.step(c, idx, PA, x, y + 1, 1, ptok) end
  end
end)
-- top flap edge: 1 px line in the paper's darker tone, lit lip just inside
top:each(function(x, y) local k = K(x, y)
  if body:has(x, y + 1) and not top:has(x, y + 1) then
    c:put(x, y, PA[3], ptok) idx[k] = 3
    if top:has(x, y - 1) then A.step(c, idx, PA, x, y - 1, 1, ptok) end
  end
end)
-- fibres: sparse 1 px tone steps
body:each(function(x, y) local h = X.hash(x, y, 11) local k = K(x, y)
  if idx[k] and idx[k] >= 3 then
    if h < 0.016 then A.step(c, idx, PA, x, y, -1, ptok) elseif h > 0.99 then A.step(c, idx, PA, x, y, 1, ptok) end
  end end)
-- top flap specular streak along its upper-left edge
for x = X0 + 3, X0 + 9 do c:put(x, Y0 + 1, PA[6], ptok) end
c:put(X0 + 2, Y0 + 2, PA[6], ptok)

-- quirk: clover pokes out under the seal (lower right), drawn before the wax so the seal sits on it
local SX, SY = CX, TIPY - 0.5
local clov = HP.mask()
local CCX, CCY = SX + 8, SY + 5
local leaves = {}
for i, ang in ipairs{ -0.9, 0.5, 1.95, 3.4 } do
  local lm = A.ell(CCX + math.cos(ang) * 2.6, CCY + math.sin(ang) * 2.6, 2.3, 2.3)
  leaves[i] = lm clov:add(lm)
end
local cn = X.pillow(clov, 1.6)
local cidx = A.shade(c, clov, cn, LF, { tok = ltok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
-- separation where leaves overlap (darker neighbour tone) + a dark centre
for i = 2, #leaves do
  leaves[i]:each(function(x, y) for j = 1, i - 1 do
    if leaves[j]:has(x, y) and not (leaves[j]:has(x + 1, y) and leaves[j]:has(x, y + 1) and leaves[j]:has(x - 1, y) and leaves[j]:has(x, y - 1)) then c:put(x, y, LF[1], ltok) end
  end end)
end
c:put(floor(CCX), floor(CCY), LF[1], ltok)
-- stem curling out to the lower right
for _, p in ipairs{ { 3, 4 }, { 4, 5 }, { 5, 5 } } do c:put(floor(CCX) + p[1], floor(CCY) + p[2], LF[2], ltok) clov:set(floor(CCX) + p[1], floor(CCY) + p[2]) end
-- contact shadow of the clover on the paper
clov:shift(1, 1):each(function(x, y) if body:has(x, y) and not clov:has(x, y) then A.step(c, idx, PA, x, y, -1, ptok) end end)

-- wax seal: disc + three drips
local seal = A.ell(SX, SY, 6.6, 6.2)
seal:add(A.ell(SX - 6.2, SY + 2.5, 1.6, 1.6)):add(A.ell(SX + 2.5, SY + 6.4, 1.7, 1.5)):add(A.ell(SX + 5.8, SY - 3.2, 1.4, 1.4))
local sn = X.pillow(seal, 3.2)
local sb = {}
-- sunken ring: groove (normals tilted inward)
local RR = 4.1
seal:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - SX) ^ 2 + (y - SY) ^ 2)
  if abs(d - RR) < 0.7 then
    local ux, uy = (x - SX) / d, (y - SY) / d
    local nx, ny, nz = -ux * 0.75, -uy * 0.75, 1
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    sn[k] = { nx / l, ny / l, nz / l }
  end
end)
-- contact shadow of the seal on the paper
seal:shift(1, 1):add(seal:shift(2, 1)):each(function(x, y)
  if body:has(x, y) and not seal:has(x, y) and not clov:has(x, y) then A.step(c, idx, PA, x, y, -1, ptok) end end)
local widx = A.shade(c, seal, sn, WX, { tok = wtok, amb = 0.08, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- embossed acorn in the centre (raised: lit upper-left edge, dark lower-right edge)
local acorn = {
  ".ccc.",
  "ccccc",
  ".nnn.",
  ".nnn.",
  "..n..",
}
local ax, ay = floor(SX) - 2, floor(SY) - 3
for yy, row in ipairs(acorn) do for xx = 1, #row do
  if row:sub(xx, xx) ~= "." then
    local x, y = ax + xx - 1, ay + yy - 1
    local up = acorn[yy - 1] and acorn[yy - 1]:sub(xx, xx) or "."
    local lf = row:sub(xx - 1, xx - 1)
    local col = (row:sub(xx, xx) == "c") and WX[2] or WX[3]
    if up == "." or up == "" or lf == "." or lf == "" then col = WX[5] end
    c:put(x, y, col, wtok)
  end end end
c:put(ax + 2, ay - 1, WX[2], wtok) -- stalk
-- specular streak + glint on the wax
c:put(floor(SX) - 4, floor(SY) - 3, WX[6], wtok) c:put(floor(SX) - 3, floor(SY) - 4, WX[6], wtok)
c:put(floor(SX) - 4, floor(SY) - 2, WX[6], wtok)
c:put(floor(SX) - 3, floor(SY) - 5, CREAM, wtok)
A.save(c, "ico-envelope")
