-- brick-path (final, Opus aB10_3). A short run of garden brick path in 2:1 axonometric: running-bond courses laid
-- across the path, each brick a slightly different fired-clay tone with a lit upper-left arris, a dark lower-right
-- arris and a few kiln speckles; sandy mortar joints; both front edges show the brick ends 3 px deep with joints,
-- a lit left face, a shaded right face and a dark bedding row (AO against the ground). Moss creeps along two joints.
-- quirk: a tiny daisy has pushed up through a crack in the mortar.
local NAME = "brick-path"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local BR = { "#45192a", "#72262c", "#9e3c30", "#c2563a", "#de7a4a", "#f2a86e" }
local MOR = { "#5a5060", "#857a84", "#ada3a2", "#cfc6bc" }
local MOSS = { "#2b5e3e", "#4f8f46", "#86bd56" }
local L, W, T = 35, 14, 3
local OX, OY = 8, 40          -- screen position of world (0,0)
local function uv(x, y) local dx, dy = x - OX, y - OY return (dx - 2 * dy) / 2, (dx + 2 * dy) / 2 end

local top, side = HP.mask(), HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local u, v = uv(x, y)
  if u >= 0 and u < L and v >= 0 and v < W then top:set(x, y) end
end end
for d = 1, T do top:shift(0, d):each(function(x, y) if not top:has(x, y) then side:set(x, y) end end) end

-- brick lookup in world coords: course along u (4 deep), bricks 6 wide across, offset 3 on odd courses
local function brick(u, v)
  local i = floor(u / 5)
  local lu = u - 5 * i
  local off = (i % 2) * 3.5
  local j = floor((v + off) / 7)
  local lv = v + off - 7 * j
  return i, j, lu, lv
end
local ttok = { r = { name = "brick" } }
local mtok = { r = { name = "mortar" } }
local mossy = {}
top:each(function(x, y)
  local u, v = uv(x, y)
  local i, j, lu, lv = brick(u, v)
  if lu < 1 or lv < 1 then
    -- mortar joint: sandy, a darker gap row on the far (upper) side of each joint
    local m = (lv < 1 and lu >= 1) and 3 or 2
    -- moss along two joints
    if (i == 4 and lu < 1 and v > 8 and v < 13) or (i == 6 and lv < 1 and lu >= 1 and X.hash(x, y, 2) > 0.3) then
      mossy[K(x, y)] = true c:put(x, y, MOSS[1 + floor(X.hash(x, y, 9) * 2.99)], mtok) return end
    c:put(x, y, MOR[min(4, m)], mtok) return
  end
  local base = 4 + ((X.hash(i, j, 11) > 0.62) and 1 or 0) - ((X.hash(i, j, 13) > 0.72) and 1 or 0)
  local b = base
  if lv < 2 then b = b + 1 end                 -- lit arris (faces upper-left)
  if lv >= 6.5 then b = b - 1 end              -- shade arris (lower-right)
  if lu < 1.5 and lv >= 2 then b = b - 1 end   -- ambient near the joint below (lower-left)
  if X.hash(x, y, 3) > 0.95 then b = b - 1 end -- kiln speckle
  c:put(x, y, BR[max(1, min(6, b))], ttok)
end)
-- one glint: a 2x1 hi on a lit arris near the upper-left of the path
do
  local best
  top:each(function(x, y)
    local u, v = uv(x, y) local _, _, lu, lv = brick(u, v)
    if lv >= 1 and lv < 1.6 and lu > 2 and top:has(x + 1, y) then
      local sc = x + 3 * y if not best or sc < best[3] then best = { x, y, sc } end end end)
  if best then c:put(best[1], best[2], BR[6], ttok) c:put(best[1] + 1, best[2], "#ffd2a0", ttok) end
end

-- front faces: brick ends with vertical joints, lit left face, shaded right face, dark bedding row
local stok = { r = { name = "brickside" } }
side:each(function(x, y)
  local d
  for q = 1, T do if top:has(x, y - q) then d = q break end end
  local u, v = uv(x, y - d)
  local i, j, lu, lv = brick(u, v)
  local right = v >= W - 1.01
  local col
  if d == T then col = MOR[1]
  elseif (right and lu < 1) or (not right and lv < 1) then col = MOR[2]
  else col = right and BR[2] or BR[4]
    if d == 1 and not right then col = BR[5] end
    if d == 1 and right then col = BR[3] end
  end
  c:put(x, y, col, stok)
end)

-- quirk: a daisy through a mortar crack (stem, two leaves, five cream petals, gold eye)
local dx, dy = 28, 36
local ftok = { r = { name = "daisy" } }
for _, q in ipairs{ { 0, 0, MOSS[1] }, { 0, -1, MOSS[2] }, { 0, -2, MOSS[2] }, { 1, -3, MOSS[2] }, { 1, -4, MOSS[3] },
  { -1, 0, MOSS[2] }, { -2, 0, MOSS[3] }, { 1, 0, MOSS[2] }, { 2, -1, MOSS[3] } } do
  c:put(dx + q[1], dy + q[2], q[3], ftok) end
local fx, fy = dx + 1, dy - 7
for _, q in ipairs{ { 0, -2, 1 }, { -2, -1, 1 }, { -2, 0, 2 }, { 2, -1, 1 }, { 2, 0, 2 }, { -1, 2, 2 }, { 1, 2, 3 },
  { -1, -2, 1 }, { 1, -2, 2 }, { -2, 1, 2 }, { 2, 1, 3 }, { 0, 2, 3 } } do
  c:put(fx + q[1], fy + q[2], ({ A.CREAM, "#f1e2c4", "#cbb7b6" })[q[3]], ftok) end
for _, q in ipairs{ { -1, -1, "#ffd25a" }, { 0, -1, "#ffd25a" }, { -1, 0, "#f5b82e" }, { 0, 0, "#f5b82e" },
  { 1, -1, "#f5b82e" }, { 1, 0, "#d98322" }, { -1, 1, "#d98322" }, { 0, 1, "#b8691e" }, { 1, 1, "#b8691e" } } do
  c:put(fx + q[1], fy + q[2], q[3], ftok) end
c:put(fx - 1, fy - 1, "#fff0a8", ftok)
for _, q in ipairs{ { 1, -4 }, { 1, -5 } } do c:put(dx + q[1], dy + q[2], MOSS[2], ftok) end
-- contact shadow of the daisy on the brick right below its stem
c:put(dx + 1, dy + 1, BR[2], ttok) c:put(dx + 2, dy + 1, BR[3], ttok)

A.save(c, NAME)
