-- tile-stepping-stones (lean D3o_3)
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
local NAME = "tile-stepping-stones"
local GR = {"#2c6639","#3a7f43","#4f9a4c","#6eb558","#8fcf68"}
for y = 0, 63 do for x = 0, 63 do
  px(x, y, pick(GR, .45 + (vn(x,y,9,4)-.5)*.55 + (H(x,y,2)-.5)*.2)) end end
for i = 1, 46 do local x, y = floor(H(i,1,7)*62)+1, floor(H(i,2,7)*60)+3
  px(x, y, GR[1]) px(x, y-1, GR[4]) px(x+1, y-2, GR[5]) px(x-1, y-1, GR[3]) end
local S = {
  {15, 47, 10, 6.5, 3, .1, {"#6a6676","#8a8698","#aaa6b8","#c9c5d4","#e6e3ee"}, {"#3c3948","#4d4a5c"}},
  {35, 32, 9, 6.5, 8, .14, {"#7d6a58","#9d8870","#bca48a","#d6c2a6","#ede0c8"}, {"#4a3d32","#5e4e40"}},
  {52, 15, 8, 5.5, 5, .12, {"#586480","#7482a0","#93a1bf","#b3c1dc","#d6e0f2"}, {"#33394e","#444c66"}}}
for i, s in ipairs(S) do
  local cx, cy, rx, ry = s[1], s[2], s[3], s[4]
  -- dirt ring and slab side
  local d = blob(cx, cy+2, rx+2.5, ry+2, s[5]+3, .1)
  for k in pairs(d) do local x, y = k%64, floor(k/64) px(x, y, H(x,y,3) > .5 and "#4a3226" or "#5e4332") end
  local side = blob(cx, cy+3, rx, ry, s[5], s[6])
  shade(side, cx, cy+3, rx, ry, s[8], s[5], { flat = 1, grain = .1 }) outline(side)
  local top = blob(cx, cy, rx, ry, s[5], s[6])
  shade(top, cx, cy, rx, ry, s[7], s[5], { flat = .55, grain = .14 }) outline(top)
  px(floor(cx - rx*.45), floor(cy - ry*.5), "#fffaf2") px(floor(cx - rx*.45)+1, floor(cy - ry*.5), "#fffaf2")
  if i == 1 then walk(floor(cx+1), floor(cy-3), 7, s[7][1], 4) end
  if i == 2 then for k in pairs(top) do local x, y = k%64, floor(k/64)
    if x < cx - 1 and y > cy and vn(x,y,3,6) > .52 then px(x, y, H(x,y,2) > .5 and "#3f8545" or "#58a24e") end end end
  if i == 3 then local lx, ly = floor(cx+2), floor(cy)
    px(lx, ly, "#d9323a") px(lx+1, ly, "#a82230") px(lx, ly-1, INK) px(lx+1, ly-1, INK) px(lx+2, ly, INK) px(lx-1, ly, INK) px(lx, ly+1, INK) px(lx+1, ly+1, INK) px(lx, ly, "#e8545a") end
end
save(NAME)
