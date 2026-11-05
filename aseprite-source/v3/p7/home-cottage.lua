-- home-cottage v3: cosy cottage interior, fire + window light
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK, vn = X.hash, GX.INK, GX.vn
local c = HP.canvas{ w=480, h=270, scale=1, name="home-cottage" }
local function mk() return HP.mask() end
local function R6(r) return GX.ramp6(r) end
local function clamp(v,a,b) return max(a, min(b, v)) end

local WALL = R6{ hi="#f4d79c", base="#d9a66a", shade="#a8704c", deep="#6a4244" }
local WOOD = R6{ hi="#e8aa6a", base="#b8703c", shade="#7e4434", deep="#442636" }
local BEAM = R6{ hi="#d0925a", base="#94562f", shade="#5e3030", deep="#34202c" }
local FLOOR= R6{ hi="#e0a25e", base="#aa6a3c", shade="#744030", deep="#422832" }
local STONE= R6{ hi="#e2dce6", base="#b0aac0", shade="#78728e", deep="#46405e" }
local BRASS= R6{ hi="#fff0a0", base="#f0b43a", shade="#c0782a", deep="#7a4020" }
local RED  = R6{ hi="#ff8a5c", base="#e8493b", shade="#b52e3f", deep="#6e2038" }
local GRN  = R6{ hi="#c8f070", base="#58b050", shade="#2e7648", deep="#1c4a40" }
local YEL  = R6{ hi="#fff0a0", base="#f5c43a", shade="#d0802a", deep="#8f4a1f" }
local GING = R6{ hi="#ffd08a", base="#ec8c40", shade="#b45a34", deep="#6a3030" }

local FX, FY = 400, 168
-- light field: fire glow + window light + cool falloff
local function Lf(x, y)
  local dx, dy = (x-FX)*.85, (y-FY)*1.15
  local dd = sqrt(dx*dx+dy*dy)
  local f = max(0, 1-dd/200)
  local v = .5*f*f - .2*clamp((dd-150)/190, 0, 1)
  local wx, wy = (x-85)*.8, (y-80)
  v = v + .22*max(0, 1-sqrt(wx*wx+wy*wy)/120)
  if y > 190 then
    local t = y-190
    if x > 10+t*.9 and x < 150+t*.9 then v = v + .16 end
  end
  return v
end
local function grainH(x, y, s) return (vn(x*.1, y, 2.2, s)-.5)*.42 + (vn(x*.3, y*1.3, 1.5, s+4)-.5)*.14 end
local function grainV(x, y, s) return (vn(x, y*.1, 2.2, s)-.5)*.42 + (vn(x*1.3, y*.3, 1.5, s+4)-.5)*.14 end
local function knot(x, y, kx, ky, kr)
  local dx, dy = (x-kx), (y-ky)*.6
  local dd = sqrt(dx*dx+dy*dy)
  if dd < kr then return (dd < kr*.35 and -.3 or 0) + sin(dd*1.5)*.14 end
  return 0
end
local function put(x, y, ramp, v) c:px(x, y, ramp[GX.idx(clamp(v,0,1))]) end

---------------------------------------------------------------- wall (vertical planks)
for x = 0, 479 do for y = 0, 190 do
  local pi = floor((x+7)/22)
  local o = (H(pi, 3, 1)-.5)*.2
  local v = .56 + o + grainV(x, y, 20+pi) + Lf(x, y)
  v = v + knot(x, y, pi*22+9, 40+H(pi,5,2)*90, 6) + ((H(pi,9,9) > .7) and knot(x, y, pi*22+8, 110+H(pi,2,2)*30, 5) or 0)
  local e = (x+7) % 22
  if e == 0 then v = v - .33 elseif e == 1 then v = v + .1 end
  put(x, y, WALL, v)
end end

-- wainscot (lower boards)
for x = 0, 479 do for y = 150, 192 do
  local pi = floor(x/11)
  local v = .5 + (H(pi,4,1)-.5)*.2 + grainV(x, y, 50+pi) + Lf(x, y) - .02
  local e = x % 11
  if e == 0 then v = v - .34 elseif e == 1 then v = v + .08 end
  put(x, y, WOOD, v)
