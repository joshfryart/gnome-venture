-- tile-gravel-path (lean D3o_3)
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
local NAME = "tile-gravel-path"
local SAND = {"#a8967a","#bba98c","#cfbf9f","#e0d2b4","#ece1c8"}
for y = 0, 63 do for x = 0, 63 do
  px(x, y, pick(SAND, 0.5 + (vn(x,y,6,1)-.5)*.5 + (H(x,y,2)-.5)*.35)) end end
for k = 0, 2 do for x = 0, 63 do local y = floor(9 + k*21 + 3*sin(x/8 + k*2))
  px(x, y, "#8e7c64") px(x, y+1, "#e9dec4") end end
local RAMPS = {
  {"#3f3b4d","#5d596d","#7f7b90","#a4a0b3","#cdc9d6"},
  {"#6a5238","#8f7048","#b69458","#d6b878","#ecd9a0"},
  {"#6e3f2a","#97593a","#bf7f4c","#e0a870","#f2cf9a"},
  {"#2a2a38","#41414f","#5c5c6c","#7a7a8c","#9d9db0"}}
local P = {}
for gy = 0, 8 do for gx = 0, 8 do
  if H(gx,gy,5) > 0.33 then
    local r = 1.8 + H(gx,gy,7)^1.5 * 2.8
    P[#P+1] = { gx*7.2 + 3 + (H(gx,gy,6)-.5)*4.5, gy*7.2 + 3 + (H(gx,gy,9)-.5)*4.5, r, gx*9+gy }
  end end end
table.sort(P, function(a, b) return a[2] < b[2] end)
for _, p in ipairs(P) do
  local cx, cy, r, s = p[1], p[2], p[3], p[4]
  local rx, ry = r*(1 + .3*H(s,1,3)), r*(.78 + .2*H(s,2,3))
  local q = H(s,3,8)
  local ramp = RAMPS[q < .35 and 1 or q < .6 and 2 or q < .82 and 3 or 4]
  stone(cx, cy, rx, ry, s, .14, ramp, { shadow = {1, 1, "#7d6c55"}, grain = .1 })
  if r > 2.9 then px(floor(cx - rx*.35), floor(cy - ry*.45), "#fff8ec") end
end
-- quirk: a stubborn little weed pushing up between pebbles
local W = {}
for _, q in ipairs{{52,52},{52,51},{52,50},{51,49},{53,49},{50,48},{54,48}} do W[q[2]*64+q[1]] = true end
for k in pairs(W) do px(k%64, floor(k/64), floor(k/64) < 50 and "#8fcf68" or "#3a7f43") end
px(52, 52, "#2d5f35") outline(W)
save(NAME)
