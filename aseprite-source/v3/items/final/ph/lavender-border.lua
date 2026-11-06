-- lavender-border (final, Opus single pass): a straight run of raised lavender border in 3/4 view.
-- Plank-edged bed (6-tone wood: lit top lip, plank rows with grain dashes, joints with nail heads, shaded right end,
-- dark ground row), dark soil with AO under the far lip, five grey-green needle mounds (pillow light + needle strokes)
-- each sending up slim 1px stems topped by whorled violet spikes (6-tone, interrupted whorls, darker low whorl).
-- quirk: a bumblebee hovers over the tallest spike.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_1.lua")
local c = A.new("lavender-border")
c:groundShadow(32, 50, 24, 2)
A.bed(c, { { 9, 34, 54, 43 } }, 6)
local cl = {
  { 15, 39, { 10, 13, 11 }, { -2, 0, 2 } },
  { 23, 40, { 12, 15, 10 }, { -1, 0, 2 } },
  { 31, 39, { 11, 16, 13 }, { -2, 0, 1 } },
  { 39, 40, { 13, 14, 10 }, { -2, 1, 2 } },
  { 47, 39, { 10, 12, 11 }, { -2, 0, 2 } },
}
for _, q in ipairs(cl) do A.clump(c, q[1], q[2], { hs = q[3], leans = q[4] }) end
A.bee(c, 36, 20)
A.save2(c, "lavender-border")