end end

local function beam(x0, y0, x1, y1, ramp, seed, vert, R)
  local m = c:rect(x0, y0, x1, y1)
  GX.lit(c, m, ramp, { R=R or 5, seed=seed, tex=.25, rimlight=true, fn=function(x, y)
    return (vert and grainV(x, y, seed) or grainH(x, y, seed))*1.1 + Lf(x, y) + knot(x, y, x0+(x1-x0)*.6, y0+(y1-y0)*.4, 4)*(H(seed,1,1)>.4 and 1 or 0) end })
  return m
end

---------------------------------------------------------------- floor planks
for x = 0, 479 do for y = 192, 269 do
  local r = floor((y-192)/13); local t = (y-192) % 13
  local v = .55 + (H(r, 7, 1)-.5)*.22 + grainH(x, y, 70+r)*1.1 + Lf(x, y)
  v = v + knot(x, y, 60+H(r,3,3)*360, 192+r*13+6, 5)*(H(r,8,8)>.5 and 1 or 0)
  if t == 0 then v = v - .34 elseif t == 1 then v = v + .1 end
  if (x + r*53) % 109 == 0 then v = v - .32 end
  put(x, y, FLOOR, v)
end end
beam(0, 188, 479, 196, BEAM, 31, false, 4)   -- baseboard beam

---------------------------------------------------------------- ceiling beam + rafter hints
beam(0, 0, 479, 17, BEAM, 11, false, 8)
beam(0, 17, 479, 22, WOOD, 12, false, 3)
-- posts
beam(144, 22, 160, 190, BEAM, 13, true, 6)
beam(306, 22, 322, 190, BEAM, 14, true, 6)
beam(0, 144, 336, 152, BEAM, 15, false, 4)   -- chair rail

---------------------------------------------------------------- window
local WX0, WY0, WX1, WY1 = 52, 40, 120, 116
for x = WX0, WX1 do for y = WY0, WY1 do
  local t = (y-WY0)/(WY1-WY0)
  local sky = t < .52
  local hill = 82 + floor(5*sin(x/9)) + floor(4*sin(x/4+1))
  local col
  if y < hill then
    col = ({ "#8ed0f0", "#a8dcf4", "#c4e8f6", "#dcf2f4" })[min(4, floor(t/.52*4)+1)]
    if vn(x*.3, y*1.4, 3, 5) > .74 then col = "#fff4e0" end
  else
    local g = clamp((y-hill)/30 + (vn(x,y,4,6)-.5)*.5, 0, 1)
    col = ({ "#a8dc60", "#78c050", "#58a448", "#3a8444" })[min(4, floor(g*4)+1)]
  end
  c:px(x, y, col)
end end
-- tiny tree in the view
local tr = mk(); GX.disc(tr, 100, 88, 7, 6); tr = GX.rough(tr, 8, 1)
GX.lit(c, tr, GRN, { R=5, tex=.6, sc=2.5, seed=8, ink=false })
c:fillMask(c:rect(99, 94, 100, 100), "#6e4234")
-- frame, mullions, sill
local function winframe()
  local fr = c:rect(WX0-6, WY0-6, WX1+6, WY1+6); fr:cut(c:rect(WX0, WY0, WX1, WY1))
  GX.lit(c, fr, WOOD, { R=4, seed=17, tex=.25, fn=function(x,y) return grainH(x,y,17)+Lf(x,y)+.04 end })
  GX.lit(c, c:rect(WX0+31, WY0, WX0+36, WY1), WOOD, { R=2, seed=18, ink=false, fn=function(x,y) return grainV(x,y,18)+Lf(x,y) end })
  GX.lit(c, c:rect(WX0, WY0+34, WX1, WY0+39), WOOD, { R=2, seed=19, ink=false, fn=function(x,y) return grainH(x,y,19)+Lf(x,y) end })
  c:rim(c:rect(WX0, WY0, WX1, WY1), INK)
  beam(WX0-12, WY1+6, WX1+12, WY1+14, WOOD, 20, false, 3)   -- sill
  beam(WX0-18, WY0-14, WX1+18, WY0-8, BEAM, 21, false, 3)   -- curtain rod/lintel
