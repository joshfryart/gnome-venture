-- spider-silk (lean E2_08)
local NAME = "spider-silk"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function blob(m, ramp, name, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local tok = { r = { name = name } }
  return X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n, tok
end
local function put(x, y, col, name) c:put(floor(x + .5), floor(y + .5), col, { r = { name = name or "d" } }) end
local function dots(m, col, name) m:each(function(x, y) c:put(x, y, col, { r = { name = name or "d" } }) end) end

local WOOD = { "#3a2218", "#5e3a26", "#82522f", "#a8703c", "#c8924e", "#e6b878" }
local SILK = { "#6f7a9a", "#98a4c0", "#bcc8de", "#d9e2ee", "#eef3f8", "#fafcff" }
c:groundShadow(32, 56, 17, 3)
local bot = c:rrect(16, 47, 47, 53, 2)
blob(bot, WOOD, "flangeB", 3)
local core = c:rrect(21, 17, 42, 47, 1)
local _, n, tok = blob(core, SILK, "thread", 11, { wrap = 0.3 })
-- winding: diagonal darker grooves + light crests
core:each(function(x, y)
  local d = (x + y) % 4
  if d == 0 then c:put(x, y, SILK[2], tok) elseif d == 2 and x < 33 then c:put(x, y, SILK[5], tok) end
end)
-- AO under top flange / over bottom flange
for x = 21, 42 do put(x, 18, SILK[1], "ao") put(x, 46, SILK[1], "ao") end
local top = c:rrect(16, 10, 47, 16, 2)
blob(top, WOOD, "flangeT", 3)
for x = 19, 44 do if x % 3 == 0 then put(x, 12, WOOD[5], "grain") end end
-- loose strand drooping from the spool, spider on the end
local strand = c:line({ {41,30}, {46,31}, {50,36}, {50,42}, {49,46} }, 1)
dots(strand, SILK[4], "strand")
put(46,31,SILK[6]) put(50,38,SILK[6])
-- spider (quirk): tiny, big readable legs
local sp = c:ellipse(49, 50, 2, 2)
blob(sp, { "#1a1020", "#2e1c3a", "#46285a", "#5e3a78", "#7a4f96", "#a67cc4" }, "spider", 2)
for _, l in ipairs{ {45,48},{44,50},{45,53},{54,48},{55,50},{54,53},{46,47},{53,47} } do put(l[1], l[2], "#2e1c3a", "leg") end
put(48,49,"#ff5a6a","eye") put(50,49,"#ff5a6a","eye")
c:sparkle(27, 24)
G.save(c, NAME)
