-- ico-bridge (final, Opus). Side view of a hump-backed stone bridge: one round arch over a slim strip of river,
-- coping stones along the curved parapet, flared abutments.
-- Material: every ashlar block is its own bevelled pillow lit per pixel (6-tone cool stone) with dark mortar
-- joints, a ring of radial voussoirs with a keystone, lighter coping with a bright top edge and a dark drip row
-- beneath, damp darker stone and moss tufts near the waterline, deep shadow under the arch, 6-tone water with
-- ripples and the arch's dark reflection.
-- quirk: a small yellow duck paddles through under the arch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("ico-bridge")
local STONE = { "#2f2c44", "#46445e", "#64637e", "#8a89a2", "#b2b1c4", "#dcdbe6" }
local WARM  = { "#3e3440", "#5a4e5a", "#7c6f78", "#a3949a", "#c8bab8", "#ebe0d8" }   -- coping / voussoirs
local WATER = { "#233f6e", "#2f5f94", "#3a86b0", "#4fa9c2", "#7fd0d4", "#c2f2e6" }
local MOSS  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local MORTAR, VOID, VOID2 = "#2e2a3e", "#241d34", "#33294a"

local CX, WL = 32, 45                     -- centre, water line
local function top(x) local t = (x - CX) / 22 return 20 + 17 * t * t end
local ARX, ARY = 13, 13.5
local function inArch(x, y, g) local dx, dy = (x - CX) / (ARX + g), (y - WL) / (ARY + g) return dx * dx + dy * dy <= 1 and y <= WL end

-- body silhouette
local body = HP.mask()
for y = 10, WL do for x = 6, 58 do
  local half = 21.5
  if abs(x - CX + 0.5) <= half and y >= top(x) then body:set(x, y) end
end end
local opening = HP.mask()
body:each(function(x, y) if inArch(x, y, 0) then opening:set(x, y) end end)
body:cut(opening)

-- water strip (drawn first; bridge feet sit in it)
local water = HP.mask()
for y = WL - 1, WL + 5 do for x = 11, 53 do
  local e = (y >= WL + 4) and 2 or 0
  if x >= 11 + e and x <= 53 - e then water:set(x, y) end
end end
local wtok = { r = { name = "water" } }
water:each(function(x, y)
  local t = (y - (WL - 1))
  local i = t <= 1 and 5 or (t <= 3 and 4 or 3)
  if x >= CX - ARX + 1 and x <= CX + ARX - 1 then i = i - 2 end    -- arch reflection
  if y >= WL + 4 then i = i - 1 end
  c:put(x, y, WATER[max(1, i)], wtok)
end)
for _, r in ipairs{ { 16, WL + 2, 3 }, { 45, WL + 1, 4 }, { 26, WL + 3, 2 }, { 39, WL + 3, 3 }, { 18, WL + 4, 2 } } do
  for i = 0, r[3] - 1 do c:put(r[1] + i, r[2], WATER[6], wtok) end
end

-- shadow under the arch
local vtok = { r = { name = "void" } }
-- the arch is open (sky shows through); only the soffit of the barrel vault shows as a dark band inside the ring
opening:each(function(x, y) if not inArch(x, y, -2.2) and y < WL - 1 then c:put(x, y, (x < CX) and STONE[2] or VOID2, vtok) end end)
opening:each(function(x, y) if not inArch(x, y, -1.1) and y < WL - 1 then c:put(x, y, VOID, vtok) end end)

-- masonry
local stok, ctok2 = { r = { name = "stone" } }, { r = { name = "coping" } }
local ring = HP.mask()
body:each(function(x, y) if inArch(x, y, 4.2) then ring:set(x, y) end end)
local cope = HP.mask()
body:each(function(x, y) if y <= top(x) + 3.2 then cope:set(x, y) end end)
ring:cut(cope)
local walls = body:copy():cut(ring):cut(cope)

-- split a mask into blocks keyed by id function; mortar where id==nil
local function blocks(m, idf, ramp, tok, R, damp)
  local groups, mortar = {}, HP.mask()
  m:each(function(x, y) local id = idf(x, y)
    if id then groups[id] = groups[id] or HP.mask() groups[id]:set(x, y) else mortar:set(x, y) end end)
  mortar:each(function(x, y) c:put(x, y, MORTAR, tok) end)
  local all = {}
  for id, g in pairs(groups) do
    local n = X.pillow(g, R or 1.4)
    local bias = {}
    local hv = X.hash(#id, id:byte(1) + (id:byte(#id) or 0), 3)
    g:each(function(x, y) local k = K(x, y)
      local b = (hv > 0.78) and -1 or 0
      if damp and y > WL - 7 then b = b - 1 end
      bias[k] = b end)
    local idx = A.shade(c, g, n, ramp, { tok = tok, bias = bias, amb = 0.12, wrap = 0.35, cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 } })
    all[id] = idx
  end
  return groups, all
