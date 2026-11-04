-- tile-notill (lean D3o_3)
local out = app.params["out"] or "./"
local floor, abs, sin, cos, sqrt, max, min, pi = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min, math.pi
local spr = Sprite(64, 64, ColorMode.RGB)
local img = Image(64, 64, ColorMode.RGB)
local INK = "#2b1c26"
local cc, grid = {}, {}
local function col(h) local v = cc[h]
  if not v then local s = h:gsub("#", ""); v = app.pixelColor.rgba(tonumber(s:sub(1,2),16), tonumber(s:sub(3,4),16), tonumber(s:sub(5,6),16), 255); cc[h] = v end
  return v end
local function px(x, y, h) x = floor(x) y = floor(y)
  if x < 0 or y < 0 or x > 63 or y > 63 then return end
  img:putPixel(x, y, col(h)); grid[y*64+x] = h end
local function H(x, y, s) local n = sin(x*127.1 + y*311.7 + (s or 0)*74.7) * 43758.5453; return n - floor(n) end
local function vn(x, y, sc, s)
  local gx, gy = x/sc, y/sc local x0, y0 = floor(gx), floor(gy) local fx, fy = gx-x0, gy-y0
  fx = fx*fx*(3-2*fx) fy = fy*fy*(3-2*fy)
  local a, b, c, d = H(x0,y0,s), H(x0+1,y0,s), H(x0,y0+1,s), H(x0+1,y0+1,s)
  return a + (b-a)*fx + (c-a)*fy + (a-b-c+d)*fx*fy end
