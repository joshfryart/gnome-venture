-- tangor (lean D3o_0)
local NAME = "tangor"
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
local OR = { "#6d2310", "#a93f12", "#d9651a", "#f29a2b", "#ffc357", "#ffe8a0" }
local FL = { "#b4501a", "#e0801f", "#f8a82c", "#ffc84a", "#ffdf7a", "#fff0b0" }
local LF = { "#14352f", "#1f5240", "#2e7448", "#46944f", "#6db55a", "#a0d070" }
local WD = { "#4a2f1e", "#6d4a2a", "#8f6a3a", "#b8905a" }
c:groundShadow(30, 55, 15, 3)
-- fruit: wide oblate body with the tangor's bumpy shoulder knob
local fruit = c:ellipse(29, 39, 15, 13):add(c:ellipse(29, 28, 7, 3))
local n, v = shade(fruit, OR, 13, {amb=.06, wrap=.2})
-- peel pores
fruit:each(function(x, y) local h = X.hash(x, y, 7)
  if h > .86 then c:px(x, y, v[K(x,y)] > .55 and OR[5] or OR[2]) end end)
-- warm bounce lower-right, spec upper-left
fruit:edge():each(function(x, y) if x > 33 and y > 44 then c:px(x, y, OR[4]) end end)
c:px(21,33,OR[6]) c:px(22,33,OR[6]) c:px(20,34,OR[6]) c:px(21,34,OR[5]) c:px(23,32,OR[6])
-- navel dimple and stem
c:fillMask(c:rect(28,26,30,27), OR[1]) c:px(29,27,OR[2])
local sm, sn = G.tube({ {29,27}, {29,24}, {30,21}, {31,18} }, function(t) return 1.5 - 0.5*t end)
toneN(sm, sn, WD, {cuts={.3,.55,.8}})
-- leaves
leaf(31,21, 38,11, 49,12, 4.2, LF, 2.2, true)
leaf(29,22, 22,14, 15,17, 3.4, LF, 2.2, true)
-- loose segment (quirk) lying lower right
local seg = c:ellipse(52, 50, 6, 5):cut(c:rect(40, 40, 58, 47))
local sn2, sv = shade(seg, FL, 5, {amb=.15, wrap=.3})
for x = 47, 57 do for y = 47, 55 do if seg:has(x,y) and (x == 52 or (y - 47) == floor((x-47)*0.0) ) then end end end
for y = 48, 53 do c:px(52, y, FL[1]) end
c:px(49,50,FL[6]) c:px(50,49,FL[6]) c:px(55,52,FL[2])
G.save(c, NAME)
