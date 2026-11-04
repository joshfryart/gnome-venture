-- tile-tilled (lean D3o_3)
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
local NAME = "tile-tilled"
local RID = {"#6b4228","#8a5a34","#a8743f","#c4914f","#dcae6c"}
local FUR = {"#241714","#33201a","#432b21","#563626"}
local PER = 13
local function zone(x, y)
  local yy = y + 2.2*sin(x/10 + 0.8)
  local t = (yy % PER) / PER
  return t < .6 and "r" or "f", t
end
for y = 0, 63 do for x = 0, 63 do
  local z, t = zone(x, y)
  if z == "r" then
    local v = .62 - t*.55 + (vn(x,y,7,1) + vn(x*.3,y*2.4,3,2) - 1)*.35 + (H(x,y,3)-.5)*.2
    if zone(x, y-1) == "f" then v = .95 end
    px(x, y, pick(RID, v))
  else
    px(x, y, pick(FUR, .35 + (t-.6)*.5 + (vn(x,y,5,4)-.5)*.5 + (H(x,y,5)-.5)*.2))
  end
end end
for y = 0, 62 do for x = 0, 63 do
  if zone(x, y) == "r" and zone(x, y+1) == "f" then px(x, y, INK) end
  if zone(x, y) == "r" and zone(x, y+2) == "f" and H(x,y,9) > .35 then px(x, y, RID[1]) end
end end
local CL = {"#4c2f1f","#6b4228","#8a5a34","#a8743f","#c4914f"}
local clods = {{8,5,2.2,1.5},{30,7,2.6,1.7},{52,3,2,1.4},{19,20,2.4,1.6},{44,18,2.2,1.5},{60,22,1.8,1.3},{8,32,2.2,1.5},{34,34,2.6,1.7},{54,45,2.2,1.5},{14,47,2.4,1.6},{40,58,2.2,1.5},{59,59,1.8,1.3}}
for i, c in ipairs(clods) do stone(c[1], c[2], c[3], c[4], i, .2, CL, { shadow = {1,1,"#2a1a14"}, grain = .15 }) end
-- pale pebbles
for _, p in ipairs{{26,19,1.8,1.3},{48,31,1.6,1.2},{12,58,1.8,1.3}} do
  stone(p[1], p[2], p[3], p[4], 31, .1, {"#8a8096","#aaa2b8","#cac4d6","#e8e4f0"}, { shadow = {1,1,"#2a1a14"} }) end
-- quirk: a seed sprouting in the furrow
local sx = 22 local sy
for y = 36, 63 do local z, t = zone(sx, y) if z == "f" and t > .74 and t < .84 then sy = y break end end
if sy then
  local s = {}
  for _, q in ipairs{{0,0},{1,0},{0,-1},{0,-2},{-1,-3},{1,-3},{-2,-3},{2,-3}} do s[(sy+q[2])*64+sx+q[1]] = true end
  outline(s)
  px(sx, sy, "#e8d6a0") px(sx+1, sy, "#b8a070") px(sx, sy-1, "#58a24e") px(sx, sy-2, "#6eb558")
  px(sx-1, sy-3, "#8fcf68") px(sx-2, sy-3, "#6eb558") px(sx+1, sy-3, "#8fcf68") px(sx+2, sy-3, "#58a24e")
end
save(NAME)
