-- coriander-chutney (final pass, Opus single pass). A slim, tall glass jar of bright green coriander chutney:
-- cylinder-lit glass with a pale rim, two vertical glints and a cool teal reflected edge; the chutney inside is a
-- 6-tone green with herb flecks, red chili and cream coconut bits, a headspace with a meniscus line under the neck.
-- A gingham cloth cover (diagonal weave, scalloped hem) is tied over the lid with twisted twine and a bow tail.
-- Ground shadow under the jar, AO under the cloth hem and twine.
-- quirk: a fat drip of chutney has escaped under the cloth and runs down the outside of the glass.
local NAME = "coriander-chutney"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GRN   = { "#173d2a", "#1f5a2e", "#2f7a32", "#4f9c36", "#7cbd45", "#b0dc6a" }
local GLASS = { "#3f6a78", "#5f8e98", "#8db6b8", "#bcd9d2", "#e0efe6", "#f6fbf2" }
local CLOTH = { "#5e1a2c", "#8e2a34", "#bc3d3c", "#de5f4c", "#f08a6a", "#fbb894" }
local CREAMC= { "#9a8a86", "#c2b4a6", "#e0d4c0", "#f2e8d4", "#fbf4e4" }
local TW    = { "#6a4a2c", "#9a7244", "#c8a066", "#e6c88e" }
local CHILI, COCO, HERB = "#d8402e", "#f4ead2", "#a8d860"
local gtok, ctok, ttok = { r = { name = "glass" } }, { r = { name = "cloth" } }, { r = { name = "twine" } }

-- ground shadow (2 tone, 3 px)
c:groundShadow(32, 56, 13, 1.6)

-- jar body: rounded slim cylinder 20 wide, shoulder into a neck
local X0, X1, Y0, Y1 = 22, 42, 25, 55
local body = c:rrect(X0, Y0, X1, Y1, 5)
local neck = c:rect(25, 21, 39, 25)
local jar = body:copy():add(neck)
-- cylinder normal across x
local n = {}
jar:each(function(x, y)
  local t = max(-0.96, min(0.96, ((x - X0) / (X1 - X0)) * 2 - 1))
  local ty = 0
  if y > Y1 - 3 then ty = (y - (Y1 - 3)) * 0.22 end          -- rounded foot
  n[K(x, y)] = { A.norm(t, ty, sqrt(1 - t * t) + 0.05) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
-- chutney fill: inside the glass wall (1 px wall), below the meniscus
local inner = body:copy():shrink(1)
local fill = HP.mask()
inner:each(function(x, y) if y >= 35 + floor(abs(x - 32) * 0.08) and y <= Y1 - 2 then fill:set(x, y) end end)
local wall = jar:copy():cut(fill)
-- glass (empty headspace + wall)
local gb = {}
X.ao(gb, wall, c:rect(20, 18, 44, 20), 2, -1)
X.tone(c, wall, v, GLASS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = gtok, bias = gb })
-- chutney, darker than the light hitting the glass (seen through it); AO under the meniscus
local fb = {}
fill:each(function(x, y) local k = K(x, y) fb[k] = (y <= 36) and -1 or 0 end)
local fidx = X.tone(c, fill, v, GRN, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = gtok, bias = fb })
-- texture: herb flecks, chili and coconut bits
fill:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if y > 37 and y < Y1 - 2 then
    if h > 0.955 then c:put(x, y, CHILI, gtok)
    elseif h > 0.925 then c:put(x, y, COCO, gtok)
    elseif h > 0.82 then c:put(x, y, (fidx[k] or 3) >= 4 and HERB or GRN[min(6, (fidx[k] or 3) + 1)], gtok)
    elseif h < 0.08 then c:put(x, y, GRN[max(1, (fidx[k] or 3) - 1)], gtok) end
  end
end)
-- meniscus: pale lip on the lit side, dark on the shade side
for x = X0 + 1, X1 - 1 do local y = 35 + floor(abs(x - 32) * 0.08)
  if fill:has(x, y) then c:put(x, y, x < 33 and GRN[6] or GRN[4], gtok) end end
