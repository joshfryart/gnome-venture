-- honeydew (final, Opus single pass aC12_2). A smooth, slightly egg-shaped honeydew melon (6-tone pale lime-cream
-- rind lit per pixel), faint lengthwise meridian streaks, waxy bloom specks, one cream specular on the shoulder, cool
-- reflected light on the lower right, a sunken stem scar with a short dry woody stem and a curled tendril. A crescent
-- slice lies in front: thin green rind, mint flesh ramp, cream seed bed with flat pale seeds and a juice glint;
-- AO on the melon behind it, contact + 2-tone ground shadow.
-- quirk: a little oval produce sticker on the rind, one edge peeling up.
local NAME = "honeydew"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local RIND = { "#55704a", "#7f9c5e", "#a9c27a", "#cbdc96", "#e3edb4", "#f5f8d2" }
local FLESH = { "#4f8f5a", "#6fb06a", "#92cc7e", "#b4e094", "#d2efb0", "#ecfad0" }
local WOOD = { "#3a2420", "#5e3a2a", "#84583a", "#a8794e" }
local BOUNCE = "#a6d4c4"
local mtok, stok, wtok, ktok = { r = { name = "melon" } }, { r = { name = "slice" } }, { r = { name = "stem" } }, { r = { name = "sticker" } }

c:groundShadow(32, 54, 21, 2)
-- melon body: egg shape, wider low
local CX, CY = 29, 35
local body = HP.mask()
for y = 15, 55 do for x = 8, 52 do
  local dy = (y - CY) / 18.5
  local rx = 16.5 * (1 + 0.08 * dy)
  local dx = (x - CX) / rx
  if dx * dx + dy * dy <= 1 then body:set(x, y) end
end end
local n = A.body(body, CX, CY - 2, 17, 7, 0.65)
-- slice (in front, lower right)
local outer, inner = c:ellipse(40, 47, 13, 9), c:ellipse(40, 46, 10, 5)
local slice = HP.mask()
outer:each(function(x, y) if y >= 47 and not inner:has(x, y) then slice:set(x, y) end end)
local bias = {}
X.ao(bias, body, slice, 2, -1)
A.cast(bias, body, slice, 0, -1, -1)
-- streaks: meridians converging at the stem scar, slightly lighter / darker pairs
body:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - (CY - 18)
  local a = atan(dx, dy + 6)
  local ph = (a * 9) % 1
  if ph < 0.09 and y > 19 and y < 50 and X.hash(x, y, 3) > 0.25 then bias[k] = (bias[k] or 0) + 1
  elseif ph > 0.5 and ph < 0.57 and y > 21 and y < 48 and X.hash(x, y, 5) > 0.45 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx, val = A.shade(c, body, n, RIND, { amb = 0.08, wrap = 0.24, bias = bias, tok = mtok, cuts = { 0.26, 0.43, 0.58, 0.72, 0.86 } })
-- cool reflected light
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.65 and y > 30 and not slice:grow(1):has(x, y) then c:put(x, y, BOUNCE, mtok) end end)
-- waxy bloom specks
body:shrink(2):each(function(x, y) local k = K(x, y)
  if val[k] > 0.55 and val[k] < 0.8 and X.hash(x, y, 17) > 0.93 then c:put(x, y, RIND[6], mtok) end end)
-- specular
c:put(19, 24, A.CREAM, mtok) c:put(20, 24, A.CREAM, mtok) c:put(19, 25, RIND[6], mtok) c:put(21, 23, RIND[6], mtok)
-- stem scar: sunken ring + short dry stem with a curled tendril
for _, p in ipairs{ { 27, 17, 2 }, { 28, 17, 1 }, { 29, 17, 1 }, { 30, 17, 1 }, { 31, 17, 2 }, { 28, 18, 3 }, { 29, 18, 2 }, { 30, 18, 3 }, { 27, 16, 3 }, { 31, 16, 3 } } do
  c:put(p[1], p[2], RIND[p[3]], mtok) end
local sm, sn = A.tube({ { 29, 17 }, { 29, 14 }, { 30, 12 }, { 31, 10 } }, function(t) return 1.2 - 0.3 * t end)
A.shade(c, sm, sn, WOOD, { amb = 0.12, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = wtok })
c:put(31, 9, WOOD[4], wtok) c:put(30, 10, WOOD[4], wtok)
A.line(c, { { 31, 12 }, { 33, 11 }, { 35, 11 }, { 36, 9 }, { 35, 8 }, { 34, 9 } }, "#7f9c5e", wtok)
c:put(33, 11, "#a9c27a", wtok)

-- quirk: produce sticker (pink oval, white-ish text dash, peeling corner shows cream underside)
A.paint(c, {
  ".pPPp.",
  "pPhPPd",
  "PwwwPd",
  ".pPPdd",
}, 34, 29, { p = "#c94f84", P = "#f5809f", h = "#ffc4d8", w = "#fff4d6", d = "#7d2c5e" }, ktok)
c:put(40, 28, "#e9dcc0", ktok) c:put(39, 28, "#fff4d6", ktok)
c:put(40, 30, RIND[1], mtok)

-- slice: rind outer ring, flesh, seed bed on the top edge
local sTop = HP.mask()
slice:each(function(x, y) if not slice:has(x, y - 1) then sTop:set(x, y) end end)
local ring = slice:copy():cut(slice:shrink(1)):cut(sTop)
local sn2 = {}
slice:each(function(x, y) local dx = (x - 40) / 13 sn2[K(x, y)] = { A.norm(dx * 0.6, -0.55, 1) } end)
local fb = {}
slice:each(function(x, y) local k = K(x, y) fb[k] = (y - 47) >= 3 and -1 or 0 end)
A.shade(c, slice, sn2, FLESH, { amb = 0.2, wrap = 0.3, bias = fb, tok = stok })
ring:each(function(x, y) c:put(x, y, (x > 42) and "#55704a" or "#7f9c5e", stok) end)
slice:each(function(x, y) if ring:has(x, y - 1) == false and ring:has(x, y + 1) and not ring:has(x, y) then c:put(x, y, "#cbdc96", stok) end end)
sTop:each(function(x, y) c:put(x, y, (x % 3 == 0) and "#f2e6b8" or "#e8f0c0", stok) end)
for _, sx in ipairs{ 33, 37, 41, 45 } do c:put(sx, 47, "#d9c48e", stok) c:put(sx + 1, 47, "#fff4d6", stok) end
c:put(36, 49, A.CREAM, stok) c:put(37, 49, FLESH[6], stok)
A.save(c, NAME)
