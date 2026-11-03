-- ico-ghost (final, Opus): a friendly bedsheet ghost, tall dome head, the sheet falling in soft folds to a
-- scalloped hem that sways a little to the right; one sheet-arm waving up, the other out and down.
-- Material (cloth): per-pixel round light on a 6-tone lavender-cream ramp, fold grooves rising from each hem cusp
-- with a lit lip, the dark inside of the sheet showing between the scallops, AO under the arms, cool bounce on the
-- shade side. Face: 3x4 ink eye pills with cream glints, a small "o" mouth, a button nose, petal cheeks.
-- quirk: a little blue darned patch, sewn on with gold stitches, on the sheet's lower right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor, sin, pi = math.sqrt, math.max, math.min, math.abs, math.floor, math.sin, math.pi
local c = A.new("ico-ghost")
local GH = { "#463b6e", "#7268a0", "#9d94c6", "#c3bde0", "#e2def2", "#f6f3fb" }
local INSIDE = { "#2f2650", "#3e3466" }
local BOUNCE = "#9fb4dc"
local gt = { r = { name = "sheet" } }

local X0, X1 = 17, 47
local function lx(y) return 19.5 - (y - 22) * 0.1 end
local function rx(y) return 42.5 + (y - 22) * 0.16 end
local NB = 3
local function hemY(x, ph)
  local u = (x - X0 + 0.5) / ((X1 - X0 + 1) / NB) + (ph or 0)
  local f = u - floor(u)
  return 46 + 5 * sin(pi * f) ^ 0.6
end

-- the inside of the sheet (back hem), seen between the front scallops
local back = HP.mask()
for x = X0 + 2, X1 - 2 do for y = 44, floor(hemY(x, 0.5) + 0.5) - 3 do back:set(x, y) end end
back:each(function(x, y) c:put(x, y, (y > 47) and INSIDE[1] or INSIDE[2], gt) end)

-- sheet mass
local mass = HP.ellipse(31, 22, 11.5, 12):cut(HP.rect(0, 23, 63, 63))
for y = 22, 52 do
  local a, b = lx(y), rx(y)
  for x = floor(a + 0.5), floor(b + 0.5) do if y <= hemY(x) then mass:set(x, y) end end
end
mass:clip(HP.rect(0, 0, 63, 63))
local nb = A.body(mass, 30, 28, 16, 6, 0.5, 22)
local idx = A.shade(c, mass, nb, GH, { tok = gt, amb = 0.22, wrap = 0.35 })
-- folds: grooves rising from each hem cusp, curving with the sway, lit lip on the left
for i = 1, NB - 1 do
  local cx = X0 - 0.5 + i * (X1 - X0 + 1) / NB
  local top = 35
  for y = top, 48 do
    local x = floor(cx - (48 - y) * 0.1 * (i - 1.5) + 0.5)
    if mass:has(x, y) then A.step(c, idx, GH, x, y, (y > top + 2) and -2 or -1, gt) end
    if mass:has(x - 1, y) and y > top + 2 then A.step(c, idx, GH, x - 1, y, 1, gt) end
  end
end
-- each scallop: shade underside row (the sheet turns under)
mass:each(function(x, y) if y > 44 and not mass:has(x, y + 1) then A.step(c, idx, GH, x, y, -1, gt) end end)

-- arms on top (cloth tubes), ambient row where they meet the body
local aidx = {}
do
  local mL, nL, TL = A.tube({ { 21, 33 }, { 17, 31 }, { 14, 28 }, { 12, 24 } }, function(t) return 2.4 - t * 0.5 end)
  local mR, nR, TR = A.tube({ { 42, 33 }, { 46, 35 }, { 48, 37 }, { 50, 39 } }, function(t) return 2.4 - t * 0.5 end)
  for _, q in ipairs{ { mL, nL }, { mR, nR } } do
    q[1]:cut(mass:copy():shrink(1))
    local id = A.shade(c, q[1], q[2], GH, { tok = gt, amb = 0.14, wrap = 0.32 })
    for k, v in pairs(id) do aidx[k] = v end
    A.sep(c, mass, idx, GH, q[1], -1, gt)
  end
  -- separate arm from body where they share the same tones: deep line on the arm's body-side edge
  for _, q in ipairs{ { mL }, { mR } } do
    q[1]:each(function(x, y) if mass:has(x, y + 1) and not q[1]:has(x, y + 1) then A.step(c, aidx, GH, x, y, -1, gt) end end)
  end
  mass:add(mL):add(mR)
end

-- cool bounce light on the lower-right silhouette
local rim = X.rim(nb)
mass:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.6 and y > 20 and y < 44 and x > 36 then c:put(x, y, BOUNCE, gt) end end)

-- face
local INK = A.INK
for _, ex in ipairs{ 24, 34 } do
  for yy = 17, 21 do for xx = ex, ex + 3 do
    if not ((yy == 17 or yy == 21) and (xx == ex or xx == ex + 3)) then c:put(xx, yy, INK, gt) end end end
  c:put(ex + 1, 18, A.CREAM, gt)
  c:put(ex + 1, 22, GH[3], gt) c:put(ex + 2, 22, GH[3], gt)
end
-- button nose: a small soft bump
c:put(30, 23, GH[3], gt) c:put(31, 23, GH[3], gt) c:put(30, 22, GH[6], gt) c:put(31, 24, GH[2], gt) c:put(30, 24, GH[2], gt)
-- "o" mouth
A.map(c, { ".kk.", "kddk", "kpdk", ".kk." }, 29, 26, { k = INK, d = "#5a2640", p = "#c94f84" }, gt)
c:cheek(21, 23) c:cheek(39, 23)
-- soft sheen on the dome + glint
c:put(24, 13, GH[6], gt) c:put(25, 13, GH[6], gt) c:put(23, 14, GH[6], gt)

-- quirk: a blue darned patch with gold stitches (lower right)
local px0, py0 = 36, 37
local PB = { "#3a6aa8", "#5a8fca", "#86b6e2" }
for y = py0, py0 + 5 do for x = px0, px0 + 5 do
  local d = (x - px0 + y - py0) % 3
  c:put(x, y, d == 0 and PB[1] or (x - px0 + (y - py0)) < 4 and PB[3] or PB[2], gt)
end end
c:stitch{ { px0, py0 }, { px0 + 5, py0 }, { px0 + 5, py0 + 5 }, { px0, py0 + 5 }, { px0, py0 + 1 } }
for x = px0, px0 + 6 do A.step(c, idx, GH, x, py0 + 6, -1, gt) end
for y = py0, py0 + 6 do A.step(c, idx, GH, px0 + 6, y, -1, gt) end
A.save(c, "ico-ghost")