end
winframe()
-- curtains (red, folded)
local function curtain(x0, x1, seed, left)
  local m = mk()
  for y = WY0-8, WY1+2 do
    local w = x1 - x0 + floor((vn(0, y, 14, seed)-.5)*5)
    for x = x0, x0 + w do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, RED, { R=6, seed=seed, tex=.2, rimlight=true, fn=function(x, y)
    local f = sin((x-x0)*.95 + vn(x, y, 12, seed)*2)*.2
    return f + Lf(x, y)*.9 end })
  c:fillMask(c:rect(x0, WY1-8, x1, WY1-6), "#e8c060") -- tie band hint
end
curtain(30, 51, 31, true); curtain(121, 143, 32, false)

---------------------------------------------------------------- shelf with jars
local function bottle(cx, cy, s, ramp, seed, hang)
  local m = mk(); GX.disc(m, cx, cy+3, 8*s, 9*s)
  for y = cy-12*s, cy-4 do for x = cx-2*s, cx+2*s do m:set(x, y) end end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, ramp, { R=6, seed=seed, tex=.3, rimlight=true, fn=function(x, y) return Lf(x, y)*.9 + ((x-cx)<-3 and -(y-cy)<-3 and 0 or 0) end })
  c:fillMask(c:rect(cx-1, cy-14*s, cx+1, cy-12*s), "#c89060")   -- cork
  c:rim(c:rect(cx-1, cy-14*s, cx+1, cy-12*s), INK)
  c:px(cx-4*s, cy, ramp[6]); c:px(cx-4*s, cy+1, ramp[6]); c:px(cx-3*s, cy-3, "#fff4e0")
  if hang then for y = 22, cy-14*s-1 do c:px(cx, y, "#6a4a38") end end
end
for i, x in ipairs{ 192, 226, 254, 284 } do bottle(x, 46, 1, GRN, 40+i, true) end
local sh = mk()
for y = 96, 104 do for x = 176, 300 do sh:set(x, y) end end
GX.lit(c, sh, WOOD, { R=4, seed=41, tex=.2, rimlight=true, fn=function(x,y) return grainH(x,y,41)+Lf(x,y) end })
for _, p in ipairs{ {186,104,198,118}, {278,104,290,118} } do   -- brackets
  local br = c:poly{ {p[1],p[2]}, {p[3],p[2]}, {p[1]+ (p[1]<230 and 0 or 12), p[4]} }
  GX.lit(c, br, WOOD, { R=3, seed=42, tex=.1, fn=function(x,y) return Lf(x,y) end })
end
local function jar(cx, cy, rx, ry, ramp, seed, lid)
  local m = mk(); GX.disc(m, cx, cy, rx, ry); m = GX.rough(m, seed, 1)
  GX.lit(c, m, ramp, { R=7, seed=seed, tex=.35, rimlight=true, fn=function(x,y) return Lf(x,y) + (y < cy-ry+4 and 0 or 0) end })
  local l = c:rect(cx-rx+3, cy-ry-4, cx+rx-3, cy-ry+1)
  GX.lit(c, l, WOOD, { R=2, seed=seed+1, fn=function(x,y) return Lf(x,y) end })
  c:px(cx-rx+3, cy-3, "#fff4e0"); c:px(cx-rx+3, cy-2, "#fff4e0")
end
jar(206, 84, 10, 11, YEL, 50); jar(234, 87, 8, 8, RED, 51); jar(264, 82, 9, 13, GRN, 52)
c:fillMask(c:rect(231, 85, 237, 89), "#f4e4c0"); c:rim(c:rect(231, 85, 237, 89), INK)  -- label

---------------------------------------------------------------- fireplace
-- chimney breast stone + body
local function stonefn(x, y, bw, bh, sd)
  local row = floor(y/bh); local off = (row%2)*floor(bw/2)
  local col = floor((x+off)/bw)
  local ex, ey = (x+off) % bw, y % bh
  local v = (H(col, row, sd)-.5)*.3
  if ex == 0 or ey == 0 then v = v - .32 elseif ex == 1 or ey == 1 then v = v + .08 end
  return v + (vn(x, y, 3, sd)-.5)*.22
