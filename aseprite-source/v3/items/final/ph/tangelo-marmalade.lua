-- tangelo-marmalade (lean D3o_0)
local NAME = "tangelo-marmalade"
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
local M  = { "#6e2410", "#a53c14", "#d9661a", "#f39a2c", "#ffc450", "#ffe590" }
local GL = { "#4f6a8a", "#7fa2c0", "#aecfe0", "#d6eef2", "#effafa", "#fbfeff" }
local CL = { "#7a1f2c", "#a8323a", "#cf4a48", "#e8756a", "#f4a58e", "#fbd2bb" }
local CR = { "#8c7a72", "#b8a79a", "#d9ccba", "#efe5d0", "#faf3e2", "#fffaee" }
local PP = { "#7a5a3a", "#a07c4c", "#c8a468", "#e2c88a", "#f2dfa8", "#fff0c8" }
c:groundShadow(32, 56, 15, 3)
-- jar body (marmalade seen through glass)
local body = c:rrect(17, 27, 46, 54, 6)
local n, v = shade(body, M, 11, {amb=.08, wrap=.3})
-- peel strips suspended in the jelly
for _, s in ipairs{ {34,31,5}, {26,34,4}, {38,42,5}, {22,45,4}, {30,50,5} } do
  for i = 0, s[3]-1 do local x, y = s[1]+i, s[2]+ floor(sin(i*0.9)*1.1+0.5)
    if body:has(x,y) then c:px(x, y, M[6]) if body:has(x,y+1) then c:px(x,y+1,M[2]) end end end end
-- glass shell: darker blue rim edge on right, bright left streak
body:copy():shrink(1):each(function(x,y) end)
for y = 31, 50 do c:px(20, y, GL[5]) end
c:px(20, 30, GL[4]) c:px(20, 51, GL[3]) c:px(21, 33, GL[6]) c:px(21, 34, GL[6])
for y = 33, 49 do c:px(44, y, GL[2]) end
-- bottom caustic
for x = 24, 40 do if x % 3 ~= 0 then c:px(x, 52, M[5]) end end
-- glass neck
local neck = c:rect(20, 23, 43, 27)
shade(neck, GL, 6, {amb=.2})
-- gingham cloth cap
local cap = HP.mask()
for y = 12, 23 do
  local flare = (y - 12) * 0.28
  for x = floor(22 - flare), floor(42 + flare) do cap:set(x, y) end end
for x = 19, 44 do if x % 4 < 3 then cap:set(x, 24) end end
local cn = X.pillow(cap, 5)
local cv = X.light(cn, { amb = .15, wrap = .3 })
local ci = {}
cap:each(function(x, y)
  local chk = (floor(x/3) + floor(y/3)) % 2 == 0
  local vv = cv[K(x,y)]
  local r = chk and CL or CR
  local i = vv > .8 and 5 or vv > .6 and 4 or vv > .4 and 3 or vv > .22 and 2 or 1
  c:px(x, y, r[i]) end)
-- twine + bow
for x = 20, 43 do c:px(x, 25, PP[3]) c:px(x, 26, PP[1]) end
for x = 22, 40, 3 do c:px(x, 25, PP[5]) end
c:fillMask(c:rect(28,24,30,27), PP[2]) c:px(29,24,PP[5])
G.line(c, { {29,25}, {25,28}, {23,31} }, PP[3]) G.line(c, { {29,25}, {34,28}, {35,32} }, PP[3])
c:px(23,32,PP[1]) c:px(35,33,PP[1])
-- label
local lab = c:rect(23, 37, 40, 49)
shade(lab, CR, 8, {amb=.2, wrap=.4})
c:fillMask(c:rect(23,37,40,37), CR[2]) 
local orng = c:ellipse(31, 41, 3, 3)
shade(orng, M, 3, {amb=.15})
c:px(31,38,"#3f8a45") c:px(32,38,"#3f8a45") c:px(30,40,M[6])
for x = 26, 38 do c:px(x, 46, CR[2]) end
for x = 27, 36 do c:px(x, 48, CR[3]) end
-- drip down the glass
c:fillMask(c:rect(45, 27, 46, 34), M[3]) c:px(45,28,M[5]) c:px(46,34,M[2]) c:px(45,35,M[3]) c:px(45,36,M[4])
-- glint
c:px(21,28,GL[6]) c:px(22,28,GL[6])
G.save(c, NAME)
