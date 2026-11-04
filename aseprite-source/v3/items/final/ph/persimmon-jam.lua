-- persimmon-jam (Opus artist pass, single). A slim round-shouldered glass jar of glossy persimmon jam: per-pixel
-- cylinder light on the jam (6 tones) with darker fruit flecks and pale pulp bits, a 1px glass wall (cool rim on the
-- shade side, pale lit rim), a long glass specular streak, a wrap-around paper label (shaded with the cylinder) with a
-- little persimmon on it. Top: red-and-cream gingham cover with a weave pattern and fold lines, cinched by a twisted
-- twine cord with a bow, the frill flaring over the shoulder (AO under the frill on the glass). Ground shadow.
-- quirk: a fat jam drip has escaped from under the cloth and is sliding down the glass.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_3.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "persimmon-jam"
local c = D.new(NAME)

local JAM   = { "#4e1626", "#7e2224", "#b23a1c", "#dc5e18", "#f5862a", "#ffb35a" }
local GLASS = { "#3d4f7e", "#5c77a6", "#8db4cc", "#c6e6e4", "#ecfaf2" }
local PAPER = { "#8c6a58", "#bb9a7c", "#e2cba4", "#f6e8c6", "#fff6e0" }
local RED   = { "#5a1630", "#8a2034", "#bb3238", "#e2483e", "#f87660", "#ffa688" }
local CRM   = { "#86647a", "#b4949a", "#dcc0b4", "#f2dcc6", "#fff0dc", "#fffaf0" }
local PINK  = { "#6e2a3e", "#a24252", "#cf6460", "#ec8a7a", "#ffb09a", "#ffd2bc" }
local TW    = { "#6e4126", "#9c6a38", "#c99a52", "#ecc77a" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a" }
local cx = 31.5

c:groundShadow(31.5, 57, 15, 2)

-- jar body (glass) rows
local Y0, Y1 = 24, 56
local function hw(y)
  if y < 27 then return 9.5 + (y - 24) * 0.4 end            -- neck under the frill
  if y < 31 then return 10.5 + (y - 27) * 0.45 end          -- shoulder
  if y > 54 then return 12.3 - (y - 54) * 1.2 end           -- rounded heel
  return 12.3
end
local body = D.rows(cx, Y0, Y1, hw)
local wall = body:edge()
local jtok, gtok = D.tok("jam"), D.tok("glass")
local inside = body:copy():cut(wall)
local jam = inside:copy()
jam:each(function(x, y) if y < 28 then jam.s[K(x, y)] = nil end end)
local head = inside:copy():cut(jam)
local bx0, _, bx1 = body:bbox()
local n = D.vcyl(body, bx0, bx1, nil, Y1, 4)
-- jam: cylinder light, flecks, pulp
local bias = {}
local jidx = D.tone(c, jam, n, JAM, { amb = 0.1, wrap = 0.35, bias = bias, tok = jtok })
jam:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 3)
  if y > 29 and h > 0.94 then c:put(x, y, JAM[max(1, (jidx[k] or 3) - 2)], jtok)
  elseif y > 29 and h < 0.05 and (jidx[k] or 1) >= 3 then c:put(x, y, JAM[min(6, jidx[k] + 2)], jtok) end
end)
-- meniscus: lit top surface row of the jam
for x = bx0 + 1, bx1 - 1 do if jam:has(x, 28) then c:put(x, 28, x < cx + 4 and JAM[6] or JAM[4], jtok) end end
-- headspace glass (pale) between jam and frill
D.tone(c, head, n, { GLASS[3], GLASS[4], GLASS[5] }, { cuts = { 0.4, 0.75 }, tok = gtok })
-- glass wall: lit rim left, cool rim right, deep heel
wall:each(function(x, y)
  local hex
  if x < cx - 3 then hex = (y < 50) and GLASS[4] or GLASS[3]
  elseif x > cx + 3 then hex = (y < 40) and GLASS[3] or GLASS[2]
  else hex = (y > 50) and GLASS[1] or GLASS[3] end
  c:put(x, y, hex, gtok)
end)
-- heel: thick glass base row
for x = bx0 + 2, bx1 - 2 do if body:has(x, Y1 - 1) then c:put(x, Y1 - 1, x < cx - 2 and GLASS[3] or GLASS[2], gtok) end end
-- label (wraps the cylinder)
local lab = c:rect(24, 36, 39, 47)
local ltok = D.tok("label")
D.tone(c, lab, n, PAPER, { cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.15, wrap = 0.4, tok = ltok })
for x = 24, 39 do c:put(x, 36, PAPER[x < 34 and 5 or 3], ltok) c:put(x, 47, PAPER[x < 34 and 3 or 2], ltok) end
-- label edges: AO line on the jam under the label
for x = 24, 39 do if jam:has(x, 48) then c:put(x, 48, JAM[max(1, (jidx[K(x, 48)] or 3) - 1)], jtok) end end
-- tiny persimmon on the label (squat, 4-lobed calyx)
c:paint({
  "..gaag..",
  ".hbbbbs.",
  "hbbbbbss",
  "bbbbbsss",
  ".bbbsss.",
  "..ssdd..",
}, 28, 39, { g = LEAF[2], a = LEAF[3], h = "#ffb35a", b = "#f07a24", s = "#c4481c", d = "#8e2a22" })
-- two ruled lines (handwriting) right of the fruit
for x = 36, 38 do c:put(x, 41, PAPER[2], ltok) end
for x = 35, 38 do c:put(x, 43, PAPER[2], ltok) end
-- glass specular streak + small glint
for y = 30, 52 do if y ~= 35 and y ~= 48 and not lab:has(25, y) then c:put(24, y, GLASS[5], gtok) end end
for y = 31, 46 do if not lab:has(23, y) and y % 6 ~= 0 then c:put(23, y, GLASS[4], gtok) end end
for y = 49, 53 do c:put(25, y, GLASS[4], gtok) end
c:put(41, 30, GLASS[4], gtok) c:put(41, 31, GLASS[4], gtok)
-- reflected cool light on the jam shade side
for y = 33, 52 do if y < 36 or y > 47 then c:put(bx1 - 1, y, "#9a4a6a", jtok) end end

