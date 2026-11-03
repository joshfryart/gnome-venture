-- ico-test-tube (final, Opus). A slim glass test tube, slightly tilted, with a flared lip, a cork stopper and a
-- bright pink potion filling the lower half.
-- Material: glass (bright left rim streak, pale core, darker walls, cool shade edge), per-pixel cylinder light on the
-- potion (6 tones) with a lit meniscus line, rising bubbles with a glint, the glass reflection streak carried over
-- the liquid; cork with pores and a pale end grain, ambient dark where the cork enters the neck.
-- quirk: a hand-written paper tag with a "?" hangs from the neck on a string.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_1.lua")
local HP, X, K = R.HP, R.X, R.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = R.new("ico-test-tube")
local GL   = { "#4c5c8e", "#7e98c4", "#b0cce4", "#d6eaf2", "#eef8f6" }
local PINK = { "#5a1a4e", "#8e2a6a", "#c2448a", "#ea6aa4", "#ff9cc0", "#ffd2e0" }
local CORK = { "#5e2e22", "#94502e", "#c27a3e", "#e0a35a", "#f6cc86" }
local PAPER = { "#9a7a64", "#d2b490", "#efdcb8", "#fbf0d4" }

-- tube body
local TX, TY, BX, BY = 25, 14, 38, 53
local LEN = sqrt((BX - TX)^2 + (BY - TY)^2)
local HW = 6
local t0 = 1 - HW / LEN
local function hw(t)
  if t < 0.05 then return HW + 1.4 end
  if t > t0 then local q = (t - t0) / (1 - t0) return HW * sqrt(max(0, 1 - q*q)) + 0.2 end
  return HW
end
local tm, tn, TT, TS = R.tube({ { TX, TY }, { TX + (BX - TX) / 3, TY + (BY - TY) / 3 }, { TX + 2 * (BX - TX) / 3, TY + 2 * (BY - TY) / 3 }, { BX, BY } }, hw, 200)
local gtok = { r = { name = "glass" } }
local LIQ = 0.44
local ux, uy = (BX - TX) / LEN, (BY - TY) / LEN
local v = X.light(tn, { amb = 0.1, wrap = 0.3 })
local liq = HP.mask()
tm:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  local surf = LIQ + (s * s) * 0.03 - 0.015             -- meniscus dips in the middle (concave)
  if t >= surf and hw(t) > 0.5 then liq:set(x, y) end
end)
local lidx = X.tone(c, liq, v, PINK, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, tok = gtok })
-- empty glass: pale core, darker walls, bright rim on the left
tm:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  if not liq:has(x, y) then
    local col = GL[4]
    if s > 0.55 then col = GL[3] end
    if s > 0.8 then col = GL[2] end
    if s < -0.8 then col = GL[3] end
    if t < 0.05 then col = s < 0 and GL[5] or GL[2] end            -- lip
    c:put(x, y, col, gtok)
  else
    if abs(s) > 0.86 then c:put(x, y, s < 0 and PINK[5] or PINK[1], gtok) end   -- glass wall over the potion
  end
  if s > -0.7 and s < -0.42 and t > 0.08 and t < 0.92 then
    c:put(x, y, (liq:has(x, y)) and PINK[6] or GL[5], gtok)                    -- reflection streak
  end
end)
-- meniscus line (lit)
liq:each(function(x, y) if not liq:has(x - floor(ux + .5), y - floor(uy + .5)) or not liq:has(x, y - 1) then
  local s = TS[K(x, y)] if abs(s) < 0.86 then c:put(x, y, s < 0.3 and PINK[6] or PINK[5], gtok) end end end)
-- ambient: darker potion on the far bottom
liq:each(function(x, y) local k = K(x, y) if TT[k] > 0.93 and TS[k] > 0 then R.step(c, lidx, PINK, x, y, -1, gtok) end end)
-- bubbles
local function bubble(t, s, r)
  local w = hw(t)
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local cx, cy = TX + ux * t * LEN + px * s * w, TY + uy * t * LEN + py * s * w
  local m = c:ellipse(floor(cx + .5), floor(cy + .5), r, r)
  local inner = m:shrink(1)
  m:each(function(x, y) c:put(x, y, inner:has(x, y) and PINK[4] or PINK[6], gtok) end)
  local bx, by = m:bbox()
  c:put(bx + (r > 1 and 1 or 0), by + (r > 1 and 1 or 0), "#fff0f4", gtok)
end
bubble(0.66, 0.1, 2) bubble(0.83, -0.15, 1)
-- specular glint on the glass shoulder
do local x, y = floor(TX + ux * 0.14 * LEN - 3.2 + .5), floor(TY + uy * 0.14 * LEN + 1 + .5)
  c:put(x, y, R.CREAM, gtok) c:put(x, y + 1, R.CREAM, gtok) end

-- cork stopper (tapered, sits in the neck, top proud of the lip)
local cm, cn, CT, CS = X.cyl(TX - ux * 6, TY - uy * 6, TX + ux * 2.5, TY + uy * 2.5, function(t) return 4.7 - t * 0.9 end)
local cbias = {}
cm:each(function(x, y) local k = K(x, y)
  if CT[k] > 0.78 then cbias[k] = -2 end                                  -- ambient where it enters the neck
  if X.hash(x, y, 3) > 0.88 and CT[k] < 0.7 then cbias[k] = (cbias[k] or 0) - 1 end        -- pores
end)
local cidx, _, ctok = R.shade(c, cm, cn, CORK, { amb = 0.1, bias = cbias, cuts = { 0.2, 0.4, 0.6, 0.8 } })
-- pale end grain on the top face
local top = R.rell(TX - ux * 6.6, TY - uy * 6.6, ux, uy, 0.9, 4.2)
top:each(function(x, y) if cm:has(x, y) then c:put(x, y, (x + 2 * y) % 4 == 0 and CORK[3] or CORK[5], ctok) end end)
-- ring of shadow on the glass right under the cork
tm:each(function(x, y) if cm:has(x - floor(ux + .5), y - floor(uy + .5)) and not cm:has(x, y) and TT[K(x, y)] < 0.2 then c:put(x, y, GL[2], gtok) end end)

-- quirk: paper tag with a "?" on a string from the neck
local sx, sy = floor(TX - 7 + .5), TY + 4
for i = 0, 5 do c:put(sx - i, sy + i + (i > 2 and 1 or 0), i % 2 == 0 and "#c94f84" or "#7d2c5e") end
local tag = c:poly{ { 9, 23 }, { 17, 21 }, { 19, 30 }, { 11, 32 } }
local tn2 = {}
tag:each(function(x, y) tn2[K(x, y)] = { R.norm(-0.2, -0.25, 1) } end)
local tb = {}
tag:each(function(x, y) if not tag:has(x + 1, y) or not tag:has(x, y + 1) then tb[K(x, y)] = -1 end end)
R.shade(c, tag, tn2, PAPER, { amb = 0.3, bias = tb, cuts = { 0.2, 0.45, 0.75 } })
c:put(15, 23, PAPER[1])                                                     -- string hole
for _, p in ipairs{ { 13, 24 }, { 14, 24 }, { 12, 25 }, { 15, 25 }, { 14, 26 }, { 13, 27 }, { 13, 29 } } do c:put(p[1], p[2], "#5a3a4a") end
R.save(c, "ico-test-tube")
