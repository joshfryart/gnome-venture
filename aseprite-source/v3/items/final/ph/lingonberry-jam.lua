-- lingonberry-jam (final, Opus single pass). A slim tall glass jar of deep ruby jam with whole lingonberries
-- suspended in it; a linen cloth cover (diagonal weave, pleated skirt) tied at the neck with twisted twine and a
-- small kraft tag. Glass: pale wall, bright rim, two specular streaks, thick glass base, cool reflected edge.
-- quirk: a fat drip of jam has escaped under the cloth and runs down the glass.
local NAME = "lingonberry-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, sqrt, floor = math.abs, math.max, math.min, math.sqrt, math.floor
local c = A.new(NAME)

local RUBY  = { "#3a0f26", "#5e132f", "#8a1b36", "#b5283b", "#dc4446", "#ff8466" }
local GLASS = { "#4d5f86", "#7b95b4", "#a9c6d6", "#cfe8ea", "#eaf8f2" }
local LIN   = { "#5c3f3a", "#8c6a58", "#b99878", "#d9bd96", "#efdcb4", "#fff1d0" }
local TW    = { "#5a3424", "#8a5530", "#b98444", "#e0b468" }
local KRAFT = { "#6e4a30", "#a47548", "#c99a64", "#e6c38a" }
local COOL  = "#6a3a6e"

c:groundShadow(32, 58, 13, 1)

-- glass: body + neck
local body = c:rrect(21, 25, 43, 57, 4)
local neck = c:rect(24, 21, 40, 25)
local glass = body:copy():add(neck)
-- per-row half widths -> cylinder normals
local rows = {}
glass:each(function(x, y) local r = rows[y] or { 99, -99 } r[1] = min(r[1], x) r[2] = max(r[2], x) rows[y] = r end)
local n = {}
glass:each(function(x, y)
  local r = rows[y] local cx, hw = (r[1] + r[2]) / 2, (r[2] - r[1]) / 2 + 0.5
  local sn = max(-0.96, min(0.96, (x - cx) / hw))
  local ny = 0
  if y >= 54 then ny = 0.35 * (y - 53) / 4 end
  local l = sqrt(sn * sn + ny * ny + (1 - sn * sn))
  n[K(x, y)] = { sn / l, ny / l, sqrt(1 - sn * sn) / l }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })

local wall = glass:copy():cut(glass:shrink(1))
local inner = glass:shrink(1)
local jam = HP.mask() inner:each(function(x, y) if y >= 29 and y <= 54 then jam:set(x, y) end end)
local base = HP.mask() inner:each(function(x, y) if y >= 55 then base:set(x, y) end end)
local head = inner:copy():cut(jam):cut(base)

local gtok, jtok = { r = { name = "glass" } }, { r = { name = "jam" } }
-- glass wall + empty headspace + thick base
X.tone(c, wall, v, GLASS, { cuts = { 0.2, 0.42, 0.62, 0.82 }, tok = gtok })
X.tone(c, head, v, GLASS, { cuts = { 0.3, 0.5, 0.7, 0.9 }, bias = {}, tok = gtok })
X.tone(c, base, v, GLASS, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = gtok })
-- jam: per-pixel cylinder light, AO at bottom and under meniscus, darker toward the core
local jb = {}
jam:each(function(x, y) local k = K(x, y)
  if y >= 53 then jb[k] = -1 end
  if y == 29 then jb[k] = 1 end
end)
local jidx = X.tone(c, jam, v, RUBY, { cuts = { 0.16, 0.34, 0.52, 0.7, 0.9 }, bias = jb, tok = jtok })
-- cool reflected light on the shade edge of the jam
jam:each(function(x, y) local r = rows[y] if x == r[2] - 1 and y > 33 and y < 52 then c:put(x, y, COOL, jtok) end end)
-- whole berries floating in the jam (glossy little spheres, one glint each)
for _, b in ipairs{ { 26, 34 }, { 33, 38 }, { 38, 33 }, { 28, 44 }, { 36, 47 }, { 31, 51 }, { 25, 50 }, { 39, 42 } } do
  local bx, by = b[1], b[2]
  local bm = c:ellipse(bx, by, 1.5, 1.5)
  local bn = X.sphere(bx, by, 1.6, bm)
  local lit = X.light(bn, { amb = 0.1, wrap = 0.2 })
  local side = (bx > 35) and -1 or 0
  bm:each(function(x, y) if jam:has(x, y) then local k = K(x, y)
    local i = (lit[k] > 0.75 and 5) or (lit[k] > 0.4 and 4) or 3
    c:put(x, y, A.step(RUBY, i, side), jtok) end end)
  c:put(bx, by + 2, RUBY[2], jtok)                                -- tiny contact dark under each berry
  c:put(bx - 1, by - 1, side < 0 and RUBY[5] or RUBY[6], jtok)    -- glint
