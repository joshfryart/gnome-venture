-- lavender-border-gate (final, Opus single pass). A low wooden garden gate in the lavender border: two square posts
-- with pyramid caps, four slim palings with an arched top, two rails and a diagonal brace, flanked by short
-- stone-kerbed stubs of lavender hedge and a flagstone sill underneath.
-- Material: wood grain streaks, pale end grain, lit left arris, AO under the rails, iron strap hinges and ring latch
-- with a specular; bevelled kerb, needle-leaf mounds, whorled spikes.
-- quirk: a sprig of lavender has been tucked through the top rail.
local NAME = "lavender-border-gate"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new(NAME)
local W, ST, P = A.WOOD, A.STONE, A.P
local bed = A.bed(c, c:rect(9, 40, 16, 44):add(c:rect(47, 40, 54, 44)), { fh = 4, seed = 17, bw = 6 })
local bushes = {
  { 13, 44, 5, 6, { { -3, -3, 14, 6 }, { 0, 0, 18, 8 }, { 2, 3, 13, 6 } }, 31 },
  { 51, 44, 5, 6, { { -2, -3, 13, 6 }, { 0, 0, 17, 8 }, { 3, 3, 14, 6 } }, 32 },
}
for _, b in ipairs(bushes) do local m = A.bush(c, b[1], b[2], b[3], b[4], b[5], b[6]) A.contact(c, bed, m) end
A.refront(c, bed)

-- sill
local sill = c:rect(23, 49, 40, 50)
sill:each(function(x, y) local i = (y == 49) and 5 or 2 if x == 23 then i = 6 end if x == 40 then i = 1 end if x == 31 then i = 1 end c:put(x, y, ST[i], { r = { name = "sill" } }) end)

-- palings (behind rails)
local gtok = { r = { name = "gate" } }
local GA = HP.mask()
for i, x0 in ipairs({ 24, 28, 32, 36 }) do
  local mid = x0 + 1.5
  local topY = 27 + floor(((mid - 32) / 8) ^ 2 * 4 + 0.5)
  local m = c:rect(x0, topY, x0 + 2, 48)
  m:cut(c:rect(x0, topY, x0, topY)):cut(c:rect(x0 + 2, topY, x0 + 2, topY))   -- pointed top
  m:each(function(x, y)
    local col = x - x0
    local j = (col == 0) and 5 or (col == 1 and 4 or 2)
    if y == topY then j = 6 end
    if y == topY + 1 and col == 0 then j = 6 end
    if col == 1 and A.h(x, y // 3, i) < 0.3 then j = 3 end                            -- grain streak
    if y >= 46 then j = max(1, j - 1) end
    c:put(x, y, W[j], gtok)
  end)
  GA:add(m)
end
-- rails + brace (in front of palings), AO row under each rail
local rtok = { r = { name = "rail" } }
local function rail(y)
  for x = 24, 39 do
    c:put(x, y, (x == 24) and W[6] or W[5], rtok) c:put(x, y + 1, W[3], rtok)
    if A.h(x, y, 9) < 0.2 then c:put(x, y + 1, W[2], rtok) end
    if GA:has(x, y + 2) then c:put(x, y + 2, W[1], gtok) end
  end
end
rail(32) rail(43)
for t = 0, 12 do
  local x, y = 26 + t, floor(42 - t * 8 / 12 + 0.5)
  c:put(x, y, W[4], rtok) c:put(x, y - 1, W[5], rtok)
  if GA:has(x, y + 1) and y + 1 < 43 then c:put(x, y + 1, W[1], gtok) end
end
-- iron strap hinges and ring latch
for _, y in ipairs({ 32, 43 }) do for x = 24, 26 do c:put(x, y, ST[2], rtok) c:put(x, y + 1, ST[1], rtok) end c:put(25, y, ST[4], rtok) end
c:put(37, 37, ST[3]) c:put(38, 36, ST[5]) c:put(39, 37, ST[2]) c:put(38, 38, ST[1]) c:put(38, 37, A.SOIL[1])

-- posts with pyramid caps
local function post(x0)
  local ptk = { r = { name = "post" .. x0 } }
  local m = c:rect(x0, 23, x0 + 3, 50)
  m:each(function(x, y)
    local col = x - x0
    local j = ({ 5, 4, 3, 2 })[col + 1]
    if A.h(x, y // 4, x0) < 0.25 and col > 0 and col < 3 then j = j - 1 end
    if y >= 48 then j = max(1, j - 1) end
    c:put(x, y, W[j], ptk)
  end)
  -- cap: collar + pyramid
  for x = x0 - 1, x0 + 4 do c:put(x, 22, (x <= x0 + 1) and W[5] or W[3], ptk) c:put(x, 23, W[1], ptk) end
  for x = x0, x0 + 3 do c:put(x, 21, (x <= x0 + 1) and W[6] or W[3], ptk) end
  c:put(x0 + 1, 20, W[6], ptk) c:put(x0 + 2, 20, W[3], ptk)
  c:put(x0 - 1, 22, W[6], ptk)
end
post(20) post(40)

-- quirk: a lavender sprig tucked through the top rail, leaning out to the right
local stok = { r = { name = "sprig" } }
A.spike(c, 30, 36, 35, 26, 6, stok, HP.mask():add(c:rect(24, 32, 39, 33)))
A.save(c, NAME)
