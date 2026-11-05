-- shared helpers for flowers P2_F4 vessels/packet (not an asset)
local V = {}
V.INK = {0x2b, 0x1c, 0x26}
function V.hex(h) return {tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16)} end
function V.ramp(t) local r = {} for i, h in ipairs(t) do r[i] = V.hex(h) end return r end
function V.layer(w, h) return {w = w, h = h, p = {}} end
function V.set(L, x, y, c) if x >= 0 and y >= 0 and x < L.w and y < L.h then L.p[y * L.w + x] = c end end
function V.get(L, x, y) if x < 0 or y < 0 or x >= L.w or y >= L.h then return nil end return L.p[y * L.w + x] end
function V.clamp(i, a, b) if i < a then return a elseif i > b then return b end return i end
function V.hash(x, y, s)
  local h = (x * 374761393 + y * 668265263 + s * 2147483647) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return ((h ~ (h >> 16)) % 1000) / 1000
end
function V.ell(x, y, cx, cy, rx, ry)
  local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
  return dx * dx + dy * dy <= 1
end
function V.interp(keys, y)
  if y < keys[1][1] or y > keys[#keys][1] then return nil end
  for i = 1, #keys - 1 do
    local a, b = keys[i], keys[i + 1]
    if y >= a[1] and y <= b[1] then
      local t = (y - a[1]) / (b[1] - a[1]); t = t * t * (3 - 2 * t)
      return a[2] + (b[2] - a[2]) * t
    end
  end
end
-- 1px ink outline on empty pixels 4-adjacent to solid(x,y); rows y0..y1; optional filter
function V.outline(L, solid, y0, y1, filt)
  local add = {}
  for y = y0, y1 do for x = 0, L.w - 1 do
    if not V.get(L, x, y) and not solid(x, y) and (not filt or filt(x, y)) then
      if solid(x-1,y) or solid(x+1,y) or solid(x,y-1) or solid(x,y+1) then add[#add+1] = {x, y} end
    end
  end end
  for _, a in ipairs(add) do V.set(L, a[1], a[2], V.INK) end
end
-- chebyshev distance to nearest non-solid pixel (1 = adjacent), capped
function V.dist(solid, x, y, maxd)
  for k = 1, maxd do
    for i = -k, k do
      if not solid(x + i, y - k) or not solid(x + i, y + k) or not solid(x - k, y + i) or not solid(x + k, y + i) then return k end
    end
  end
  return maxd + 1
end
function V.shadow(L, cx, cy, rx, ry)
  for y = 0, L.h - 1 do for x = 0, L.w - 1 do
    if not V.get(L, x, y) then
      local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
      local d = dx * dx + dy * dy
      if d <= 1 then V.set(L, x, y, d <= 0.4 and V.hex("#5e3f30") or V.hex("#8a6a52")) end
    end
  end end
end
function V.toImage(L)
  local img = Image(L.w, L.h, ColorMode.RGB)
  for k, c in pairs(L.p) do img:putPixel(k % L.w, k // L.w, app.pixelColor.rgba(c[1], c[2], c[3], 255)) end
  return img
end
-- layers: list of {name=, L=}; writes <name>-<layer>.png per layer when multi, else <name>.png; plus <name>.aseprite
function V.save(out, name, layers)
  local w, h = layers[1].L.w, layers[1].L.h
  local s = Sprite(w, h, ColorMode.RGB)
  for i, l in ipairs(layers) do
    local img = V.toImage(l.L)
    local ly = s.layers[1]
    if i == 1 then s.cels[1].image:drawImage(img, Point(0, 0)) else ly = s:newLayer(); s:newCel(ly, 1, img, Point(0, 0)) end
    ly.name = l.name
    local t = Sprite(w, h, ColorMode.RGB)
    t.cels[1].image:drawImage(img, Point(0, 0))
    t:saveCopyAs(out .. (#layers > 1 and (name .. "-" .. l.name) or name) .. ".png")
    t:close()
  end
  s:saveAs(out .. name .. ".aseprite")
end
return V