end
local chim = c:rect(352, 22, 450, 66)
GX.lit(c, chim, STONE, { R=6, seed=60, tex=.1, fn=function(x,y) return stonefn(x,y,22,11,60)+Lf(x,y)-.05 end })
local body = c:rect(336, 82, 464, 192)
GX.lit(c, body, STONE, { R=8, seed=61, tex=.1, fn=function(x,y) return stonefn(x,y,20,12,61)+Lf(x,y) end })
-- firebox arch
local arch = c:rect(362, 126, 436, 182)
for y = 108, 126 do for x = 362, 436 do
  if ((x-399)/37.5)^2 + ((y-126)/18)^2 <= 1 then arch:set(x, y) end end end
local ring = arch:copy():grow(6):cut(arch)
ring:cut(c:rect(300, 183, 480, 200))
GX.lit(c, ring, STONE, { R=3, seed=62, tex=.1, fn=function(x,y)
  local a = floor(((x-399)*.5 + (y-126)*0)/6 + (H(x//6,y//6,3)*3)); return (H(x//7, y//7, 62)-.5)*.35 + Lf(x,y)*1.2 + .1 end })
-- firebox interior (dark with ember glow)
arch:each(function(x, y)
  local dx, dy = (x-399)/38, (y-172)/60
  local g = clamp(1 - sqrt(dx*dx+dy*dy), 0, 1)
  local col = g > .72 and "#a8381e" or g > .5 and "#7e2a24" or g > .3 and "#56202c" or g > .15 and "#3a1a2a" or "#24121e"
  if (x+y)%2==0 and g > .3 and g < .72 then col = g>.5 and "#a8381e" or "#7e2a24" end
  c:px(x, y, col)
end)
c:rim(arch, INK)
-- hearth slab
local hearth = c:rect(326, 182, 474, 196)
GX.lit(c, hearth, STONE, { R=4, seed=63, tex=.1, rimlight=true, fn=function(x,y) return stonefn(x,y,24,14,63)+Lf(x,y)*1.2 end })
-- mantel
local mant = c:rect(324, 66, 476, 82)
GX.lit(c, mant, BEAM, { R=6, seed=64, tex=.25, rimlight=true, fn=function(x,y) return grainH(x,y,64)*1.2+Lf(x,y)*1.1 end })
-- logs
for i, lg in ipairs{ {372,170,426,179, 70}, {378,176,432,184, 71} } do
  local m = c:rect(lg[1], lg[2], lg[3], lg[4]); m = GX.rough(m, lg[5], 1)
  GX.lit(c, m, BEAM, { R=4, seed=lg[5], tex=.3, fn=function(x,y) return grainH(x,y,lg[5])+.25 end })
end

---------------------------------------------------------------- mantel items
-- brass bell
local bell = mk()
for y = 44, 64 do
  local t = (y-44)/20
  local hw = floor(3 + 10*t^1.5 + (t>.9 and 1 or 0))
  for x = 361-hw, 361+hw do bell:set(x, y) end
end
GX.disc(bell, 361, 45, 4, 3)
bell = GX.rough(bell, 72, 1)
GX.lit(c, bell, BRASS, { R=7, seed=72, tex=.25, rimlight=true, fn=function(x,y) return Lf(x,y)+.08 end })
local cl = mk(); GX.disc(cl, 361, 66, 2, 2)  -- clapper peeks below the lip
-- gold ornament on a tiny stand
local orn = mk(); GX.disc(orn, 436, 52, 9, 8); orn = GX.rough(orn, 73, 1)
GX.lit(c, orn, BRASS, { R=8, seed=73, tex=.3, rimlight=true, fn=function(x,y) return Lf(x,y)+.05 end })
c:fillMask(c:rect(430, 60, 442, 65), "#c0782a"); c:rim(c:rect(430, 60, 442, 65), INK)
c:px(431, 48, "#fff8d0"); c:px(432, 47, "#fff8d0"); c:px(431, 49, "#fff8d0")
-- small candle stub
local cd = c:rect(396, 52, 401, 65)
GX.lit(c, cd, R6{ hi="#fffaf0", base="#f2e0bc", shade="#c8a880", deep="#8a6a58" }, { R=3, seed=74, tex=.05, fn=function(x,y) return Lf(x,y)+.1 end })

---------------------------------------------------------------- rug
local rug = mk(); GX.disc(rug, 395, 238, 78, 15); rug = GX.rough(rug, 80, 1)
GX.lit(c, rug, RED, { R=7, h=.5, seed=81, tex=.35, sc=2, rimlight=false, fn=function(x, y)
  local dd = sqrt(((x-395)/78)^2 + ((y-238)/15)^2)
  local f = 0
  if dd > .82 and dd < .9 then f = .28 elseif dd > .7 and dd < .76 then f = -.3 elseif dd > .55 and dd < .6 then f = .2 end
  if dd < .45 and (floor((x-395)/7) + floor((y-238)/4)) % 2 == 0 then f = f + .13 end
  return f + Lf(x, y) end })
-- fringe tassels
for a = 0, 40 do local t = a/40*6.283; local x, y = floor(395+cos(t)*79), floor(238+sin(t)*16)
  if sin(t) > -.2 and a % 2 == 0 then c:px(x, y+1, "#f0d8a0") end end

---------------------------------------------------------------- cat (quirk): sleeping ginger loaf by the fire
local cat = mk()
GX.disc(cat, 352, 232, 19, 10)
GX.disc(cat, 331, 227, 8, 7)
for y = 216, 222 do for x = 326, 330 do if x - 326 <= y - 216 + 1 and (x-326) >= 0 then cat:set(x, y) end end end
for y = 216, 222 do for x = 333, 337 do if 337 - x <= y - 216 + 1 then cat:set(x, y) end end end
GX.disc(cat, 372, 238, 8, 3)  -- tail curl
cat = GX.rough(cat, 90, 1)
GX.lit(c, cat, GING, { R=7, seed=91, tex=.25, rimlight=true, fn=function(x, y)
  local s = 0
  if vn(x*.7, y*.7, 3, 92) > .5 and ((x*2 + y) // 3) % 3 == 0 then s = -.2 end
  if x > 343 and (x % 7 == 0) and y < 236 then s = -.18 end
  return s + Lf(x, y)*1.1 + (y > 236 and .08 or 0) end })
c:px(329, 227, INK); c:px(330, 227, INK); c:px(335, 227, INK); c:px(334, 227, INK)  -- shut eyes
c:px(332, 230, "#f08a90")                                                           -- nose
for _, p in ipairs{ {327,219},{337,219} } do c:px(p[1], p[2], "#f4a090") end        -- inner ears

---------------------------------------------------------------- foreground cabinet
local top = c:rect(0, 206, 298, 220)
GX.lit(c, top, BEAM, { R=7, seed=100, tex=.25, rimlight=true, fn=function(x,y) return grainH(x,y,100)*1.2+Lf(x,y)*1.1+.06 end })
local post = c:rect(284, 220, 296, 270)
local pans = {}
for i = 0, 3 do pans[#pans+1] = c:rect(8+i*69, 228, 68+i*69, 266) end
local frame = c:rect(0, 220, 284, 270)
for _, p in ipairs(pans) do frame:cut(p) end
GX.lit(c, frame, WOOD, { R=5, seed=101, tex=.25, rimlight=true, fn=function(x,y) return grainV(x,y,101)+Lf(x,y)+.02 end })
for i, p in ipairs(pans) do
  GX.lit(c, p, FLOOR, { R=4, seed=102+i, tex=.2, fn=function(x,y) return grainV(x,y,102+i)*1.1+Lf(x,y)-.1 end })
  local kx = 8+i*69 - 69 + (i%2==1 and 55 or 12)
  c:fillMask(c:rect(kx, 244, kx+2, 246), "#f0b43a"); c:rim(c:rect(kx, 244, kx+2, 246), INK)
end
GX.lit(c, post, BEAM, { R=5, seed=110, tex=.25, rimlight=true, fn=function(x,y) return grainV(x,y,110)+Lf(x,y) end })
-- a small loaf-and-bowl on the cabinet top
local bowl = mk(); GX.disc(bowl, 62, 205, 14, 6); bowl = GX.rough(bowl, 111, 1)
bowl:cut(c:rect(40, 190, 90, 198))
GX.lit(c, bowl, R6{ hi="#f4e0c0", base="#c8a078", shade="#8e6a5a", deep="#523a44" }, { R=4, seed=111, tex=.3, fn=function(x,y) return Lf(x,y) end })
for i, p in ipairs{ {55,196,RED}, {66,194,GRN}, {61,200,YEL} } do
  local a = mk(); GX.disc(a, p[1], p[2], 5, 5); a = GX.rough(a, 112+i, 1)
  GX.lit(c, a, p[3], { R=4, seed=112+i, tex=.3, rimlight=true, fn=function(x,y) return Lf(x,y) end })
end
-- redraw bowl rim front over fruit
local brim = mk(); GX.disc(brim, 62, 207, 14, 5); brim:cut(c:rect(40, 190, 90, 203))
GX.lit(c, brim, R6{ hi="#f4e0c0", base="#c8a078", shade="#8e6a5a", deep="#523a44" }, { R=3, seed=115, tex=.2, fn=function(x,y) return Lf(x,y) end })

---------------------------------------------------------------- colour grade pass: dithered firelight warmth + cool shadow
local B = { {0,8,2,10},{12,4,14,6},{3,11,1,9},{15,7,13,5} }
local cache = {}
local function mixc(a, b, t) local k = a..b..t; local r = cache[k]; if not r then r = GX.mix(a, b, t); cache[k] = r end return r end
local WARM, COOL = "#ff9a3c", "#40306e"
for y = 0, 269 do for x = 0, 479 do
  local col = c:get(x, y)
  if col then
    local b = B[y%4+1][x%4+1]/16
    local dx, dy = (x-FX)*.85, (y-FY)*1.15
    local dd = sqrt(dx*dx+dy*dy)
    local w = max(0, 1-dd/190); w = w*w*.34
    local wq = floor(w*12 + b)/12
    if wq > 0 then col = mixc(col, WARM, floor(wq*100+.5)/100)
    else
      local cl = clamp((dd-170)/200, 0, 1)*.3
      local wl = max(0, 1-sqrt(((x-85)*.8)^2+(y-80)^2)/130)
      cl = max(0, cl - wl*.3)
      local cq = floor(cl*10 + b)/10
      if cq > 0 then col = mixc(col, COOL, floor(cq*100+.5)/100) end
    end
    c:px(x, y, col)
  end
end end

---------------------------------------------------------------- flame (after grade, unaffected)
local function flame(pts, col) c:fillMask(c:poly(pts), col) end
-- ember glow bed
local bed = mk(); GX.disc(bed, 399, 172, 24, 5); c:fillMask(GX.rough(bed, 120, 1), "#e8602a")
flame({ {378,170},{380,150},{385,136},{388,150},{392,126},{398,146},{402,118},{407,142},{412,130},{416,150},{420,140},{422,170} }, "#d03a2c")
flame({ {383,170},{385,154},{390,140},{393,152},{398,132},{403,150},{408,138},{412,154},{417,170} }, "#f07a2a")
flame({ {388,170},{391,156},{396,142},{400,156},{404,144},{408,158},{412,170} }, "#f8b83a")
flame({ {393,170},{396,160},{400,150},{404,160},{407,170} }, "#ffe58a")
flame({ {397,170},{400,162},{403,170} }, "#fff6d0")
for _, p in ipairs{ {386,120},{412,114},{396,108},{420,124} } do c:px(p[1], p[2], "#ffd070") end  -- sparks
-- re-ink log fronts lit by flame
for y = 170, 175 do for x = 386, 414 do if H(x, y, 5) < .3 then c:px(x, y, "#a8381e") end end end
-- window glass glint (hard)
for i = 0, 5 do c:px(WX0+6+i, WY0+4-i//2+i, "#ffffff"):px(WX0+7+i, WY0+4+i, "#fff4e0") end

local out = d.."/out"
c:save{ aseprite=out.."/home-cottage.aseprite", png=out.."/home-cottage.png", scale=1 }
