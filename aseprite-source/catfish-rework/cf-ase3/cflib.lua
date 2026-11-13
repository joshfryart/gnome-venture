-- cflib.lua: tiny layered pixel canvas for the Cat Fish Aseprite pass (hand-authored spans/polygons, hard pixels only).
-- Tones are one-char keys (grey coat ramp + fixed accents) or literal '#rrggbb' strings. Every pixel remembers the
-- layer that painted it last; save() writes a layered .aseprite (outline/body/shade/light/rim/detail) + flat PNG.
local L = {}
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local function K(x, y) return (y + 64) * 1024 + (x + 64) end
local function XY(k) return k % 1024 - 64, k // 1024 - 64 end
L.K, L.XY = K, XY
L.HEX = { ['#'] = "#2b1c26", D = "#3d3654", s = "#57516f", r = "#646691", b = "#6e6684", m = "#8a859b", l = "#aca7b9",
  L = "#cdc9d3", g = "#f1ebe3", c = "#f2e4c0", u = "#2a1a10", U = "#4a2c1a", W = "#74462a", p = "#e8909e", P = "#c66a80" }
local LAYER_OF = { ['#'] = "outline", D = "shade", s = "shade", b = "shade", r = "rim", m = "body", l = "light", L = "light", g = "light" }
L.LAYER_OF = LAYER_OF
L.LADDER = { D = 1, s = 2, r = 2, b = 3, m = 4, l = 5, L = 6, g = 7 }
L.BYIDX = { "D", "s", "b", "m", "l", "L", "g" }
function L.step(t, n) local i = L.LADDER[t] if not i then return t end return L.BYIDX[max(1, min(7, i + n))] end
function L.isCoat(t) return L.LADDER[t] ~= nil end

