-- oats (final, C3 Opus single pass). One slim straw-green oat stem with two jointed nodes, nodding at the top,
-- carrying a loose open panicle: fine drooping threads, each ending in a pendant papery spikelet (two glumes with a
-- pale lit edge and a darker seam, one bent awn on a few). Two long grass blades with midribs from the lower nodes.
-- Per-pixel tube/oval lighting, AO where threads meet the spikelets and where leaves sheath the stem.
-- quirk: a tiny ladybird climbing the right-hand leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "oats"
local c = A.new(NAME)
local STALK = { "#4c5426", "#6c7a32", "#93a044", "#b8c060", "#d8da88", "#f2f0b8" }
local HUSK = { "#7a5624", "#a67c2e", "#cc9e42", "#e6c060", "#f4da8c", "#fff0c4" }
local LEAF = { "#173f36", "#24584a", "#3f8150", "#5fa456", "#8cc464", "#c4e07a" }
local THREAD = "#b0a04a"

-- leaves first (behind the stem)
local ltok = { r = { name = "leaf" } }
local l1 = A.leaf(c, 30, 50, 19, 41, 9, 47, 2.4, LEAF, { tok = ltok, vs = 99, fold = 0.5, pw = 0.6 })
local l2 = A.leaf(c, 31, 42, 43, 33, 53, 39, 2.2, LEAF, { tok = ltok, vs = 99, fold = 0.5, pw = 0.6, cut = l1 })

-- stem
local stok = { r = { name = "stem" } }
local sp = { { 30, 58 }, { 30, 44 }, { 31, 24 }, { 37, 11 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.15 - 0.35 * t end)
local sb = {}
A.shade(c, sm, sn, STALK, { tok = stok, bias = sb, amb = 0.12, wrap = 0.3 })
-- leaf sheaths: AO on the stem just above where each leaf leaves it, and dark nodes
for _, nd in ipairs{ { 0.17, 0 }, { 0.33, 0 } } do
  local x, y = A.bez(sp, nd[1])
  local xi, yi = floor(x + .5), floor(y + .5)
  for dx = -1, 1 do c:put(xi + dx, yi, STALK[dx < 0 and 3 or 2], stok) end
  c:put(xi - 1, yi - 1, STALK[5], stok)
end
-- leaf collars where blades join the stem (ambient shade)
for _, p in ipairs{ { 29, 49 }, { 29, 50 }, { 32, 41 }, { 32, 42 } } do c:put(p[1], p[2], LEAF[1], ltok) end

-- panicle: threads from whorls on the upper stem, each drooping to a pendant spikelet
local branches = {
  -- t on stem, end x, end y, spikelet tilt, awn
  { 1.0, 45, 13, 0.25, true },
  { 0.97, 27, 12, -0.25, false },
  { 0.84, 48, 22, 0.3, false },
  { 0.84, 22, 21, -0.3, true },
  { 0.7, 44, 30, 0.2, false },
  { 0.7, 21, 30, -0.2, false },
  { 0.9, 39, 21, 0.1, false },
}
local ttok = { r = { name = "thread" } }
local spikes = {}
for _, b in ipairs(branches) do
  local sx, sy = A.bez(sp, b[1])
  local ex, ey = b[2], b[3]
  local cxp, cyp = (sx + ex) / 2, min(sy, ey) - 5
  local lastx, lasty
  for i = 0, 40 do
    local t = i / 40 local u = 1 - t
    local x = u * u * sx + 2 * u * t * cxp + t * t * ex
    local y = u * u * sy + 2 * u * t * cyp + t * t * ey
    local xi, yi = floor(x + .5), floor(y + .5)
    if not sm:has(xi, yi) then c:put(xi, yi, THREAD, ttok) end
  end
  spikes[#spikes + 1] = { ex + 3.2 * sin(b[4]), ey + 3.6 * cos(b[4]), b[4], b[5] }
end
-- spikelets (pendant ovals: long axis roughly vertical)
for i, s in ipairs(spikes) do
  local ang = pi / 2 - s[3]
  local m, n = A.oval(s[1], s[2], 3.4, 1.7, ang, 0.8)
  local tok = { r = { name = "spike" .. i } }
  local idx = A.shade(c, m, n, HUSK, { tok = tok, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
  local ca, sa = cos(ang), sin(ang)
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / 3.85, (-dx * sa + dy * ca) / 2.15
    -- glume seam down the middle, papery lit edge on the left glume
    if abs(v) < 0.22 and u > -0.55 and u < 0.7 then c:put(x, y, HUSK[max(1, idx[k] - 2)], tok)
    elseif u < -0.7 then c:put(x, y, HUSK[max(1, idx[k] - 1)], tok) end   -- AO at the thread joint (top)
  end)
  -- awn: a bent bristle out of the lower tip
  if s[4] then
    local bx, by = floor(s[1] + ca * 4.2 + .5), floor(s[2] + sa * 4.2 + .5)
    local dir = s[3] > 0 and 1 or -1
    c:put(bx, by, HUSK[3], tok) c:put(bx + dir, by + 1, HUSK[3], tok) c:put(bx + dir, by + 2, HUSK[2], tok)
  end
end
-- one specular glint on the top spikelet
do local s = spikes[1] c:put(floor(s[1] - 1 + .5), floor(s[2] - 2 + .5), "#fff4d6", { r = { name = "spike1" } }) end

-- quirk: ladybird on the right leaf
local lb = { r = { name = "ladybird" } }
local bx, by = 45, 34
local rows = { ".kk.", "rRrk", "rkrr", ".rr." }
local map = { k = "#2b1c26", r = "#d83a34", R = "#ff8a5c" }
for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
  if map[ch] then c:put(bx + i - 1, by + j - 1, map[ch], lb) end end end
c:put(bx + 1, by + 4, LEAF[1], ltok) c:put(bx + 2, by + 4, LEAF[1], ltok)   -- contact shadow

A.save(c, NAME)
