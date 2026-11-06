-- mushroom-toast (final, Opus). A slice of toast seen from just above: domed loaf silhouette, a bevelled golden-brown
-- crust ring, pitted toasted crumb (darker toasting toward the rim), a 4 px crust side in shade underneath. On top,
-- four butter-glossy sauteed mushroom slices in profile (dark skin on the cap, pale flesh, a gill band, a lit
-- specular), contact shadow under each, and a scatter of parsley.
-- quirk: a bead of melted butter runs off the lower-right corner and hangs from the crust as a drip.
local NAME = "mushroom-toast"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)

local CRUST = { "#4a2620", "#6e3826", "#94532e", "#b8743a", "#d69a50", "#ecc070" }
local CRUMB = { "#9a6438", "#c08648", "#d9a85c", "#e8c272", "#f4d898", "#fcebc0" }
local MUSH = { "#3a2020", "#5a3226", "#7e4c32", "#a87048", "#cf9f6e", "#eed0a0" }
local FLESH = { "#7a5034", "#9c6c44", "#bc8c5c", "#d6ac78" }
local PARS = { "#24544a", "#3f9150", "#7cc35a" }
local BUT = { "#d9a830", "#f6d65a", "#fff0a0", "#fff4d6" }

-- top face
local top = c:rrect(13, 23, 50, 46, 3)
top:add(c:ellipse(22, 23, 9.5, 6.5)):add(c:ellipse(41, 23, 9.5, 6.5)):add(c:rect(14, 20, 49, 26))
-- crust side (thickness), shade side lower-right
local side = HP.mask()
for k = 1, 4 do side:add(top:shift(0, k)) if k >= 2 then side:add(top:shift(1, k)) end end
side:cut(top)
local stok = { r = { name = "side" } }
local sbb = side:bbox()
side:each(function(x, y)
  local i = 3
  if not side:has(x, y + 1) then i = 1 elseif not top:has(x, y - 1) and not side:has(x, y - 1) then i = 2 end
  if top:has(x, y - 1) then i = 2 end
  if x < 22 and i == 3 then i = 4 end
  if X.hash(x, y, 11) > 0.86 and i >= 3 then i = i - 1 end
  c:put(x, y, CRUST[i], stok)
end)

-- top: crust ring (bevelled) + crumb
local inner = top:shrink(2)
local ring = top:copy():cut(inner)
local tn = X.pillow(top, 2.5)
local tok = { r = { name = "top" } }
A.shade(c, ring, tn, CRUST, { amb = 0.25, wrap = 0.35, cuts = { 0.25, 0.42, 0.58, 0.72, 0.86 }, tok = tok })

-- toppings first as masks (for AO / contact shadow on the crumb)
local function slice(cx, cy, rx, ry, flip)
  local cap = c:ellipse(cx, cy, rx, ry)
  local m = HP.mask()
  cap:each(function(x, y) if y <= cy + 0.5 then m:set(x, y) end end)
  local sx0 = floor(cx - 1.5 + (flip and 1 or 0))
  m:add(c:rect(sx0, floor(cy), sx0 + 2, floor(cy) + 4))
  m:set(sx0 - 1, floor(cy) + 4) m:set(sx0 + 3, floor(cy) + 4)
  return { m = m, cap = cap, cx = cx, cy = cy, rx = rx, ry = ry }
end
local sl = { slice(23, 25, 5.5, 4, false), slice(39, 27, 5, 3.5, true), slice(28, 37, 4.5, 3.5, true), slice(42, 39, 4, 3, false) }
local cb = {}
inner:each(function(x, y)
  -- toasting: darker within 3 px of the crust, a few pits
  local d = 0
  if not inner:has(x - 3, y) or not inner:has(x + 3, y) or not inner:has(x, y - 3) or not inner:has(x, y + 3) then d = -1 end
  local h = X.hash(x, y, 5)
  if h > 0.9 then d = d - 2 elseif h > 0.8 then d = d - 1 elseif h < 0.06 then d = d + 1 end
  cb[K(x, y)] = d
end)
for _, s in ipairs(sl) do X.ao(cb, inner, s.m, 1, -1) A.cast(cb, inner, s.m, 1, 1, -2) end
local cn = X.pillow(inner, 3)
A.shade(c, inner, cn, CRUMB, { amb = 0.35, wrap = 0.4, cuts = { 0.2, 0.36, 0.5, 0.64, 0.8 }, bias = cb, tok = { r = { name = "crumb" } } })

