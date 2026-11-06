-- taro (lean D3o_0)
local NAME = "taro"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
G.line = G.line or function(cc, pts, hex) cc:line(pts, 1):each(function(x, y) cc:px(x, y, hex) end) end
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function bez(p, t) local u = 1 - t
  return u^3*p[1][1]+3*u*u*t*p[2][1]+3*u*t*t*p[3][1]+t^3*p[4][1], u^3*p[1][2]+3*u*u*t*p[2][2]+3*u*t*t*p[3][2]+t^3*p[4][2] end
local CUTS = { .22, .4, .56, .72, .86 }
local function toneN(m, n, ramp, o) o = o or {}
  local v = X.light(n, { amb = o.amb or .1, wrap = o.wrap or .25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, tok = { r = { name = o.name or "p" } } }) return v end
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return n, toneN(m, n, ramp, o) end
local function leaf(ax,ay,cx,cy,bx,by,w,ramp,ser, vein)
  local L = sqrt((bx-ax)^2+(by-ay)^2)
  local m, n, T, S = G.blade(ax,ay,cx,cy,bx,by,function(t) return max(0.5, w*sin(pi*min(1,t*0.95+0.03))^0.7 + (ser and 0.4*sin(t*L*ser) or 0)) end)
  toneN(m, n, ramp, {amb=.12, wrap=.3, name="leaf"})
  m:each(function(x,y) local k=K(x,y) local s,t=S[k],T[k]
    if abs(s) < 0.16 and t > 0.08 and t < 0.92 then c:px(x,y, s<=0 and ramp[5] or ramp[2]) end
    if vein and t>0.2 and t<0.85 and abs(s)>0.3 and abs(s)<0.8 then
      local d=(t*L*0.5 - abs(s)*1.6) % 1.6 if d<0.4 then c:px(x,y, s<=0 and ramp[5] or ramp[2]) end end end)
  return m end
local BR = { "#2f1d1b", "#523226", "#7a4e34", "#a37548", "#c9a06a", "#e8cc96" }
local PK = { "#5a2a55", "#8a3f78", "#b4639a", "#d68fb8", "#ecb8d2", "#fbe0e8" }
local LF = { "#16393a", "#1f5648", "#2d7650", "#44985c", "#6cba68", "#a6d884" }
local ST = { "#2a5a45", "#3f7e55", "#6aa664", "#a0cc80" }
c:groundShadow(32, 58, 17, 3)
-- cormels
for _, e in ipairs{ {16, 53, 4, 3}, {49, 54, 4, 3} } do
  local m = c:ellipse(e[1], e[2], e[3], e[4]) shade(m, BR, 4, {amb=.1})
  c:px(e[1]-1, e[2]-1, BR[6]) end
-- big corm with ring bands and hair
local corm = c:ellipse(32, 50, 13, 8)
local n, v = shade(corm, BR, 9, {amb=.07, wrap=.2})
corm:each(function(x, y)
  local r = (y + floor(abs(x-32)*0.25)) % 4
  if r == 0 and X.hash(x, y, 3) > .22 then c:px(x, y, v[K(x,y)] > .6 and BR[3] or BR[1]) end
  if X.hash(x, y, 9) > .93 then c:px(x, y, BR[6]) end end)
-- pink cut crown where the stalk leaves
local crown = c:ellipse(32, 44, 5, 2) shade(crown, PK, 3, {amb=.2, wrap=.4})
c:px(30,43,PK[6]) c:px(31,43,PK[5])
-- stalk
local sm, sn = G.tube({ {32,44}, {32,38}, {33,30}, {32,22} }, function(t) return 1.6 end)
toneN(sm, sn, ST, {cuts={.3,.55,.8}})
-- heart leaf (elephant ear), tip up, lobes down, notch at the stalk
local leaf = c:ellipse(25, 18, 9, 8):add(c:ellipse(39, 18, 9, 8)):add(c:poly{ {17,21}, {47,21}, {32,6} })
leaf:cut(c:poly{ {32,21}, {29,29}, {35,29} })
local ln = X.pillow(leaf, 7)
local lv = toneN(leaf, ln, LF, {amb=.1, wrap=.3, name="leaf"})
-- veins radiating from the peltate join
for _, p in ipairs{ {{32,22},{32,8}}, {{32,22},{22,17}}, {{32,22},{42,17}}, {{32,22},{20,24}}, {{32,22},{44,24}}, {{32,22},{26,12}}, {{32,22},{38,12}} } do
  c:line(p, 1):each(function(x, y) if leaf:has(x, y) then c:px(x, y, x <= 32 and LF[5] or LF[2]) end end) end
c:px(32,22,LF[1]) c:px(32,21,LF[1])
-- dew bead (quirk)
c:fillMask(c:rect(37,12,38,13), "#bfe8f0") c:px(37,12,"#f6fdff") c:px(38,14,LF[1]) c:px(39,14,LF[1])
G.save(c, NAME)
