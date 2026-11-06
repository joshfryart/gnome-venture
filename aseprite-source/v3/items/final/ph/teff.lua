-- teff (lean D3o_0)
local NAME = "teff"
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
local SD = { "#4a2a22", "#7a4a30", "#a8704a", "#cf9a62", "#e8c488", "#f6e4b4" }
local RD = { "#5a2230", "#8a3440", "#b4524e", "#d67a62" }
local GR = { "#2c4a28", "#46722f", "#6e9a3c", "#9cc050", "#c8dc78", "#e4efa0" }
local ST = { "#3b5a2c", "#5d8a3a", "#8cb04c", "#c4d070" }
c:groundShadow(32, 58, 15, 2)
-- basal blades (thin, arching)
leaf(30,56, 20,44, 12,30, 2.6, GR, 0, false)
leaf(34,56, 46,46, 54,34, 2.4, GR, 0, false)
-- three culms with feathery open panicles
local culms = {
  { {31,57}, {30,40}, {25,26}, {22,10}, 1 },
  { {32,57}, {33,38}, {34,24}, {36,8}, -1 },
  { {33,57}, {40,44}, {44,34}, {46,20}, 1 } }
for ci, cu in ipairs(culms) do
  local pts = { cu[1], cu[2], cu[3], cu[4] }
  local sm, sn = G.tube(pts, function(t) return 1.1 end)
  toneN(sm, sn, ST, {cuts={.3,.55,.8}})
  -- node knob
  local nx, ny = bez(pts, 0.35) c:px(floor(nx+0.5), floor(ny+0.5), ST[1])
  -- panicle: branches off the upper culm, drooping with seeds
  local k = 0
  for t = 0.5, 1.0, 0.045 do
    local x, y = bez(pts, t) x, y = floor(x + 0.5), floor(y + 0.5)
    k = k + 1
    local side = (k % 2 == 0) and 1 or -1
    local reach = floor(2 + 3 * sin(pi * (t - 0.4) / 0.7) + 0.5)
    for i = 1, reach do
      local bx, by = x + side * i, y + floor(i * 0.5)
      local h = X.hash(bx, by, ci)
      c:px(bx, by, h > .8 and SD[5] or SD[3 + (h > .4 and 1 or 0)])
    end
    local ex, ey = x + side * reach, y + floor(reach * 0.5)
    c:px(ex, ey + 1, SD[2]) c:px(ex + side, ey, h and RD[2] or SD[4])
  end
  c:px(floor(pts[4][1]+0.5), floor(pts[4][2]+0.5) - 1, SD[4])
end
-- a few red-brown seeds mixed in, light glints
c:px(24,17,RD[3]) c:px(35,14,RD[3]) c:px(45,26,RD[3]) c:px(23,13,SD[6]) c:px(36,11,SD[6])
-- fallen grains (quirk)
for _, p in ipairs{ {24,57},{25,57},{27,58},{39,57},{40,58},{42,57} } do c:px(p[1], p[2], SD[(p[1]%3)+3]) end
G.save(c, NAME)