end
-- meniscus: pale line where jam meets the glass wall at the top
for x = rows[29][1] + 1, rows[29][2] - 1 do if x % 3 ~= 0 then c:put(x, 29, RUBY[5], jtok) end end
-- glass specular streaks + bright rim at the shoulder + AO line on the base
for y = 30, 51 do if y ~= 41 and y ~= 42 then c:put(23, y, GLASS[5], gtok) end end
for y = 32, 37 do c:put(25, y, GLASS[4], gtok) end
for y = 46, 48 do c:put(25, y, GLASS[4], gtok) end
for x = 22, 42 do if c:get(x, 55) then c:put(x, 55, x < 30 and GLASS[4] or GLASS[2], gtok) end end
c:sparkle(24, 28)

-- cloth cover: puffed cap over the mouth, pleated skirt below the twine
local cap = c:ellipse(32, 16, 12, 5.5)
local capm = HP.mask() cap:each(function(x, y) if y >= 11 and y <= 20 then capm:set(x, y) end end)
capm:add(c:rect(21, 17, 43, 20))
local skirt = HP.mask()
for y = 22, 27 do
  local half = 11 + (y - 22) * 0.5
  for x = floor(32 - half), floor(32 + half + 0.5) do
    local hem = 26 + ((x % 4 == 0) and 1 or 0) - ((x % 4 == 2) and 1 or 0)
    if y <= hem then skirt:set(x, y) end
  end
end
local cloth = capm:copy():add(skirt)
local cn = X.pillow(cloth, 3)
local cb = {}
-- AO under the twine and on the jar glass beneath the skirt
skirt:each(function(x, y) if y == 22 then cb[K(x, y)] = -1 end end)
capm:each(function(x, y) if y == 20 then cb[K(x, y)] = -1 end end)
local ctok = { r = { name = "cloth" } }
local cidx = A.shade(c, cloth, cn, LIN, { bias = cb, tok = ctok, amb = 0.12, wrap = 0.35 })
-- weave: diagonal threads; pleats: vertical folds in the skirt
cloth:each(function(x, y) local k = K(x, y)
  local i = cidx[k]
  if (x + y) % 3 == 0 and capm:has(x, y) and i >= 3 then c:put(x, y, LIN[i - 1], ctok) end
  if skirt:has(x, y) and y > 22 then
    if x % 4 == 1 then c:put(x, y, A.step(LIN, i, -1), ctok)
    elseif x % 4 == 3 and x < 34 then c:put(x, y, A.step(LIN, i, 1), ctok) end
  end
end)
-- contact shadow of the skirt on the glass
for x = 22, 43 do local y = 0
  for yy = 28, 22, -1 do if skirt:has(x, yy) then y = yy break end end
  if y > 0 and glass:has(x, y + 1) and not skirt:has(x, y + 1) then c:put(x, y + 1, GLASS[1], gtok) end
end

-- twisted twine band + knot + tail with a kraft tag
local ttok = { r = { name = "twine" } }
for x = 21, 43 do
  c:put(x, 21, ((x % 3) == 0) and TW[4] or (x < 36 and TW[3] or TW[2]), ttok)
  c:put(x, 22, ((x % 3) == 1) and TW[1] or TW[2], ttok)
end
local knot = c:rect(39, 20, 41, 22)
knot:each(function(x, y) c:put(x, y, (x == 39 and y == 20) and TW[4] or TW[2 + ((x + y) % 2)], ttok) end)
local tail = A.seg(nil, 42, 23, 46, 29)
tail:each(function(x, y) c:put(x, y, (y % 2 == 0) and TW[3] or TW[2], ttok) end)
local tag = c:poly{ { 45, 29 }, { 49, 29 }, { 50, 31 }, { 50, 37 }, { 45, 37 }, { 44, 31 } }
local ktok = { r = { name = "tag" } }
tag:each(function(x, y)
  local i = 3
  if x <= 45 or y <= 30 then i = 4 end
  if x >= 50 or y >= 37 then i = 2 end
  c:put(x, y, KRAFT[i], ktok)
end)
c:put(47, 31, KRAFT[1], ktok)                -- punched hole
c:put(46, 34, RUBY[4], ktok) c:put(48, 34, RUBY[4], ktok) c:put(47, 35, RUBY[3], ktok) c:put(47, 33, "#3f9150", ktok)

-- quirk: jam drip escaping from under the cloth, running down the glass
local dtok = { r = { name = "drip" } }
local drip = c:rect(35, 27, 36, 33):add(c:ellipse(35.5, 35, 1.5, 1.6))
drip:each(function(x, y)
  local i = (x == 35) and 4 or 3
  if y >= 34 then i = (x <= 35 and y <= 35) and 5 or 3 end
  c:put(x, y, RUBY[i], dtok)
end)
c:put(35, 34, RUBY[6], dtok)
c:put(38, 35, GLASS[1], gtok) c:put(36, 37, GLASS[1], gtok) c:put(35, 37, GLASS[1], gtok)   -- shadow of the drip on the glass

A.save(c, NAME)
