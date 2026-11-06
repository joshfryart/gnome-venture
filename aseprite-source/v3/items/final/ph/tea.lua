-- tea (lean D3o_0)
local NAME = "tea"
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
local YL = { "#2c5a2a", "#4c8431", "#78ab3c", "#a3cc50", "#cbe46c", "#eaf5a0" }
local DK = { "#13302e", "#1d4a38", "#2a6a3b", "#418a40", "#63aa4a", "#93c963" }
local SV = { "#5f8a6a", "#8fb592", "#bcd6b8", "#dceed0", "#f0f8e6", "#fbfff0" }
local WD = { "#3a2a1e", "#5a4028", "#7d5a36", "#a88050" }
c:groundShadow(30, 58, 12, 2)
-- older leaves low on the shoot, darker
leaf(21,44, 8,48, 6,38, 4.6, DK, 2.4, true)
leaf(23,40, 34,46, 49,43, 4.8, DK, 2.4, true)
-- woody stem
local sm, sn = G.tube({ {18,57}, {19,44}, {28,32}, {39,18} }, function(t) return 1.7 - 0.7*t end)
toneN(sm, sn, WD, {cuts={.3,.55,.8}})
-- young leaves
leaf(28,32, 17,31, 10,22, 4.0, YL, 2.6, true)
leaf(34,26, 45,27, 53,19, 3.8, YL, 2.6, true)
-- the pluck: bud (silver spear, downy) between two leaves
local bud = leaf(38,19, 38,10, 42,5, 2.4, SV, 0, false)
leaf(38,20, 33,13, 31,8, 2.0, YL, 0, false)
-- downy hairs on bud
c:px(40,9,SV[6]) c:px(39,12,SV[6])
-- dewdrop quirk on lower leaf
c:fillMask(c:rect(42,44,43,45), "#bfe8f0") c:px(42,44,"#f6fdff") c:px(43,46,DK[1])
G.save(c, NAME)
