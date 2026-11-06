-- paper-comb (final, Opus). A paper-wasp comb hanging from a twig by its slim paper stalk, seen from below at a slight
-- tilt: an umbrella of hexagonal cells. Cell walls are chewed-wood paper in two banded ramps (grey and tan, laid down
-- in concentric strips), lit as one domed disc; each open cell is a dark hole with its inner wall shadowed upper-left
-- and lit lower-right; some cells are capped with cream silk domes (spec glint). The comb's thick back rim shows on the
-- lower right with layered paper bands and an AO row under the face. Twig: wood grain, pale cut end, contact shadow.
-- quirk: a sleepy wasp grub is peeking out of one cell.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "paper-comb"
local c = A.new(NAME)

local GREY = { "#3b3549", "#5a536a", "#827a8e", "#aaa2ae", "#cfc6c6", "#ece4da" }
local TAN  = { "#4a3530", "#6e5242", "#97765a", "#bb9c78", "#dac09a", "#f1dfbc" }
local HOLE = { "#2e2232", "#433445", "#5d4b58" }
local SILK = { "#b7aaa0", "#dcd2c2", "#f4ead2", "#fff4d6" }
local WOOD = { "#51302b", "#6f4430", "#8f5c3a", "#b97a4a", "#d69e66", "#e8c08c" }
local tok, wtok, ktok = { r = { name = "comb" } }, { r = { name = "twig" } }, { r = { name = "stalk" } }

-- twig across the top (slightly tilted), cut end on the left, small bud on the right
local twig = c:line({ { 13, 12 }, { 30, 10 }, { 51, 9 } }, 3)
local _, tn = X.cyl(13, 12, 51, 9, function() return 1.5 end, twig)
local tb = {}
twig:each(function(x, y) if X.hash(x, y, 3) > 0.86 then tb[K(x, y)] = -1 end end)
local tidx = A.shade(c, twig, tn, WOOD, { amb = 0.12, wrap = 0.3, bias = tb, tok = wtok })
for x = 16, 49, 5 do local y = floor(12 - (x - 13) * 3 / 38 + .5) if twig:has(x, y) then c:put(x, y, WOOD[2], wtok) c:put(x + 1, y, WOOD[2], wtok) end end
for _, q in ipairs{ { 12, 11, 6 }, { 12, 12, 5 }, { 12, 13, 5 }, { 13, 12, 4 } } do c:put(q[1], q[2], WOOD[q[3]], wtok) end
for _, q in ipairs{ { 47, 7, 3 }, { 48, 6, 4 }, { 48, 7, 2 } } do c:put(q[1], q[2], WOOD[q[3]], wtok) end

-- stalk (petiole): slim paper stem from the twig down to the comb top
local stalk = c:rect(31, 12, 33, 17)
for y = 12, 17 do c:put(31, y, TAN[5], ktok) c:put(32, y, TAN[4], ktok) c:put(33, y, TAN[2], ktok) end
c:put(30, 12, TAN[3], ktok) c:put(34, 12, TAN[2], ktok)       -- glued foot flares onto the twig
c:put(32, 13, TAN[3], ktok) c:put(32, 15, TAN[3], ktok)        -- spiral ridges
c:put(31, 11, TAN[4], ktok) c:put(33, 11, TAN[3], ktok)

-- back rim (thickness) offset lower-right, banded paper
local CX, CY, RX, RY = 31.5, 34.5, 19, 16
local face = c:ellipse(CX, CY, RX, RY)
-- gently scalloped silhouette: knock out a pixel where cell walls meet the edge
local rim = c:ellipse(CX + 1.5, CY + 2.5, RX, RY):cut(face)
rim:each(function(x, y)
  local a = math.atan(y - CY, x - CX)
  local band = floor((sqrt((x - CX) ^ 2 + (y - CY) ^ 2)) + a * 1.3) % 3
  local inner = face:has(x - 1, y - 1) or face:has(x, y - 1) or face:has(x - 1, y)
  local t = band == 0 and 3 or (band == 1 and 2 or 4)
  if inner then t = max(1, t - 1) end
  c:put(x, y, (band == 2 and TAN or GREY)[t], tok)
end)