end

-- wall courses: 5 px (4 stone + 1 mortar), blocks 8 wide staggered
blocks(walls, function(x, y)
  local row = floor((y - 1) / 5)
  if (y - 1) % 5 == 4 then return nil end
  local xo = x + (row % 2) * 4 + (row % 3)
  if xo % 8 == 7 then return nil end
  return row .. ":" .. floor(xo / 8)
end, STONE, stok, 1.4, true)

-- voussoirs: radial joints around the arch, keystone at the crown
blocks(ring, function(x, y)
  local a = atan(WL - y, x - CX)                  -- 0 right .. pi left
  local f = a / (pi / 11)
  local fr = f - floor(f)
  local ok = abs(x - CX) <= 1 and y < WL - ARY - 0.5
  if not ok and fr < 0.11 then return nil end
  if ok then return "key" end
  return "v" .. floor(f)
end, WARM, stok, 1.3)

-- coping: long cap stones along the parapet
local cgroups = blocks(cope, function(x, y)
  local xo = x + 3
  if xo % 11 == 10 then return nil end
  return "c" .. floor(xo / 11)
end, WARM, ctok2, 1.5)
-- bright top edge, dark drip row under the coping (ambient where it overhangs the wall)
cope:each(function(x, y) if not body:has(x, y - 1) and c:get(x, y) ~= MORTAR then c:put(x, y, WARM[6], ctok2) end end)
walls:each(function(x, y) if cope:has(x, y - 1) then c:put(x, y, STONE[1], stok) end end)
-- ambient under the voussoir ring where it meets the wall above (one dark row)
walls:each(function(x, y) if ring:has(x, y + 1) and c:get(x, y) ~= MORTAR then
  local cur = c:get(x, y) for i = 2, #STONE do if STONE[i] == cur then c:put(x, y, STONE[i - 1], stok) end end end end)

-- moss tufts near the waterline and on the abutment feet
local mtok = { r = { name = "moss" } }
for _, p in ipairs{ { 17, WL - 6, 2 }, { 47, WL - 1, 3 }, { 49, WL - 9, 2 }, { 18, WL - 1, 2 }, { 45, WL - 7, 2 } } do
  for i = 0, p[3] - 1 do
    local x = p[1] + i
    if body:has(x, p[2]) then c:put(x, p[2], (i == 0) and MOSS[3] or MOSS[2], mtok)
      if body:has(x, p[2] + 1) and i < p[3] - 1 then c:put(x, p[2] + 1, MOSS[1], mtok) end
      if i == 1 then c:put(x, p[2], MOSS[4], mtok) end
    end
  end
end

-- grassy banks at both ends (soil face, grass lip), in front of the abutment feet
local SOIL = { "#3e2628", "#5e3a2e", "#864c33", "#a86c44", "#c88e5a" }
local btok = { r = { name = "bank" } }
for _, sd in ipairs{ -1, 1 } do
  local bx = CX + sd * 20 - 0.5
  local bank = A.ellM(bx, WL + 2.5, 5, 5.5)
  bank:clip(HP.mask():add(c:rect(4, WL - 4, 59, WL + 5)))
  local bn = X.pillow(bank, 2)
  A.shade(c, bank, bn, SOIL, { tok = btok, amb = 0.1, wrap = 0.3 })
  bank:each(function(x, y)
    if not bank:has(x, y - 1) then c:put(x, y, MOSS[3], btok) if bank:has(x, y + 1) then c:put(x, y + 1, MOSS[2], btok) end
      if bank:has(x, y + 2) and X.hash(x, 1, 5) > 0.5 then c:put(x, y + 2, MOSS[1], btok) end end
    if X.hash(x, y, 8) > 0.9 and bank:has(x, y - 3) then c:put(x, y, SOIL[5], btok) end   -- pebbles
  end)
  local tx = floor(bx - sd * 2)
  c:put(tx, WL - 4, MOSS[4], btok) c:put(tx + sd, WL - 4, MOSS[3], btok)
end

-- quirk: a little duck paddling under the arch
A.map(c, {
  "..hY..",
  ".hYeY.",
  "..YYoo",
  "hYYYY.",
  "YYYyy.",
  ".ryyr.",
}, CX + 1, WL - 4, { h = "#fff0a8", Y = "#f5c42e", y = "#d9902a", e = A.INK, o = "#f07a2e", r = WATER[5] }, wtok)

A.save(c, "ico-bridge")
