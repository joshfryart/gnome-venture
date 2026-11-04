-- ico-gnome-hat (final, Opus). The hat alone, standing on its brim: a tall red felt cone that rises, leans and then
-- flops over to the LEFT, ending in a cream wool pompom; a thick rolled cuff at the base; 2-tone ground shadow.
-- Material: per-pixel cylinder light along the curved cone (6-tone red, cool-violet shade side, warm lit side),
-- compression wrinkles on the inside of the bend (dark groove + lit lip), soft felt nap (sparse tone steps), a rolled
-- cuff lit on its top lip and dark beneath, gold stitch on the cuff hem, AO where the cone tucks into the cuff and
-- where the pompom meets the tip; the pompom is tufted (scattered dark tufts, a bright tuft).
-- quirk: a mouse is hiding under the brim; only its pink tail curls out on the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("ico-gnome-hat")
local RED  = { "#4e1630", "#82203a", "#b52e3f", "#e0443c", "#f9714f", "#ffa676" }
local CUFF = { "#2e0e22", "#521630", "#7a2038", "#a02c3e", "#c84448", "#ea7458" }
local WOOL = { "#6a6078", "#958aa0", "#c2b8c4", "#e2dbd8", "#f4efe4", "#fff8ea" }
local ctok, btok, ptok = A.tok("felt"), A.tok("cuff"), A.tok("wool")

c:groundShadow(32, 53, 19, 2)

-- cone along a cubic bezier: base centre -> up -> flops left
local p = { { 32, 47 }, { 33.5, 24 }, { 30, 9 }, { 15, 17 } }
local function hw(t) return 12 * (1 - t) ^ 1.2 + 1.3 end
local cm, cn, CT, CS, samp = A.tube(p, hw)
cm:cut(HP.rect(0, 46, 63, 63))   -- the base sits inside the cuff
-- felt nap: tiny normal jitter so the light breaks up very slightly
local v = A.val(cn, { amb = 0.07, wrap = 0.28 })
for k, val in pairs(v) do local x, y = k % 1024 - 256, k // 1024 - 256
  v[k] = val + (X.hash(x, y, 9) - 0.5) * 0.06 end
local bias = {}
local cidx = X.tone(c, cm, v, RED, { cuts = { 0.17, 0.33, 0.5, 0.66, 0.84 }, tok = ctok, bias = bias })
-- compression wrinkles on the inner (lower-left) side of the bend: short arcs across the cone
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
local wr = { { 0.52, -0.95, 0.15 }, { 0.6, -0.9, 0.35 }, { 0.68, -0.9, 0.2 }, { 0.42, -0.2, 0.55 } }
cm:each(function(x, y) local k = K(x, y)
  local t, s = CT[k], CS[k]
  for _, w in ipairs(wr) do
    if s > w[2] and s < w[3] then
      local d = (t - w[1]) * LEN + s * s * 1.2
      if d > -0.5 and d < 0.5 then A.step(c, cidx, RED, x, y, -2, ctok)
      elseif d >= -1.5 and d <= -0.5 then A.step(c, cidx, RED, x, y, 1, ctok) end
    end
  end
end)
-- cool reflected light on the lower-right edge of the upright part
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.75 and CT[k] < 0.35 and CT[k] > 0.08 then c:put(x, y, "#8a4a7a", ctok) end end)
-- specular: 2x1 hi + cream glint on the lit shoulder
c:put(24, 30, RED[6], ctok) c:put(25, 30, RED[6], ctok) c:put(25, 29, RED[6], ctok) c:put(24, 31, "#fff4d6", ctok)

-- rolled cuff (in front of the cone base)
local cuff = A.ell(32, 45.5, 16.5, 5.2)
local un = {}
cuff:each(function(x, y)
  local s = (y - 45.5) / 5.1
  local u = (x - 32) / 17
  un[K(x, y)] = { u * 0.8, s, sqrt(max(0.05, 1 - s * s - u * u * 0.3)) }
end)
for k, n in pairs(un) do local l = sqrt(n[1]^2 + n[2]^2 + n[3]^2) un[k] = { n[1]/l, n[2]/l, n[3]/l } end
local uidx = A.shade(c, cuff, un, CUFF, { tok = btok, amb = 0.1, wrap = 0.3, cuts = { 0.24, 0.42, 0.6, 0.76, 0.92 } })
-- inner separation: 1 px deep line on the cone where it meets the cuff
A.touch(cm:copy():cut(cuff), cuff):each(function(x, y) c:put(x, y, RED[1], ctok) cidx[K(x, y)] = 1 end)
-- AO: the cone darkens where it tucks into the cuff
for x = 14, 50 do for y = 38, 39 do if cidx[K(x, y)] and cidx[K(x, y)] > 1 then A.step(c, cidx, RED, x, y, y == 39 and -1 or 0, ctok) end end end
-- cuff top lip highlight + felt fold dents along the roll
cuff:each(function(x, y)
  if not cuff:has(x, y - 1) and x % 7 ~= 3 then A.step(c, uidx, CUFF, x, y, 1, btok) end
  if x % 7 == 3 and (not cuff:has(x, y - 1) or not cuff:has(x, y - 2)) then A.step(c, uidx, CUFF, x, y, -1, btok) end
  if not cuff:has(x, y + 1) then A.step(c, uidx, CUFF, x, y, -1, btok) end
end)
c:stitch{ { 19, 48 }, { 23, 49 }, { 41, 49 }, { 45, 48 } }

-- pompom at the tip: tufted wool ball
local PX, PY = 13.5, 19.5
local pm = A.ell(PX, PY, 4, 4)
local pn = X.sphere(PX, PY, 4.4, pm)
local pidx = A.shade(c, pm, pn, WOOL, { tok = ptok, amb = 0.12, wrap = 0.35 })
for _, q in ipairs{ { 12, 18 }, { 15, 20 }, { 11, 21 }, { 14, 23 }, { 16, 18 } } do A.step(c, pidx, WOOL, q[1], q[2], -1, ptok) end
c:put(11, 17, WOOL[6], ptok) c:put(12, 16, WOOL[6], ptok)
-- AO on the felt next to the pompom
A.touch(cm:copy():cut(pm), pm):each(function(x, y) A.step(c, cidx, RED, x, y, -1, ctok) end)

-- quirk: mouse tail curling out from under the brim (right)
local TL = { a = "#f5a0b4", b = "#c96a88" }
A.map(c, {
  "....ab.",
  "...a..b",
  "..a...b",
  "aab..b.",
  ".bbbb..",
}, 46, 46, TL, A.tok("tail"))
A.save(c, "ico-gnome-hat")
