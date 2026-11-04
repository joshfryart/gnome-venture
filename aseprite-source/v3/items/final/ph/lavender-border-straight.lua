-- lavender-border-straight (final, Opus single pass). A straight run of lavender hedge in a low stone-kerbed bed,
-- 3/4 view: four grey-green needle-leaf mounds tucked behind the front kerb, slim violet spikes fanning up.
-- Material: bevelled kerb blocks with mortar joints and one specular, crumbly soil, contact shadow under the mounds.
-- quirk: a bee has settled on the tallest spike.
local NAME = "lavender-border-straight"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_2.lua")
local c = A.new(NAME)
local bed = A.bed(c, c:rect(9, 38, 54, 42), { fh = 4, seed = 3 })
local bushes = {
  { 15, 42, 6, 6, { { -3, -4, 15, 7 }, { 0, -1, 19, 8 }, { 3, 3, 14, 6 } }, 1 },
  { 27, 42, 6, 7, { { -3, -2, 17, 7 }, { 0, 1, 21, 8 }, { 3, 4, 15, 6 } }, 2 },
  { 39, 42, 6, 6, { { -3, -3, 14, 6 }, { 0, 0, 18, 8 }, { 3, 3, 16, 7 } }, 3 },
  { 50, 42, 5, 6, { { -2, -2, 16, 7 }, { 1, 2, 19, 8 }, { 3, 5, 13, 6 } }, 4 },
}
for _, b in ipairs(bushes) do
  local m = A.bush(c, b[1], b[2], b[3], b[4], b[5], b[6])
  A.contact(c, bed, m)
end
A.refront(c, bed)
-- quirk: bee on the tallest spike (bush 2, centre spike tip at 28,21)
A.bee(c, 29, 24)
A.save(c, NAME)
