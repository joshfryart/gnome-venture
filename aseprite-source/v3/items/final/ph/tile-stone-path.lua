-- tile-stone-path (lean D3o_3)
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
local NAME = "tile-stone-path"
local sd = {{10,10,0},{30,8,2},{50,11,-1},{6,28,1},{22,26,-1},{40,29,2},{58,27,0},{10,47,1},{28,49,-1},{46,46,1},{60,50,-1},{20,61,0},{44,60,2}}
local R = {
  {"#4b4a5c","#66657a","#83829a","#a3a2b8","#c4c3d6"},
  {"#6a5d58","#8a7a70","#a99a8b","#c6b8a6","#e0d4c0"},
  {"#4a5568","#65738a","#8394ac","#a3b4cb","#c4d2e4"},
  {"#74685c","#95897a","#b5a995","#d3c8b0","#ece4cc"}}
local cellOf = {}
for y = 0, 63 do for x = 0, 63 do
  local d1, d2, i1 = 1e9, 1e9, 0
  for i, s in ipairs(sd) do local d = sqrt((x-s[1])^2 + (y-s[2])^2) - s[3]
    if d < d1 then d2 = d1 d1 = d i1 = i elseif d < d2 then d2 = d end end
  local e = d2 - d1
  cellOf[y*64+x] = i1
  if e < 1.8 then px(x, y, e < 1.0 and INK or (H(x,y,1) > .5 and "#3a2e3a" or "#4d414d"))
  else
    local s = sd[i1] local r = R[(i1 % 4) + 1]
    local v = .5 + (H(x,y,2)-.5)*.16 + (vn(x,y,5,i1)-.5)*.3 - ((x-s[1]) + (y-s[2]))*.006
    if e < 5.5 then local f = 1 - e/5.5
      if (x-s[1]) + (y-s[2]) < 0 then v = v + .3*f else v = v - .3*f end end
    px(x, y, pick(r, v))
  end
end end
walk(14, 5, 8, "#3a3548", 3) walk(52, 33, 7, "#5b4a40", 5) walk(30, 44, 6, "#4a4052", 7, -1) walk(42, 55, 6, "#3a3548", 9)
-- quirk: a weed in the mortar
local wx, wy
for y = 40, 62 do for x = 31, 62 do if not wx and grid[y*64+x] == INK and grid[(y+1)*64+x] == INK then wx, wy = x, y end end end
if wx then
  local W = {{0,0},{0,-1},{-1,-2},{1,-2},{0,-2}}
  local s = {} for _, q in ipairs(W) do s[(wy+q[2])*64+wx+q[1]] = true end
  outline(s)
  px(wx, wy, "#3a7f43") px(wx, wy-1, "#58a24e") px(wx-1, wy-2, "#8fcf68") px(wx+1, wy-2, "#6eb558") px(wx, wy-2, "#8fcf68")
end
save(NAME)