-- butter puddle near the lower-right corner, feeding the drip
local btok = { r = { name = "butter" } }
for _, q in ipairs{ { 45, 43, 2 }, { 46, 43, 2 }, { 44, 44, 2 }, { 45, 44, 3 }, { 46, 44, 2 }, { 47, 44, 2 }, { 46, 45, 2 }, { 47, 45, 1 },
  { 47, 46, 2 }, { 48, 46, 1 } } do c:put(q[1], q[2], BUT[q[3]], btok) end
-- quirk: the drip down the crust side, hanging a bead below
for _, q in ipairs{ { 47, 47, 2 }, { 48, 47, 1 }, { 47, 48, 2 }, { 48, 48, 1 }, { 47, 49, 2 }, { 48, 49, 1 }, { 47, 50, 2 }, { 48, 50, 1 },
  { 47, 51, 3 }, { 48, 51, 2 }, { 47, 52, 2 }, { 48, 52, 1 } } do c:put(q[1], q[2], BUT[q[3]], btok) end
c:put(47, 51, BUT[4], btok)

-- parsley flecks
local ptok = { r = { name = "parsley" } }
for _, q in ipairs{ { 18, 33 }, { 33, 23 }, { 36, 35 }, { 20, 41 }, { 47, 33 }, { 31, 30 }, { 24, 44 } } do
  do
    c:put(q[1], q[2], PARS[2], ptok) c:put(q[1] + 1, q[2], PARS[3], ptok) c:put(q[1], q[2] + 1, PARS[1], ptok) end
end

-- mushroom slices
for i, s in ipairs(sl) do
  local mtok = { r = { name = "mush" .. i } }
  local n = X.pillow(s.m, 2)
  -- flesh everywhere, then skin on the cap top, gill band, darker stem edges
  local fi = A.shade(c, s.m, n, FLESH, { amb = 0.25, wrap = 0.35, cuts = { 0.3, 0.55, 0.78 }, tok = mtok })
  local capTop = HP.mask()
  s.m:each(function(x, y)
    if s.cap:has(x, y) and y <= s.cy and (not s.m:has(x, y - 1) or not s.m:has(x, y - 2) and (not s.m:has(x - 1, y) or not s.m:has(x + 1, y))) then capTop:set(x, y) end
  end)
  -- skin 1-2 px thick, browned by the pan
  s.m:each(function(x, y)
    if capTop:has(x, y) or (s.cap:has(x, y) and y <= s.cy and (not s.m:has(x - 1, y) or not s.m:has(x + 1, y))) then
      local i2 = (x < s.cx and y < s.cy - 1) and 4 or 3
      if x > s.cx + s.rx - 2 then i2 = 2 end
      c:put(x, y, MUSH[i2], mtok)
    end
  end)
  -- gill band under the cap
  for x = floor(s.cx - s.rx + 1), floor(s.cx + s.rx - 1) do
    local y = floor(s.cy + 0.5)
    if s.m:has(x, y) and s.m:has(x, y - 1) and (x % 2 == 0) then c:put(x, y, MUSH[2], mtok) elseif s.m:has(x, y) then c:put(x, y, MUSH[3], mtok) end
  end
  -- stem shade side + base
  s.m:each(function(x, y) if y > s.cy + 0.5 and not s.m:has(x + 1, y) then c:put(x, y, MUSH[3], mtok) end
    if y > s.cy + 0.5 and not s.m:has(x, y + 1) then c:put(x, y, MUSH[3], mtok) end end)
  -- butter gloss specular on the cap skin
  local gx, gy = floor(s.cx - s.rx * 0.45), floor(s.cy - s.ry * 0.7)
  if s.m:has(gx, gy) then c:put(gx, gy, MUSH[6], mtok) c:put(gx + 1, gy, MUSH[5], mtok) end
end
c:put(22, 21, BUT[4], { r = { name = "mush1" } })

A.save(c, NAME)