-- face: hex cells
local fn = X.pillow(face, 7)
local fv = X.light(fn, { amb = 0.12, wrap = 0.3 })
local PX, PY = 5.0, 4.4
local function cellOf(x, y)
  -- nearest and second-nearest lattice centres (rows offset by half a pitch)
  local best, bi, bj, sec = 1e9, 0, 0, 1e9
  local r0 = floor((y - CY) / PY + 0.5)
  for j = r0 - 1, r0 + 1 do
    local off = (j % 2 == 0) and 0 or PX / 2
    local i0 = floor((x - CX - off) / PX + 0.5)
    for i = i0 - 1, i0 + 1 do
      local cx, cy = CX + off + i * PX, CY + j * PY
      local d = sqrt((x - cx) ^ 2 + ((y - cy) * 1.0) ^ 2)
      if d < best then sec = best best, bi, bj = d, i, j elseif d < sec then sec = d end
    end
  end
  local off = (bj % 2 == 0) and 0 or PX / 2
  return best, sec, bi, bj, CX + off + bi * PX, CY + bj * PY
end
local capped = { ["0,0"] = true, ["1,0"] = true, ["0,-1"] = true, ["-1,1"] = true, ["-1,-1"] = true, ["2,1"] = true, ["-2,0"] = true, ["1,-2"] = true }
local GRUB = "1,1"
local caps = {}
face:each(function(x, y)
  local k = K(x, y)
  local d, s, i, j, cx, cy = cellOf(x, y)
  local v = fv[k] or 0.5
  local ti = 1
  for q, t in ipairs{ 0.16, 0.32, 0.48, 0.64, 0.8 } do if v >= t then ti = q + 1 end end
  local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  local strip = floor(r / 2.6 + X.hash(i, j, 5) * 1.2) % 3
  local ramp = (strip == 1) and TAN or GREY
  local key = i .. "," .. j
  local edgeCell = not face:has(floor(cx + .5), floor(cy + .5)) or ((cx - CX) / (RX - 2)) ^ 2 + ((cy - CY) / (RY - 2)) ^ 2 > 1
  if s - d < 1.0 or edgeCell then
    -- wall (or outer half-cells, which read as solid paper skirt)
    local t = ti
    if edgeCell and (x + y) % 4 == 0 then t = max(1, t - 1) end
    c:put(x, y, ramp[t], tok)
  elseif capped[key] then
    caps[#caps + 1] = { x, y, x - cx, y - cy }
    local ox, oy = x - cx, y - cy
    local dl = -(ox + oy)
    c:put(x, y, SILK[dl > 1 and 4 or (dl > -1 and 3 or 2)], tok)
  else
    -- open cell: shadowed upper-left inner wall, lit lower-right inner wall, dark depth in the middle
    local ox, oy = x - cx, y - cy
    local dl = ox + oy
    local hv = (dl < -1.4) and 1 or ((dl > 1.4) and 3 or 2)
    if key == GRUB then hv = 0 end
    if hv > 0 then c:put(x, y, HOLE[hv], tok) end
  end
end)
-- grub: cream head peeking from its cell with a sleepy eye + mouth
do
  local d, s, i, j, cx, cy = 0, 0, 1, 1, CX + PX / 2 + 1 * PX, CY + 1 * PY
  local gx, gy = floor(cx + .5), floor(cy + .5)
  local map = {
    ".hhh.",
    "hHhhb",
    "hKhhb",
    ".hmb.",
  }
  A.map(c, map, gx - 2, gy - 2, { h = SILK[3], H = SILK[4], b = SILK[1], K = "#2b1c26", m = "#c98a7a" }, tok)
end
-- AO row where the face meets the stalk, and a glint on one cap
for x = 30, 34 do if face:has(x, 19) then c:put(x, 19, GREY[2], tok) end end
c:put(30, 30, SILK[4], tok) c:put(25, 31, "#ffffee", tok)

A.save(c, NAME)