-- masks ------------------------------------------------------------------------------------------
local M = {} M.__index = M
function L.mask() return setmetatable({ s = {} }, M) end
function M:set(x, y) self.s[K(x, y)] = true return self end
function M:unset(x, y) self.s[K(x, y)] = nil return self end
function M:has(x, y) return self.s[K(x, y)] == true end
function M:add(o) for k in pairs(o.s) do self.s[k] = true end return self end
function M:cut(o) for k in pairs(o.s) do self.s[k] = nil end return self end
function M:clip(o) for k in pairs(self.s) do if not o.s[k] then self.s[k] = nil end end return self end
function M:copy() local n = L.mask() for k in pairs(self.s) do n.s[k] = true end return n end
function M:keys() local ks = {} for k in pairs(self.s) do ks[#ks + 1] = k end table.sort(ks) return ks end
function M:each(f) for _, k in ipairs(self:keys()) do local x, y = XY(k) f(x, y) end end
function M:count() local n = 0 for _ in pairs(self.s) do n = n + 1 end return n end
function M:shift(dx, dy) local n = L.mask() self:each(function(x, y) n:set(x + dx, y + dy) end) return n end
function M:grow(r)
  local cur = self:copy()
  for _ = 1, (r or 1) do local nx = cur:copy() cur:each(function(x, y) nx:set(x + 1, y) nx:set(x - 1, y) nx:set(x, y + 1) nx:set(x, y - 1) end) cur = nx end
  return cur
end
function M:edge() local n = L.mask() self:each(function(x, y) if not (self:has(x + 1, y) and self:has(x - 1, y) and self:has(x, y + 1) and self:has(x, y - 1)) then n:set(x, y) end end) return n end
function M:filter(f) local n = L.mask() self:each(function(x, y) if f(x, y) then n:set(x, y) end end) return n end

function L.spans(rows, ox, oy)   -- rows[y] = {x0,x1, x0,x1, ...} inclusive
  local m = L.mask()
  for y, r in pairs(rows) do for i = 1, #r, 2 do for x = r[i], r[i + 1] do m:set(x + (ox or 0), y + (oy or 0)) end end end
  return m
end
function L.rect(x0, y0, x1, y1) local m = L.mask() for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end return m end
function L.ellipse(cx, cy, rx, ry)
  local m = L.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    if dx * dx + dy * dy <= 1.0 then m:set(x, y) end
  end end
  return m
end
function L.poly(pts)    -- scanline at pixel centres
  local m = L.mask()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0 = min(y0, p[2]) y1 = max(y1, p[2]) end
  for y = floor(y0), math.ceil(y1) do
    local xs = {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= y and b[2] > y) or (b[2] <= y and a[2] > y) then xs[#xs + 1] = a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1]) end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do for x = math.ceil(xs[i] - 0.001), floor(xs[i + 1] + 0.001) do m:set(x, y) end end
  end
  return m
end
-- Catmull-Rom curve through pts; returns list of {x,y,t}
function L.curve(pts, step)
  local out = {}
  local n = #pts
  local seg = n - 1
  for i = 1, seg do
    local p0, p1, p2, p3 = pts[max(1, i - 1)], pts[i], pts[i + 1], pts[min(n, i + 2)]
    local steps = 24
    for j = 0, steps - 1 do
      local t = j / steps
      local t2, t3 = t * t, t * t * t
      local function cr(a, b, c, d) return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3) end
      out[#out + 1] = { cr(p0[1], p1[1], p2[1], p3[1]), cr(p0[2], p1[2], p2[2], p3[2]), (i - 1 + t) / seg }
    end
  end
  out[#out + 1] = { pts[n][1], pts[n][2], 1 }
  return out
end
-- tube along a curve; r(t) radius; returns mask, T (param per pixel)
function L.tube(pts, rf)
  local m, T, best = L.mask(), {}, {}
  for _, p in ipairs(L.curve(pts)) do
    local r = rf(p[3])
    for y = floor(p[2] - r) - 1, floor(p[2] + r) + 1 do for x = floor(p[1] - r) - 1, floor(p[1] + r) + 1 do
      local d = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
      if d <= r * r then
        local k = K(x, y) m.s[k] = true
        if not best[k] or d < best[k] then best[k] = d T[k] = p[3] end
      end
    end end
  end
  return m, T
end
-- 1px pixel-perfect line through points (Bresenham per segment)
function L.line(pts)
  local m = L.mask()
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      m:set(x0, y0)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy x0 = x0 + sx end
      if e2 <= dx then err = err + dx y0 = y0 + sy end
    end
  end
  return m
end
-- stamp: rows of chars at (x0,y0); '.' or ' ' skip
function L.stamp(rows, x0, y0)
  local out = {}
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if ch ~= '.' and ch ~= ' ' then out[#out + 1] = { x0 + i - 1, y0 + j - 1, ch } end
  end end
  return out
end

-- canvas -----------------------------------------------------------------------------------------
local C = {} C.__index = C
function L.canvas(w, h, ordered) return setmetatable({ w = w, h = h, t = {}, ly = {}, obj = L.mask(), lock = {}, order = ordered and {} or nil, seen = {} }, C) end
function C:put(x, y, t, layer, notobj)
  if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
  local k = K(x, y)
  if self.lock[k] then return end
  self.t[k] = t
  self.ly[k] = self.curLayer or layer or LAYER_OF[t] or "detail"
  if self.order and not self.seen[self.ly[k]] then self.seen[self.ly[k]] = true self.order[#self.order + 1] = self.ly[k] end
  if notobj then self.obj.s[k] = nil else self.obj.s[k] = true end
end
function C:get(x, y) return self.t[K(x, y)] end
function C:isObj(x, y) return self.obj.s[K(x, y)] == true end
function C:hex(t) return L.HEX[t] or t end
function C:stamp(list, layer) for _, p in ipairs(list) do self:put(p[1], p[2], p[3], layer or "detail") end end

local DR = { { 1, 0 }, { 0, 1 }, { 1, 1 } }
local UL = { { -1, 0 }, { 0, -1 }, { -1, -1 } }
local function dist(m, x, y, dirs, maxk)
  local best = maxk + 1
  for _, d in ipairs(dirs) do
    for k = 1, maxk do
      if not m.s[K(x + d[1] * k, y + d[2] * k)] then if k < best then best = k end break end
    end
  end
  return best
end
L.dist, L.DR, L.UL = dist, DR, UL

-- AO where a front part meets what is already painted, then the part's own offset-band shading.
-- o.ws shade band (lower-right), o.wl light band (upper-left), o.ramp maps 'D s b m l L g' to literal colours (fish)
function C:part(m, o)
  o = o or {}
  local ws, wl = o.ws or 2, o.wl or 2
  if o.ao ~= false then
    local done = {}
    m:each(function(x, y)
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local qx, qy = x + d[1], y + d[2]
        local k = K(qx, qy)
        if not m.s[k] and not done[k] and self.obj.s[k] and L.isCoat(self.t[k]) and not o.noao then
          done[k] = true
          local below = (d[1] == 1 or d[2] == 1)   -- q is right of / below the front part
          local tgt = below and 's' or 'b'          -- flat AO tone (never lighter than what is there)
          if L.LADDER[self.t[k]] > L.LADDER[tgt] then self:put(qx, qy, tgt) end
        end
      end
    end)
    if o.cast then  -- one more soft row under the part
      m:each(function(x, y)
        local qx, qy = x, y + 2
        local k = K(qx, qy)
        if not m.s[k] and not m.s[K(x, y + 1)] then return end
        if not m.s[k] and not done[k] and self.obj.s[k] and L.isCoat(self.t[k]) and L.LADDER[self.t[k]] > 3 then done[k] = true self:put(qx, qy, 'b') end
      end)
    end
  end
  m:each(function(x, y)
    local dr = dist(m, x, y, DR, ws + 2)
    local ul = dist(m, x, y, UL, wl + 1)
    local t
    if dr <= ws then t = 's' elseif dr == ws + 1 then t = 'b' elseif ul <= 1 then t = 'L' elseif ul <= wl then t = 'l' else t = 'm' end
    if o.lift then t = L.step(t, o.lift) end
    if o.ramp then self:put(x, y, o.ramp[t] or t, o.layer or LAYER_OF[t]) else self:put(x, y, t, o.layer) end
  end)
end
function C:fill(m, t, layer, notobj) m:each(function(x, y) self:put(x, y, t, layer, notobj) end) end
-- tone shift inside a mask (coat tones only)
function C:shiftTone(m, n, layer) m:each(function(x, y) local t = self:get(x, y) if t and L.isCoat(t) then self:put(x, y, L.step(t, n), layer) end end) end

function C:contact(gy)   -- bottom pixels resting on the ground -> deep
  self.obj:each(function(x, y)
    if y >= gy - 1 and not self.obj:has(x, y + 1) and L.isCoat(self:get(x, y)) then self:put(x, y, 'D') end
  end)
end
function C:rim(gy)       -- cool reflected rim on the lower-right silhouette
  local list = {}
  self.obj:each(function(x, y)
    local t = self:get(x, y)
    if t == 's' or t == 'b' or t == 'D' then
      if not self.obj:has(x + 1, y) and self.obj:has(x - 1, y) then list[#list + 1] = { x, y }
      elseif t ~= 'D' and not self.obj:has(x, y + 1) and y < (gy or 99) - 2 and self.obj:has(x, y - 1) and self.obj:has(x + 1, y) then list[#list + 1] = { x, y } end
    end
  end)
  for _, p in ipairs(list) do self:put(p[1], p[2], 'r') end
end
function C:outline()
  local ring = L.mask()
  self.obj:each(function(x, y)
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      if not self.obj:has(x + d[1], y + d[2]) then ring:set(x + d[1], y + d[2]) end
    end
  end)
  ring:each(function(x, y) if x >= 0 and y >= 0 and x < self.w and y < self.h then
    local k = K(x, y) self.t[k] = '#' self.ly[k] = "outline"
    if self.order and not self.seen["outline"] then self.seen["outline"] = true self.order[#self.order + 1] = "outline" end end end)
end
function C:spurs()   -- report silhouette pixels with <=1 4-neighbour (jaggy tips)
  local n = {}
  self.obj:each(function(x, y)
    local c = 0
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do if self.obj:has(x + d[1], y + d[2]) then c = c + 1 end end
    if c <= 1 then n[#n + 1] = x .. "," .. y end
  end)
  return n
end
function C:colours() local s, n = {}, 0 for _, t in pairs(self.t) do local h = self:hex(t) if not s[h] then s[h] = true n = n + 1 end end return n end

local ORDER = { "outline", "body", "shade", "rim", "light", "detail" }
local function rgba(h) return app.pixelColor.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
function C:save(dir, name, flatOnly)
  local flat = Image(self.w, self.h, ColorMode.RGB)
  if not flatOnly then
    local spr = Sprite(self.w, self.h, ColorMode.RGB)
    local layers, imgs = {}, {}
    local ORDER = self.order or ORDER
    spr.layers[1].name = ORDER[1] layers[ORDER[1]] = spr.layers[1]
    for i = 2, #ORDER do local ly = spr:newLayer() ly.name = ORDER[i] layers[ORDER[i]] = ly end
    for _, n in ipairs(ORDER) do imgs[n] = Image(self.w, self.h, ColorMode.RGB) end
    for k, t in pairs(self.t) do
      local x, y = XY(k)
      imgs[self.ly[k] or "detail"]:drawPixel(x, y, rgba(self:hex(t)))
    end
    for _, n in ipairs(ORDER) do spr:newCel(layers[n], 1, imgs[n], Point(0, 0)) end
    spr:saveAs(dir .. name .. ".aseprite")
    spr:close()
  end
  for k, t in pairs(self.t) do local x, y = XY(k) flat:drawPixel(x, y, rgba(self:hex(t))) end
  flat:saveAs(dir .. name .. ".png")
end
return L
