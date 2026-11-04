-- lavender-border-cross (final, Opus single pass): a four-way crossing of the raised lavender border, 3/4 view.
-- Plus-shaped plank bed (walls only on the near faces, shadowed where the cross-arm meets the down-leg), soil with AO,
-- six needle mounds + whorled violet spikes painted back to front, and at the hub a little wooden marker stake
-- (grain, bevel, nail) whose board carries a painted lavender sprig.
-- quirk: the marker board hangs a pixel crooked, hammered in at a tilt.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_1.lua")
local c = A.new("lavender-border-cross")
A.bed(c, { { 7, 28, 56, 38 }, { 25, 16, 37, 50 } }, 4)
local W, P, S = A.WOOD, A.PUR, A.STEM
local cl = {
  { 31, 19, { 8, 10, 8 }, { -1, 0, 1 } },
  { 12, 33, { 10, 12, 9 }, { -2, 0, 2 } },
  { 20, 33, { 11, 13, 10 }, { -2, 0, 1 } },
  { 43, 33, { 10, 13, 11 }, { -1, 0, 2 } },
  { 51, 33, { 9, 11, 10 }, { -2, 0, 2 } },
  { 31, 45, { 9, 11, 9 }, { -2, 0, 2 } },
}
local function stake()
  local oy = 4
  -- post
  for y = 27, 38 do c:put(30, y, W[5]) c:put(31, y, W[4]) c:put(32, y, W[2]) end
  c:put(31, 38, W[1]) c:put(30, 38, W[3])
  -- board, crooked: the right half sits 1px lower
  for y = 0, 6 do for x = 0, 10 do
    local xx, yy = 26 + x, 20 + oy + y + ((x >= 6) and 1 or 0)
    local t = 5
    if y == 0 then t = 6 elseif y == 6 then t = 3 elseif x == 10 then t = 3 elseif x == 0 then t = 6 end
    if t == 5 and (y == 2 or y == 4) and (x + y) % 4 ~= 0 then t = 4 end
    c:put(xx, yy, W[t])
  end end
  -- painted sprig on the board
  local function q(x, y, h) c:put(x, y + oy, h) end
  q(29, 25, S[2]) q(30, 24, S[2]) q(31, 23, P[3]) q(32, 22, P[4]) q(31, 22, P[5]) q(32, 23, P[2])
  q(33, 24, P[3]) q(34, 24, P[4])
  -- nail
  q(35, 22, "#d8d4e0") q(35, 23, "#74758c")
end
local done = false
table.sort(cl, function(a, b) return a[2] < b[2] end)
for _, q in ipairs(cl) do
  if q[2] > 33 and not done then stake() done = true end
  A.clump(c, q[1], q[2], { hs = q[3], leans = q[4] })
  if q[2] == 20 then end
end
A.save2(c, "lavender-border-cross")
