-- Fight backdrop kit (private to fight-*.lua). 480x270 opaque scenes, hard pixels.
local K = {}
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
K.HP = dofile(ROOT .. "lib/hp.lua")
local W, H = 480, 270
K.W, K.H, K.INK = W, H, "#2b1c26"
local buf = {}
local floor, sqrt, abs = math.floor, math.sqrt, math.abs

function K.set(x, y, c) x, y = floor(x), floor(y) if c and x >= 0 and x < W and y >= 0 and y < H then buf[y*W+x+1] = c end end
function K.get(x, y) x, y = floor(x), floor(y) if x >= 0 and x < W and y >= 0 and y < H then return buf[y*W+x+1] end end

local function hash(x, y, s)
  x, y, s = floor(x), floor(y), floor(s or 0)
  local n = ((x * 73856093) ~ (y * 19349663) ~ (s * 83492791)) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
K.hash = hash
local function sm(t) return t*t*(3-2*t) end
function K.noise(x, y, sc, s)
  local fx, fy = x/sc, y/sc
  local ix, iy = floor(fx), floor(fy)
  local tx, ty = sm(fx-ix), sm(fy-iy)
  local a, b = hash(ix, iy, s), hash(ix+1, iy, s)
  local c, d = hash(ix, iy+1, s), hash(ix+1, iy+1, s)
  local top = a + (b-a)*tx
  return top + ((c + (d-c)*tx) - top)*ty
end
function K.fbm(x, y, sc, s)
  return K.noise(x, y, sc, s)*0.55 + K.noise(x, y, sc/2, s+7)*0.3 + K.noise(x, y, sc/4, s+13)*0.15
end

