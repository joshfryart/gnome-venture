-- lavender-border-corner (final, Opus single pass): an L-bend of the raised lavender border (along the top, down the
-- left), 3/4 view. Same plank bed as the straight run: end-grain squares at the outer corners, the arm's wall falls
-- into shadow where it tucks in beside the down-leg, soil AO under the far lip. Needle mounds + whorled violet spikes,
-- painted back to front so near spikes overlap far mounds.
-- quirk: a tiny snail is climbing the plank wall.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_1.lua")
local c = A.new("lavender-border-corner")
A.bed(c, { { 8, 20, 56, 31 }, { 8, 20, 20, 50 } }, 5)
local cl = {
  { 14, 25, { 11, 14, 10 }, { -2, 0, 1 } },
  { 22, 26, { 10, 12, 11 }, { -1, 0, 2 } },
  { 30, 25, { 12, 14, 10 }, { -2, 0, 2 } },
  { 38, 26, { 10, 13, 12 }, { -2, 1, 2 } },
  { 46, 25, { 11, 12, 9 }, { -2, 0, 2 } },
  { 14, 33, { 10, 12, 9 }, { -2, 0, 2 } },
  { 14, 40, { 9, 12, 10 }, { -2, 0, 2 } },
  { 14, 46, { 10, 11, 9 }, { -2, 0, 2 } },
}
table.sort(cl, function(a, b) return a[2] < b[2] end)
for _, q in ipairs(cl) do A.clump(c, q[1], q[2], { hs = q[3], leans = q[4], rx = (q[1] == 46) and 3.5 or 4 }) end
A.snail(c, 40, 31)
A.save2(c, "lavender-border-corner")
