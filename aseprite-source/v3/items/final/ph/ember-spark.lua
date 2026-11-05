-- ember-spark (lean E2_00)
local NAME = "ember-spark"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, tok, amb, wrap)
  local n = X.pillow(m, R)
  return X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n
end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t) local r1,g1,b1 = hx(a) local r2,g2,b2 = hx(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5)) end
local function ramp6(base) return { mix(base,"#1c1020",.62), mix(base,"#2a1428",.36), mix(base,"#2a1428",.14), base, mix(base,"#fff2b0",.3), mix(base,"#fff8e0",.6) } end
c:groundShadow(32, 56, 19, 3)
local lump = c:poly{{14,52},{12,40},{19,31},{29,27},{40,29},{50,35},{53,46},{46,55},{30,57}}
local CH = { "#17101a", "#2a1d28", "#3f2c36", "#5b4148", "#7c5c5a", "#a08074" }
local tok = { r = { name = "coal" } }
local idx = shade(lump, CH, 11, tok, 0.05, 0.15)
lump:each(function(x, y) local k = K(x, y) if X.hash(x, y, 5) > 0.86 and idx[k] >= 2 then c:put(x, y, CH[idx[k] - 1], tok) end end)
local cracks = { {{32,56},{30,47},{35,41},{33,33}}, {{30,47},{22,43},{17,36}}, {{35,41},{44,43},{49,48}}, {{44,43},{45,35}}, {{26,52},{20,50}} }
local cm = HP.mask()
local glow = HP.mask()
for _, pl in ipairs(cracks) do local lm = c:line(pl, 1) cm:add(lm) glow:add(lm:copy():grow(1)) end
local ct = { r = { name = "crack" } }
glow:each(function(x, y) if lump:has(x, y) then c:put(x, y, "#8a2a24", ct) end end)
cm:each(function(x, y) if lump:has(x, y) then c:put(x, y, "#ff7a1c", ct) if (x + y) % 2 == 0 then c:put(x, y, "#ffd25a", ct) end end end)
-- flame
local fl = c:poly{{32,31},{25,26},{26,19},{30,13},{30,9},{34,5},{35,12},{39,18},{40,25},{37,30}}
local FT = { r = { name = "flame" } }
fl:each(function(x, y) local col = y > 24 and "#e03a1c" or (y > 16 and "#ff7a1c" or "#ffb030") c:put(x, y, col, FT) end)
fl:copy():shrink(2):each(function(x, y) c:put(x, y, y > 20 and "#ffd25a" or "#ffe890", FT) end)
fl:copy():shrink(3):each(function(x, y) if y > 18 then c:put(x, y, "#fff6c8", FT) end end)
-- quirk: a four-point spark drifting off
local sp = { r = { name = "spark" } }
for _, p in ipairs{ {51,12},{51,10},{51,9},{51,14},{51,15},{49,12},{48,12},{53,12},{54,12} } do c:put(p[1], p[2], "#ff9a2c", sp) end
c:put(51, 11, "#ffe890", sp) c:put(51, 13, "#ffe890", sp) c:put(50, 12, "#ffe890", sp) c:put(52, 12, "#ffe890", sp) c:put(51, 12, "#fff6c8", sp)
c:put(15, 22, "#ffb030", sp) c:put(14, 23, "#ff7a1c", sp) c:put(57, 26, "#ffb030", sp)
G.save(c, NAME)
