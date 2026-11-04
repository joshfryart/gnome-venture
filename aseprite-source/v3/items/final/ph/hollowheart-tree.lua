-- hollowheart-tree (final, Opus single pass). A slim, slightly swaying oak-ish tree: a narrow bark trunk (6-tone,
-- vertical fissures between lit bark plates, flared roots with grooves) carrying a heart-shaped hollow (pale
-- bulging lip upper-left, dark inner wall, lit far wall lower-right), two branches into a clumped crown of eight
-- bumpy leaf masses (per-clump sphere light blended with the whole-crown form, speckled leaf flecks, contact shadow
-- where front clumps overlap back ones, cool reflected edge lower-right, one specular), AO under the crown and a
-- 2-tone ground shadow.
-- quirk: two little gold eyes blink out of the dark heart hollow.
local NAME = "hollowheart-tree"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local BARK = { "#2e1b1f", "#4a2c28", "#6c4130", "#8f5a3a", "#b37a4f", "#d6a370" }
local LEAF = { "#163832", "#1f533e", "#2c7243", "#45934a", "#6bb452", "#a3d56f" }
local COOL, SPEC = "#3e7a78", "#e6f6b4"
local btok, ltok, htok = { r = { name = "bark" } }, { r = { name = "leaf" } }, { r = { name = "hollow" } }

c:groundShadow(32, 56, 14, 1.4)

-- trunk by rows
local Y0, Y1 = 30, 55
local function cx(y) return 32 + 0.9 * sin((y - Y0) / (Y1 - Y0) * pi * 1.2) end
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  local w = 3.2 + 2.3 * sin(min(1, t / 0.55) * pi / 2)
  if y > 49 then w = w + 0.32 * (y - 49) ^ 1.7 end
  return w
end
local trunk = HP.mask()
local TU = {}
for y = Y0, Y1 do local h, m = hw(y), cx(y)
  for x = floor(m - h + 0.5), floor(m + h - 0.5) do
    local u = (x + 0.5 - m) / h
    -- root gaps on the last two rows
    local gap = y >= Y1 - 1 and (abs(x - floor(m) + 6) < 1 or abs(x - floor(m) - 6) < 1)
    if not gap then trunk:set(x, y) TU[K(x, y)] = u end
  end end
-- branches into the crown
local brm = HP.mask()
local b1 = A.tube({ { 31, 33 }, { 29, 28 }, { 26, 25 }, { 22, 22 } }, function(t) return 1.6 - 0.6 * t end)
local b2 = A.tube({ { 33, 32 }, { 35, 28 }, { 38, 25 }, { 43, 22 } }, function(t) return 1.6 - 0.6 * t end)
brm:add(b1):add(b2):cut(trunk)

-- crown: bumpy clumps, back to front
local blobs = { { 22, 20, 7 }, { 42, 19, 7 }, { 32, 15, 7.2 }, { 16, 27, 5.6 }, { 48, 27, 5.6 }, { 32, 21, 7 }, { 26, 28, 6 }, { 38, 28, 6 } }
local crown, owner = HP.mask(), {}
for i, b in ipairs(blobs) do
  local R = b[3] + 1.5
  for y = floor(b[2] - R), floor(b[2] + R) do for x = floor(b[1] - R), floor(b[1] + R) do
    local dx, dy = x + 0.5 - b[1], y + 0.5 - b[2]
    local a = atan(dy, dx)
    local r = b[3] + 0.75 * sin(a * 7 + i * 1.7)
    if dx * dx + dy * dy <= r * r then crown:set(x, y) owner[K(x, y)] = i end
  end end
end

-- trunk shading: cylinder normals, fissures, AO under the crown
local tn = {}
for k, u in pairs(TU) do local s = max(-0.95, min(0.95, u)) tn[k] = { s, 0.15, sqrt(1 - s * s) } end
local tb = {}
X.ao(tb, trunk, crown, 2, -1)
local tidx = A.shade(c, trunk, tn, BARK, { amb = 0.08, wrap = 0.3, bias = tb, tok = btok })
trunk:each(function(x, y) local k = K(x, y)
  local u = TU[k]
  local p = u * 2.6 + 0.22 * sin(y * 0.8) + (y > 49 and 0.1 * (y - 49) * u or 0)
  local f = p - floor(p)
  if f < 0.17 then c:put(x, y, BARK[max(1, tidx[k] - 2)], btok)
  elseif f < 0.33 and u < 0.2 then c:put(x, y, BARK[min(6, tidx[k] + 1)], btok) end
end)
do local n = X.pillow(brm, 1.5) local bb = {} X.ao(bb, brm, crown, 1, -1)
  A.shade(c, brm, n, BARK, { amb = 0.1, wrap = 0.3, bias = bb, tok = btok }) end