-- masks: tables keyed by pixel index
function K.has(m, x, y) return x >= 0 and x < W and y >= 0 and y < H and m[y*W+x+1] end
function K.each(m, fn) for k in pairs(m) do local i = k-1 fn(i % W, i // W) end end
function K.add(a, b) for k in pairs(b) do a[k] = true end return a end
function K.cut(a, b) for k in pairs(b) do a[k] = nil end return a end
function K.clip(a, b) for k in pairs(a) do if not b[k] then a[k] = nil end end return a end
function K.copy(a) local m = {} for k in pairs(a) do m[k] = true end return m end
function K.filter(a, fn) local m = {} K.each(a, function(x, y) if fn(x, y) then m[y*W+x+1] = true end end) return m end
function K.rect(x0, y0, x1, y1) local m = {}
  for y = math.max(0, floor(y0)), math.min(H-1, floor(y1)) do for x = math.max(0, floor(x0)), math.min(W-1, floor(x1)) do m[y*W+x+1] = true end end
  return m end
function K.poly(pts)
  local m, miny, maxy = {}, 1e9, -1e9
  for _, p in ipairs(pts) do miny = math.min(miny, p[2]) maxy = math.max(maxy, p[2]) end
  for y = math.max(0, floor(miny)), math.min(H-1, math.ceil(maxy)) do
    local yc, xs = y + 0.5, {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= yc and b[2] > yc) or (b[2] <= yc and a[2] > yc) then
        xs[#xs+1] = a[1] + (yc - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs-1, 2 do
      for x = math.max(0, math.ceil(xs[i]-0.5)), math.min(W-1, floor(xs[i+1]-0.5)) do m[y*W+x+1] = true end
    end
  end
  return m
end
function K.blob(cx, cy, rx, ry, seed, rough)
  local m = {}
  rough = rough or 0.2
  for y = floor(cy-ry*1.5), math.ceil(cy+ry*1.5) do for x = floor(cx-rx*1.5), math.ceil(cx+rx*1.5) do
    if x >= 0 and x < W and y >= 0 and y < H then
      local dx, dy = (x-cx)/rx, (y-cy)/ry
      local r = 1 + (K.noise(x, y, 7, seed) - 0.5) * rough * 2
      if dx*dx + dy*dy < r*r then m[y*W+x+1] = true end
    end
  end end
  return m
end
function K.terrain(f, ybot, x0, x1)
  local m = {}
  for x = x0 or 0, x1 or W-1 do for y = math.max(0, floor(f(x))), ybot do m[y*W+x+1] = true end end
  return m
end
function K.bez(p0, p1, p2, p3, n)
  local t = {}
  for i = 0, n do local s = i/n local u = 1-s
    t[#t+1] = { u^3*p0[1] + 3*u*u*s*p1[1] + 3*u*s*s*p2[1] + s^3*p3[1],
                u^3*p0[2] + 3*u*u*s*p1[2] + 3*u*s*s*p2[2] + s^3*p3[2] } end
  return t
end
function K.stroke(pts, w, m)
  m = m or {}
  for i = 1, #pts-1 do
    local a, b = pts[i], pts[i+1]
    local d = math.max(abs(b[1]-a[1]), abs(b[2]-a[2]), 1)
    for s = 0, math.ceil(d) do
      local t = s / math.ceil(d)
      local x, y = a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t
      local ww = type(w) == "function" and w((i-1+t)/(#pts-1)) or w
      ww = math.max(1, floor(ww + 0.5))
      local x0, y0 = floor(x - (ww-1)/2 + 0.5), floor(y - (ww-1)/2 + 0.5)
      for yy = y0, y0+ww-1 do for xx = x0, x0+ww-1 do
        if xx >= 0 and xx < W and yy >= 0 and yy < H then m[yy*W+xx+1] = true end end end
    end
  end
  return m
end
function K.bbox(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  K.each(m, function(x, y) if x < x0 then x0 = x end if y < y0 then y0 = y end if x > x1 then x1 = x end if y > y1 then y1 = y end end)
  return x0, y0, x1, y1
end

-- paint
function K.fill(m, hex) K.each(m, function(x, y) K.set(x, y, hex) end) end
-- ramp dark->light; light from upper-left; stepped noise texture (clusters, no dither)
function K.shade(m, ramp, o)
  o = o or {}
  local x0, y0, x1, y1 = K.bbox(m)
  if x0 > x1 then return end
  local w, h = math.max(1, x1-x0), math.max(1, y1-y0)
  local n = #ramp
  K.each(m, function(x, y)
    local u, v = (x-x0)/w, (y-y0)/h
    local val = (o.base or 0.6) - (o.lx or 0.35)*(u-0.5) - (o.ly or 0.45)*(v-0.5)
    val = val + (K.fbm(x*(o.sx or 1), y*(o.sy or 1), o.sc or 8, o.seed or 1) - 0.5) * (o.nz or 0.5)
    if o.fn then val = o.fn(x, y, val) end
    if o.rim ~= false then
      if not K.has(m, x-1, y) or not K.has(m, x, y-1) then val = val + (o.rimA or 0.2) end
      if not K.has(m, x+1, y) or not K.has(m, x, y+1) then val = val - (o.rimA or 0.2) end
    end
    local i = floor(val*n) + 1
    if i < 1 then i = 1 elseif i > n then i = n end
    K.set(x, y, ramp[i])
  end)
end
-- 1px edge on the mask's own border (not at canvas border); dirs: table of which neighbour sides count
function K.outline(m, hex, skipBottom)
  local todo = {}
  K.each(m, function(x, y)
    if x > 0 and x < W-1 and y > 0 and y < H-1 then
      if not K.has(m, x-1, y) or not K.has(m, x+1, y) or not K.has(m, x, y-1) or (not skipBottom and not K.has(m, x, y+1)) then
        todo[#todo+1] = {x, y} end
    end
  end)
  for _, p in ipairs(todo) do K.set(p[1], p[2], hex) end
end
-- dark separation lines between noise clumps inside a mask (leaf masses, rock facets)
function K.clumps(m, sc, seed, hex, thr)
  thr = thr or 0.5
  local function q(x, y) return K.noise(x, y, sc, seed) > thr end
  local todo = {}
  K.each(m, function(x, y)
    if q(x, y) and (not q(x+1, y) or not q(x, y+1)) and K.has(m, x+1, y) and K.has(m, x, y+1) then todo[#todo+1] = {x, y} end
  end)
  for _, p in ipairs(todo) do K.set(p[1], p[2], hex) end
end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function K.mix(h, t, a)
  local r, g, b = hx(h) local R, G, B = hx(t)
  local function c(u, v) local z = floor(u + (v-u)*a + 0.5) if z < 8 then z = 8 elseif z > 250 then z = 250 end return z end
  return string.format("#%02x%02x%02x", c(r, R), c(g, G), c(b, B))
end
function K.tint(m, t, a)
  K.each(m, function(x, y) local v = K.get(x, y) if v then K.set(x, y, K.mix(v, t, a)) end end)
end

function K.save(name)
  local HP = K.HP
  local c = HP.canvas{ w = W, h = H, scale = 1, name = name }
  for y = 0, H-1 do for x = 0, W-1 do c:put(x, y, buf[y*W+x+1] or K.INK) end end
  c:finish{ outline = false }
  HP.assertClean(c)
  local out = (app and app.params and app.params.out) or (ROOT .. "here-gate/places/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
  print("saved " .. out .. name .. ".png")
end
return K