-- glass: pale rim on the lit edge, cool teal reflected edge, two vertical glints, bottom thickness
for y = Y0 + 2, Y1 - 3 do c:put(X0, y, GLASS[4], gtok) c:put(X1, y, GLASS[2], gtok) end
for y = Y0 + 6, Y1 - 4 do c:put(X1 - 1, y, "#4f8f94", gtok) end
for y = 31, 48 do c:put(25, y, GLASS[6], gtok) end
for y = 33, 38 do c:put(27, y, GLASS[5], gtok) end
c:put(25, 51, GLASS[5], gtok) c:put(25, 30, GLASS[5], gtok)
for x = X0 + 3, X1 - 3 do c:put(x, Y1 - 1, x < 30 and GLASS[4] or GLASS[3], gtok) end
for x = X0 + 4, X1 - 5 do c:put(x, Y1 - 2, GLASS[2], gtok) end
-- shoulder line (glass curving into the neck)
for x = X0 + 2, X1 - 2 do c:put(x, Y0, x < 31 and GLASS[5] or GLASS[3], gtok) end

-- cloth cover: dome over the lid with a scalloped hem
local cloth = HP.mask()
for y = 12, 25 do for x = 18, 46 do
  local cx, top = 32, 12
  local hw
  if y < 17 then hw = 9.5 * sqrt(max(0, (y - top + 0.6) / 5.2)) else hw = 9.5 + (y - 17) * 0.62 end
  local hem = 23 + ((x % 4 < 2) and 1 or 0) + floor(abs(x - 32) * 0.08)
  if abs(x + 0.5 - cx - 0.5) <= hw and y <= hem then cloth:set(x, y) end
end end
local cn = X.pillow(cloth, 3.5)
local cv = X.light(cn, { amb = 0.1, wrap = 0.25 })
-- ripple folds: hanging vertical pleats below the twine
local cb = {}
cloth:each(function(x, y) local k = K(x, y)
  if y > 19 then local ph = (x - 18) % 5 if ph == 0 then cb[k] = -1 elseif ph == 2 then cb[k] = 1 end end
end)
-- gingham: alternate checks of red and cream
local red, crm = HP.mask(), HP.mask()
cloth:each(function(x, y)
  local a, b = floor((x - 18) / 3) % 2, floor((y - 12) / 3) % 2
  if a == 1 and b == 1 then crm:set(x, y) else red:set(x, y) end
end)
X.tone(c, red, cv, CLOTH, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ctok, bias = cb })
X.tone(c, crm, cv, CREAMC, { cuts = { 0.25, 0.45, 0.65, 0.84 }, tok = ctok, bias = cb })
-- weave: diagonal 1px dark threads on the cloth
cloth:each(function(x, y) if (x + y) % 6 == 0 and X.hash(x, y, 3) > 0.35 and y < 23 then
  local cur = c:get(x, y) if cur and red:has(x, y) then c:put(x, y, CLOTH[2], ctok) end end end)
-- AO: one dark row of glass under the hem
cloth:each(function(x, y) if not cloth:has(x, y + 1) and jar:has(x, y + 1) then c:put(x, y + 1, GLASS[1], gtok) end end)
-- twine wrapped at y 19-20 with a twist pattern, knot + bow tail on the right
for x = 20, 44 do if cloth:has(x, 19) then
  c:put(x, 19, TW[(x % 2 == 0) and 4 or 3], ttok)
  c:put(x, 20, TW[(x % 2 == 0) and 2 or 1], ttok)
end end
c:put(41, 18, TW[3], ttok) c:put(42, 18, TW[4], ttok) c:put(42, 19, TW[2], ttok)
A.line(c, { { 43, 20 }, { 45, 22 }, { 46, 25 } }, TW[2], ttok)
A.line(c, { { 43, 20 }, { 47, 21 }, { 48, 23 } }, TW[3], ttok)
c:put(46, 26, TW[4], ttok) c:put(48, 24, TW[4], ttok)
-- cloth highlight: one 2x1 hi on the crown
c:put(27, 14, CREAMC[5], ctok) c:put(28, 14, CREAMC[5], ctok)

-- quirk: drip running down the glass from under the hem (lit left bead + dark right)
local drip = HP.mask()
for _, p in ipairs{ {30,25},{30,26},{31,26},{30,27},{30,28},{31,27},{30,29},{30,30},{29,31},{30,31},{31,31},{29,32},{30,32},{31,32},{30,33} } do drip:set(p[1], p[2]) end
drip:each(function(x, y) c:put(x, y, (x == 29 or (x == 30 and y < 31)) and GRN[5] or GRN[3], gtok) end)
c:put(31, 33, GRN[2], gtok) c:put(30, 34, GRN[2], gtok)
c:put(29, 31, GRN[6], gtok)   -- glint on the bead

A.save(c, NAME)