-- crown shading
local gn = A.body(crown, 30, 18, 22, 5, 0.5)
local cn, cb = {}, {}
crown:each(function(x, y) local k = K(x, y)
  local b = blobs[owner[k]]
  local nx, ny = (x + 0.5 - b[1]) / (b[3] + 1), (y + 0.5 - b[2]) / (b[3] + 1)
  local q = max(0.05, 1 - nx * nx - ny * ny)
  local g = gn[k]
  cn[k] = { A.norm(nx * 0.55 + g[1] * 0.45, ny * 0.55 + g[2] * 0.45, sqrt(q) * 0.55 + g[3] * 0.45) }
  -- contact shadow: a front clump sits just above/left of this pixel
  for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { -1, -1 }, { 0, -2 } } do
    local o = owner[K(x + d[1], y + d[2])]
    if o and o > owner[k] then cb[k] = -2 break end
  end
end)
local cidx, cv = A.shade(c, crown, cn, LEAF, { amb = 0.1, wrap = 0.25, bias = cb, tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
-- leaf flecks: little 2px leaf marks, lit on the lit side, dark on the shade side
crown:shrink(1):each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if cb[k] then return end
  if h > 0.86 and cidx[k] >= 3 and cidx[k] < 6 then c:put(x, y, LEAF[cidx[k] + 1], ltok) if crown:has(x + 1, y - 1) then c:put(x + 1, y - 1, LEAF[cidx[k] + 1], ltok) end
  elseif h < 0.1 and cidx[k] > 1 then c:put(x, y, LEAF[cidx[k] - 1], ltok) end
end)
local rim = X.rim(cn)
crown:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and (cidx[k] or 1) <= 3 and not cb[k] then c:put(x, y, COOL, ltok) end end)
-- specular on the top clump
c:put(27, 10, SPEC, ltok) c:put(28, 10, SPEC, ltok) c:put(27, 11, LEAF[6], ltok)

-- heart hollow
local hcx, hcy, S = cx(44) + 0.2, 43.2, 3.0
local heart = HP.mask()
local HROWS = { ".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }
local hx0, hy0 = floor(hcx + 0.5) - 3, 40
for r, row in ipairs(HROWS) do for i = 1, #row do if row:sub(i, i) == "X" then heart:set(hx0 + i - 1, hy0 + r - 1) end end end
hcx, hcy = hx0 + 3.5, hy0 + 2.5
heart:clip(trunk)
local lip = heart:grow(1):cut(heart):clip(trunk)
lip:each(function(x, y) local k = K(x, y)
  local dx, dy = x + 0.5 - hcx, y + 0.5 - hcy
  if dx + dy < 0.5 then c:put(x, y, BARK[6], htok) elseif dx + dy > 3 then c:put(x, y, BARK[2], htok) else c:put(x, y, BARK[5], htok) end
end)
heart:each(function(x, y)
  local dx, dy = x + 0.5 - hcx, y + 0.5 - hcy
  local col = "#1c1118"
  -- far inner wall catches light lower-right
  if not heart:has(x + 1, y) or not heart:has(x, y + 1) then col = (dx + dy > 0) and "#5a3530" or "#140c12" end
  if (heart:has(x + 1, y) and heart:has(x, y + 1)) and (not heart:has(x + 2, y) or not heart:has(x, y + 2)) and dx + dy > 1 then col = "#33201f" end
  c:put(x, y, col, htok)
end)
-- quirk: gold eyes peeking from the two lobes of the heart
c:put(hx0 + 1, hy0 + 1, "#ffd24a", htok) c:put(hx0 + 4, hy0 + 1, "#ffd24a", htok)
c:put(hx0 + 1, hy0 + 2, "#b8661c", htok) c:put(hx0 + 4, hy0 + 2, "#b8661c", htok)
A.save(c, NAME)