local function pick(r, v) local i = floor(v*#r) + 1 if i < 1 then i = 1 elseif i > #r then i = #r end return r[i] end
local function outline(set)
  for k in pairs(set) do local x, y = k % 64, floor(k/64)
    for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do local nx, ny = x+d[1], y+d[2]
      if nx >= 0 and ny >= 0 and nx < 64 and ny < 64 and not set[ny*64+nx] then px(nx, ny, INK) end end end end
local function blob(cx, cy, rx, ry, seed, rough)
  local set, ph = {}, seed*1.7
  for y = floor(cy-ry*1.4)-1, floor(cy+ry*1.4)+1 do for x = floor(cx-rx*1.4)-1, floor(cx+rx*1.4)+1 do
    local dx, dy = x+0.5-cx, y+0.5-cy
    local a = math.atan(dy, dx)
    local rr = 1 + rough*(sin(a*2+ph)*.5 + sin(a*3+ph*2.1)*.3 + sin(a*5+ph*3.3)*.2)
    if (dx/rx)^2 + (dy/ry)^2 < rr*rr and x >= 0 and y >= 0 and x < 64 and y < 64 then set[y*64+x] = true end
  end end
  return set end
local function shade(set, cx, cy, rx, ry, r, seed, o)
  o = o or {} local flat = o.flat or 0
  for k in pairs(set) do local x, y = k % 64, floor(k/64)
    local nx, ny = (x+.5-cx)/rx, (y+.5-cy)/ry
    local z = sqrt(max(0, 1-nx*nx-ny*ny))
    local v = 0.5 + (-nx*.5 - ny*.6)*.4*(1-flat) + (z-.5)*.35*(1-flat) + (H(x,y,seed)-.5)*(o.grain or .12)
    if not set[(y-1)*64+x] or not set[y*64+x-1] then v = v + .2 end
    if not set[(y+1)*64+x] or not set[y*64+x+1] then v = v - .22 end
    px(x, y, pick(r, v)) end end
local function stone(cx, cy, rx, ry, seed, rough, r, o)
  o = o or {}
  local set = blob(cx, cy, rx, ry, seed, rough)
  if o.shadow then for k in pairs(set) do local x, y = k % 64 + o.shadow[1], floor(k/64) + o.shadow[2]
    if not set[y*64+x] then px(x, y, o.shadow[3]) end end end
  shade(set, cx, cy, rx, ry, r, seed, o)
  if not o.noink then outline(set) end
  return set end
local function walk(x, y, n, col_, seed, dir)
  for i = 1, n do px(x, y, col_)
    local h = H(x, y, seed+i)
    if h < .4 then x = x + (dir or 1) elseif h < .7 then y = y + 1 else x = x + (dir or 1) y = y + 1 end end end
local function save(name)
  local cel = spr.cels[1]
  if cel then cel.image:drawImage(img) else spr:newCel(spr.layers[1], 1, img, Point(0,0)) end
  spr:saveCopyAs(out .. name .. ".png")
  spr:saveAs(out .. name .. ".aseprite") end
local NAME = "tile-notill"
local SOIL = {"#241719","#34211f","#472e27","#5d3d2e","#76503a"}
for y = 0, 63 do for x = 0, 63 do
  px(x, y, pick(SOIL, 0.33 + (vn(x,y,7,3)-.5)*.6 + (H(x,y,2)-.5)*.25)) end end
local CL = {"#2f1d1f","#46302a","#634232","#835a41","#a07553"}
local clods = {{8,12,3.6,2.6},{27,8,3,2.2},{44,20,4,2.8},{58,9,2.6,2},{16,34,3.4,2.4},{36,38,3,2.2},{56,40,3.6,2.6},{6,58,3.2,2.2},{28,57,3.6,2.6},{50,59,3,2},{22,22,2.4,1.8},{60,28,2.4,1.8}}
for i, c in ipairs(clods) do stone(c[1], c[2], c[3], c[4], i, .25, CL, { shadow = {1,1,"#1b1013"}, grain = .2 }) end
-- rock
stone(47, 49, 5.5, 3.8, 21, .12, {"#4a4658","#6c687a","#8d899a","#b2aebb","#d4d0d8"}, { shadow = {1,2,"#1b1013"}, flat = .2 })
px(44, 47, "#f2f0f6") px(45, 47, "#f2f0f6")
-- dry grass tufts
local STR = {"#7a5a1c","#a9801f","#d3a936","#f0d067","#fbeaa0"}
local function tuft(x0, y0, n, len, seed)
  local set = {}
  for j = 1, n do
    local ang = (-.9 + 1.8*(j-1)/(n-1)) + (H(j,seed,4)-.5)*.3
    local L = len*(.65 + .5*H(j,seed,5))
    local x, y = x0, y0
    for i = 0, floor(L) do
      local a = ang*(1 + .6*i/L)
      x = x + sin(a)*.95 y = y - cos(a)*.95
      local X, Y = floor(x+.5), floor(y+.5)
      set[Y*64+X] = pick(STR, .1 + .9*(i/L))
    end
  end
  local s2 = {} for k in pairs(set) do s2[k] = true end
  outline(s2)
  for k, c in pairs(set) do px(k%64, floor(k/64), c) end
  px(x0, y0, STR[1]) px(x0-1, y0, STR[1]) px(x0+1, y0, STR[1])
end
tuft(18, 26, 6, 9, 1) tuft(48, 33, 7, 10, 2) tuft(10, 46, 5, 7, 3) tuft(34, 20, 5, 8, 4) tuft(58, 54, 5, 7, 5)
-- green sprouts
for _, s in ipairs{{30,50},{40,6},{5,28},{23,44}} do
  local S2 = {}
  for _, q in ipairs{{0,0},{0,-1},{-1,-2},{1,-2},{-2,-2},{2,-2}} do S2[(s[2]+q[2])*64+s[1]+q[1]] = true end
  outline(S2)
  px(s[1], s[2], "#3a7f43") px(s[1], s[2]-1, "#58a24e")
  for _, q in ipairs{{-1,-2},{-2,-2}} do px(s[1]+q[1], s[2]+q[2], "#8fcf68") end
  for _, q in ipairs{{1,-2},{2,-2}} do px(s[1]+q[1], s[2]+q[2], "#6eb558") end
end
-- quirk: a tiny mushroom
local st = {} for y = 53, 55 do for x = 13, 14 do st[y*64+x] = true end end
outline(st) for k in pairs(st) do px(k%64, floor(k/64), (k%64 == 13) and "#f2e6d0" or "#c9b79c") end
local cap = blob(14, 51.5, 4.2, 2.6, 9, 0)
for k in pairs(cap) do local x, y = k%64, floor(k/64) if y < 53 then px(x, y, (x+y) % 5 == 0 and "#fff4e8" or (x > 14 and "#a82f3a" or "#d9484f")) end end
outline(cap)
save(NAME)