-- quirk: jam drip escaping down the glass (right of label top)
local dtok = D.tok("drip")
local drip = D.stroke({ { 39, 24 }, { 40, 28 }, { 40, 31 } }, 0.7):add(D.ell(40.2, 32.6, 1.3, 1.6))
D.tone(c, drip, X.pillow(drip, 1.5), { JAM[2], JAM[3], JAM[4], JAM[5], JAM[6] }, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = dtok })
c:put(39, 32, "#fff0d8", dtok)

-- gingham cover: dome over the lid, cinched at the neck, frill flares over the shoulder
local ctok = D.tok("cloth")
local function cw(y)
  if y < 13 then return nil end
  if y <= 18 then return 9.2 + sqrt(max(0, 1 - ((18 - y) / 6) ^ 2)) * 1.6 - (y == 13 and 2.2 or 0) end
  if y <= 20 then return 9.4 end
  if y <= 26 then return 9.8 + (y - 20) * 0.75 end
  return nil
end
local cloth = D.rows(cx, 13, 26, cw)
-- scalloped hem: notch every 3 px on the last two rows
cloth:each(function(x, y)
  if y == 26 and (x % 3 == 0) then cloth.s[K(x, y)] = nil end
  if y == 25 and (x % 3 == 0) and (x < 22 or x > 41) then cloth.s[K(x, y)] = nil end
end)
local cn = X.pillow(cloth, 3)
-- frill bends outward: tilt normals by side
cloth:each(function(x, y) local k = K(x, y) if y >= 21 then
  local t = (x - cx) / 13
  cn[k] = { t * 0.8, 0.25, sqrt(max(0.05, 1 - t * t * 0.64 - 0.06)) } end end)
local v = X.light(cn, { amb = 0.1, wrap = 0.3 })
cloth:each(function(x, y) local k = K(x, y)
  local val = v[k]
  -- fold lines on the frill (soft vertical creases)
  if y >= 21 and ((x + floor((y - 21) * (x - cx) / 14)) % 5 == 0) then val = val - 0.18 end
  -- AO just under the cord
  if y == 21 then val = val - 0.15 end
  local i = 1
  for j, t in ipairs(D.CUT6) do if val >= t then i = j + 1 end end
  i = max(1, min(6, i))
  -- gingham: 3 px checks, red x red = red, cream x cream = cream, mixed = pink
  local a, b = (floor((x + 1) / 3) % 2 == 0), (floor((y + 1) / 3) % 2 == 0)
  local ramp = (a and b) and RED or (not a and not b) and CRM or PINK
  -- weave: alternate pixel darkened inside checks (diagonal twill)
  if (x + y) % 4 == 0 and i > 2 then i = i - 1 end
  c:put(x, y, ramp[i], ctok)
end)
-- AO on the glass right under the frill hem
body:each(function(x, y) if y == 27 or (y == 26 and not cloth:has(x, y)) then
  if not cloth:has(x, y) and not drip:has(x, y) then c:put(x, y, GLASS[1], gtok) end end end)
-- twisted twine cord at y 19-20 with a bow on the right
local ttok = D.tok("twine")
for x = 22, 41 do
  c:put(x, 19, TW[(x % 3 == 0) and 4 or (x % 3 == 1) and 3 or 2], ttok)
  c:put(x, 20, TW[(x % 3 == 0) and 2 or (x % 3 == 1) and 1 or 3], ttok)
end
-- bow loops + tails
local bow = D.ell(41, 18, 1.6, 1.3):add(D.ell(44, 19.6, 1.6, 1.2))
local bh = bow:copy():cut(c:rect(41, 19, 42, 20))
bh:each(function(x, y) c:put(x, y, TW[(x + y) % 2 == 0 and 3 or 2], ttok) end)
c:put(41, 18, TW[1], ttok) c:put(44, 20, TW[1], ttok)
c:put(42, 19, TW[4], ttok) c:put(42, 20, TW[2], ttok)
D.line(c, { { 42, 21 }, { 44, 24 }, { 44, 26 } }, nil, ttok, function(x, y) return TW[(y % 2 == 0) and 3 or 2] end)
D.line(c, { { 43, 21 }, { 46, 23 } }, nil, ttok, function(x, y) return TW[(x % 2 == 0) and 3 or 1] end)
-- one cream sparkle on the cloth dome
c:put(26, 14, CRM[6], ctok) c:put(27, 14, CRM[6], ctok)

D.save(c, NAME)
