-- tea-shrine (lean D3o_0)
local NAME = "tea-shrine"
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
local ST = { "#3a3441", "#595463", "#7d7a86", "#a19fa5", "#c4c0bf", "#e3ded6" }
local RF = { "#1c3a34", "#2c5a48", "#3f7a55", "#5c9a62", "#86bb74", "#b4d890" }
local FR = { "#8a3a14", "#c4621c", "#f09030", "#ffc050", "#ffe08a", "#fff0b8" }
local PC = { "#3f5a8a", "#6c8fc0", "#a4c4e0", "#d0e4f0", "#eef6fa", "#fbfeff" }
local MS = { "#24462a", "#3a6a34", "#5c9040", "#8cb85a" }
c:groundShadow(32, 58, 17, 3)
local function stone(m, R) local n, v = shade(m, ST, R, {amb=.1, wrap=.2})
  m:each(function(x, y) if X.hash(x, y, 5) > .92 then c:px(x, y, v[K(x,y)] > .5 and ST[5] or ST[2]) end end) return v end
-- base slab (two steps)
stone(c:rrect(15, 53, 49, 57, 1), 3)
stone(c:rrect(20, 49, 44, 53, 1), 3)
-- post
stone(c:rect(28, 40, 36, 49), 4)
for y = 41, 48 do c:px(31, y, ST[4]) end
c:fillMask(c:rect(26, 38, 38, 40), ST[3]) c:fillMask(c:rect(26, 40, 38, 40), ST[1])
-- lamp chamber with glowing window
local ch = c:rect(23, 27, 41, 38)
stone(ch, 5)
local win = c:rect(27, 30, 37, 36)
shade(win, FR, 4, {amb=.3, wrap=.5})
c:fillMask(c:rect(31, 30, 33, 36), FR[1])    -- cross bars
c:fillMask(c:rect(27, 33, 37, 33), FR[1])
c:px(28,31,FR[6]) c:px(29,31,FR[6])
-- roof: wide curved eaves with tile rows and a moss patch
local roof = c:poly{ {12,28}, {20,22}, {26,16}, {32,13}, {38,16}, {44,22}, {52,28} }
roof:cut(c:rect(0, 29, 63, 40))
local rn, rv = shade(roof, RF, 8, {amb=.1, wrap=.25})
roof:each(function(x, y) if (y % 3 == 0) and X.hash(x, y, 2) > .15 then c:px(x, y, rv[K(x,y)] > .55 and RF[3] or RF[1]) end end)
for x = 12, 52 do if roof:has(x, 28) then c:px(x, 28, RF[1]) end end
for _, p in ipairs{ {22,24},{23,24},{24,23},{23,25},{40,22},{41,23},{39,23} } do c:px(p[1], p[2], MS[4]) end
-- finial
shade(c:ellipse(32, 11, 2, 2), ST, 2, {amb=.3}) c:px(31,10,ST[6])
-- moss on lower slab
for _, p in ipairs{ {16,53},{17,53},{18,53},{16,54},{17,54},{21,49},{22,49} } do c:px(p[1], p[2], MS[(p[1]+p[2])%3+2]) end
-- teacup offering with steam (quirk)
local cup = c:rrect(40, 46, 46, 49, 1)
shade(cup, PC, 3, {amb=.25, wrap=.4})
c:px(47,47,PC[3]) c:px(47,48,PC[2]) c:px(41,46,PC[6])
for i, p in ipairs{ {43,44},{44,43},{43,42},{44,41},{43,40},{44,39} } do c:px(p[1], p[2], i < 5 and "#e6eef2" or "#c8d6dc") end
G.save(c, NAME)
