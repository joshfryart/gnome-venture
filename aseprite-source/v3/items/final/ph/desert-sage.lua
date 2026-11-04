-- desert-sage (final, Opus single pass). A slim cut sprig of desert sage: a woody tan stem (bark grain, pale cut end
-- grain, darker nodes) carrying three pairs of narrow spatulate silver-green leaves angled upward (V-fold light,
-- pale felted speckle, midrib, AO where each leaf meets the stem), topped by a spike of three whorls of tiny violet
-- two-lipped flowers sitting in rose-pink bracts, getting smaller toward the tip.
-- quirk: one round dew bead clings to the lowest right leaf, catching the light.
local NAME = "desert-sage"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, cos, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.cos, math.sin, math.pi
local c = A.new(NAME)
local SAGE = { "#263c3a", "#40605a", "#638a7c", "#8eb29e", "#bcd3bc", "#e4eed8" }
local VIO = { "#35295f", "#5a459e", "#8a6fd0", "#b39ae8", "#dccdf8" }
local BR = { "#7d2c5e", "#b24c7c", "#d97aa0" }
local WOOD = { "#3f2524", "#5e3a2c", "#864c33", "#a86a42", "#c99263", "#e8c08f" }
local DEW = { "#3a86b0", "#8fd2dc", "#e4f6ff" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- stem
local sp = { { 31, 55 }, { 30, 44 }, { 33, 30 }, { 32, 9 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.35 - t * 0.6 end)
local wtok = { r = { name = "stem" } }
local widx = X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), WOOD, { cuts = CUTS, tok = wtok })
-- bark grain: broken vertical dark streaks on the lower woody part
sm:each(function(x, y) local k = K(x, y)
  if ST[k] < 0.5 and abs(SS[k]) < 0.3 and X.hash(x, y, 7) > 0.55 then c:put(x, y, WOOD[max(1, widx[k] - 1)], wtok) end end)

-- leaf pairs: node t, side, length, angle up
local leaves = {}
local function leaf(t, side, L, rise)
  local nx, ny = A.bez(sp, t)
  local tx, ty = nx + side * L * 0.9, ny - L * rise
  local m, n, T, S = A.blade(nx + side * 0.5, ny, nx + side * L * 0.45, ny - L * rise * 0.25, tx, ty, function(u)
    if u > 0.985 then return -1 end
    return max(0.45, 2.7 * sin(pi * min(1, u * 0.72 + 0.28)) ^ 0.75 * (0.55 + 0.45 * u))
  end, { fold = 0.35 })
  m:cut(sm)
  leaves[#leaves + 1] = { m = m, n = n, T = T, S = S, node = { floor(nx + .5), floor(ny + .5) } }
end
leaf(0.18, -1, 12, 0.55) leaf(0.2, 1, 12, 0.5)
leaf(0.38, -1, 10, 0.6) leaf(0.4, 1, 10, 0.55)
leaf(0.56, -1, 8, 0.7) leaf(0.58, 1, 8, 0.65)
local ltok = { r = { name = "leaf" } }
for i, L in ipairs(leaves) do
  local bias = {}
  X.ao(bias, L.m, sm, 1, -1)
  local idx = A.toneN(c, L.m, L.n, SAGE, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3, bias = bias })
  L.m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    if abs(L.S[k]) < 0.14 and L.T[k] > 0.08 and L.T[k] < 0.82 then c:put(x, y, L.S[k] <= 0 and SAGE[5] or SAGE[3], ltok) return end
    -- felted silver speckle
    if X.hash(x, y, i) > 0.82 and idx[k] >= 3 then c:put(x, y, SAGE[min(6, idx[k] + 1)], ltok) end
  end)
end
-- darker nodes where leaves leave the stem (ambient)
for _, L in ipairs(leaves) do c:put(L.node[1], L.node[2], WOOD[2], wtok) end
-- cut end: pale end grain ring at the base
c:put(30, 55, WOOD[6], wtok) c:put(31, 55, WOOD[5], wtok)

-- flower spike: whorls (bracts behind, violet florets in front), tapering upward
local ftok = { r = { name = "flower" } }
local function whorl(cy, w, n)
  local cx = floor(A.bez(sp, (cy - 9) / 48 * 0 + 0.02) + 0.5)
  cx = 32
  -- bracts: short pink cup
  for x = cx - w, cx + w do
    local d = abs(x - cx)
    c:put(x, cy + 1, d == w and BR[1] or (x < cx and BR[3] or BR[2]))
    if d < w then c:put(x, cy + 2, BR[1]) end
  end
  -- florets: little two-lipped blobs fanned on both sides
  for j = 1, n do
    local side = (j % 2 == 1) and -1 or 1
    local off = floor((j + 1) / 2)
    local fx = cx + side * (off * 2 - 1)
    local fy = cy - (off == 1 and 1 or 0)
    local lit = side < 0
    c:put(fx, fy, lit and VIO[4] or VIO[3], ftok)
    c:put(fx + side, fy, lit and VIO[3] or VIO[2], ftok)
    c:put(fx, fy - 1, lit and VIO[5] or VIO[4], ftok)
    c:put(fx + side, fy + 1, VIO[2], ftok)
    c:put(fx, fy + 1, VIO[2], ftok)
  end
  c:put(cx, cy - 1, VIO[3], ftok) c:put(cx, cy, VIO[1], ftok)
end
whorl(25, 5, 4)
whorl(17, 4, 4)
whorl(10, 3, 2)
-- tip bud
c:put(32, 6, VIO[4], ftok) c:put(32, 7, VIO[3], ftok) c:put(33, 7, VIO[2], ftok)
c:put(30, 9, VIO[5], ftok)

-- quirk: dew bead on the lower right leaf
local bx, by = 40, 44
c:put(bx, by, DEW[2]) c:put(bx + 1, by, DEW[1]) c:put(bx, by + 1, DEW[1]) c:put(bx + 1, by + 1, DEW[1])
c:put(bx, by, DEW[3])
c:put(bx, by - 1, DEW[2]) c:put(bx + 1, by - 1, DEW[2])
A.save(c, A.here(), NAME)
