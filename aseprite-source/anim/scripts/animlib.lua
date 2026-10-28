-- animlib.lua: tiny frame-edit helpers for the Gnome Venture pilot animations.
-- Everything is pixel-exact and palette-preserving: frames are built only by MOVING, COPYING or
-- RECOLOURING pixels that already exist in the static image (plus a few hand-placed accent pixels
-- in colours taken from that same image), so there is never any blending or new colour.
-- Units: "cells". Scenes are drawn on a 2px grid (S=2, 72x54 cells); icons are S=1.
local A = {}
local REPO = "C:/Users/hello/OneDrive/Desktop/claude/Gnome Venture/gnome-venture/"
A.REPO = REPO

local function rgba(r, g, b, a) return app.pixelColor.rgba(r, g, b, a or 255) end
function A.hex(h)
  h = h:gsub("#", "")
  return rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255)
end
function A.unhex(v)
  return string.format("#%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v))
end

-- Pix: flat table, 0-based x,y. alpha 0 pixels are stored as 0.
local Pix = {}
Pix.__index = Pix
function A.load(path, S)
  local im = Image{ fromFile = path }
  local p = setmetatable({ w = im.width, h = im.height, S = S or 1, d = {} }, Pix)
  for y = 0, im.height - 1 do
    for x = 0, im.width - 1 do
      local v = im:getPixel(x, y)
      if app.pixelColor.rgbaA(v) == 0 then v = 0 end
      p.d[y * p.w + x] = v
    end
  end
  return p
end
function Pix:copy()
  local q = setmetatable({ w = self.w, h = self.h, S = self.S, d = {} }, Pix)
  for i = 0, self.w * self.h - 1 do q.d[i] = self.d[i] end
  return q
end
function Pix:get(x, y)
  if x < 0 or y < 0 or x >= self.w or y >= self.h then return 0 end
  return self.d[y * self.w + x]
end
function Pix:put(x, y, v)
  if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
  self.d[y * self.w + x] = v
end
-- cell accessors (top-left pixel of the cell)
function Pix:cget(cx, cy) return self:get(cx * self.S, cy * self.S) end
function Pix:cput(cx, cy, v)
  if type(v) == "string" then v = A.hex(v) end
  for j = 0, self.S - 1 do for i = 0, self.S - 1 do self:put(cx * self.S + i, cy * self.S + j, v) end end
end
function Pix:fillbox(b, v)
  for cy = b[2], b[4] do for cx = b[1], b[3] do self:cput(cx, cy, v) end end
end

local function predOf(p)
  if p == nil then return function(v) return v ~= 0 end end
  if type(p) == "function" then return p end
  local set = {}
  for _, h in ipairs(p) do set[A.hex(h)] = true end
  return function(v) return set[v] == true end
end
A.predOf = predOf

-- Move the pixels inside box={cx0,cy0,cx1,cy1} (cells, inclusive) that satisfy pred by (dx,dy) cells.
-- bg: "L" or "R" (sample the cell just outside the box on that side, same row), "U"/"D" (same column),
-- or an integer colour (0 = transparent). keepLast: leave the box's bottom row of the object in place
-- (so a moved-up top part stays joined = a stretch). keepFirst: likewise for the top row.
function Pix:move(o)
  local b = o.box
  local pred = predOf(o.pred)
  local objs = {}
  for cy = b[2], b[4] do
    for cx = b[1], b[3] do
      local v = self:cget(cx, cy)
      if v ~= 0 and pred(v, cx, cy) then objs[#objs + 1] = { cx, cy, v } end
    end
  end
  local src = self:copy()
  local function bgAt(cx, cy)
    local m = o.bg
    if type(m) == "number" then return m end
    if type(m) == "function" then return m(src, cx, cy) end
    if m == "L" then return self:cget(b[1] - 1, cy) end
    if m == "R" then return self:cget(b[3] + 1, cy) end
    if m == "U" then return self:cget(cx, b[2] - 1) end
    if m == "D" then return self:cget(cx, b[4] + 1) end
    return 0
  end
  for _, ob in ipairs(objs) do
    local cx, cy = ob[1], ob[2]
    local isKeep = (o.keepLast and cy == b[4]) or (o.keepFirst and cy == b[2])
    if not isKeep then self:cput(cx, cy, bgAt(cx, cy)) end
  end
  for _, ob in ipairs(objs) do
    self:cput(ob[1] + (o.dx or 0), ob[2] + (o.dy or 0), ob[3])
  end
end

-- bg helper for Pix:move: nearest cell in the same row (scanning right then left) whose colour is in hexset.
function A.bgNear(hexset, maxd)
  local set = {}
  for _, h in ipairs(hexset) do set[A.hex(h)] = true end
  return function(src, cx, cy)
    for d = 1, maxd or 12 do
      local v = src:cget(cx + d, cy)
      if set[v] then return v end
      v = src:cget(cx - d, cy)
      if set[v] then return v end
    end
    return src:cget(cx, cy)
  end
end

-- Recolour pixels in a box: map = { ["#aaaaaa"] = "#bbbbbb" }. mask optional function(cx,cy)->bool.
function Pix:recolor(box, map, mask)
  local m = {}
  for k, v in pairs(map) do m[A.hex(k)] = A.hex(v) end
  for cy = box[2], box[4] do
    for cx = box[1], box[3] do
      local v = self:cget(cx, cy)
      if m[v] and (not mask or mask(cx, cy)) then self:cput(cx, cy, m[v]) end
    end
  end
end

-- ASCII stamp in cells. legend: char -> "#hex" or 0.   '.' and ' ' are skipped.
function Pix:stamp(rows, cx, cy, legend)
  for j, r in ipairs(rows) do
    for i = 1, #r do
      local ch = r:sub(i, i)
      if ch ~= "." and ch ~= " " then
        local c = legend[ch]
        self:cput(cx + i - 1, cy + j - 1, c)
      end
    end
  end
end

-- Pixel-level row shear for 1px icons: shifts rows y0..y1 by fdx(y); transparent fill.
function Pix:shearRows(y0, y1, fdx)
  local rows = {}
  for y = y0, y1 do
    local r = {}
    for x = 0, self.w - 1 do r[x] = self:get(x, y) end
    rows[y] = r
  end
  for y = y0, y1 do
    local dx = fdx(y)
    for x = 0, self.w - 1 do self:put(x, y, 0) end
    for x = 0, self.w - 1 do
      local v = rows[y][x]
      if v ~= 0 then self:put(x + dx, y, v) end
    end
  end
end

-- Nearest-neighbour rescale about (cx,cy) px, kx/ky factors (1 = unchanged). Returns a new Pix.
function Pix:scaled(cx, cy, kx, ky)
  local q = self:copy()
  for y = 0, self.h - 1 do
    for x = 0, self.w - 1 do
      local sx = math.floor(cx + (x - cx) / kx + 0.5)
      local sy = math.floor(cy + (y - cy) / ky + 0.5)
      q:put(x, y, self:get(sx, sy))
    end
  end
  return q
end
-- Whole-image shift by (dx,dy) px, transparent fill. Returns a new Pix.
function Pix:shifted(dx, dy)
  local q = self:copy()
  for y = 0, self.h - 1 do
    for x = 0, self.w - 1 do q:put(x, y, self:get(x - dx, y - dy)) end
  end
  return q
end
-- Rows y0..y1 only, shifted as a rigid band by (dx,dy) (transparent fill where vacated).
function Pix:band(y0, y1, dx, dy)
  local src = self:copy()
  for y = y0, y1 do for x = 0, self.w - 1 do self:put(x, y, 0) end end
  for y = y0, y1 do
    for x = 0, self.w - 1 do
      local v = src:get(x, y)
      if v ~= 0 then self:put(x + dx, y + dy, v) end
    end
  end
end

-- Components of pixels matching pred (4-connected, in cells). Returns list of {x0,y0,x1,y1,n}.
function Pix:components(pred)
  pred = predOf(pred)
  local S = self.S
  local cw, ch = self.w // S, self.h // S
  local seen, out = {}, {}
  for cy = 0, ch - 1 do
    for cx = 0, cw - 1 do
      local k = cy * cw + cx
      if not seen[k] and pred(self:cget(cx, cy)) then
        local st, bb = { { cx, cy } }, { cx, cy, cx, cy, 0 }
        seen[k] = true
        while #st > 0 do
          local c = table.remove(st)
          bb[1] = math.min(bb[1], c[1]); bb[2] = math.min(bb[2], c[2])
          bb[3] = math.max(bb[3], c[1]); bb[4] = math.max(bb[4], c[2]); bb[5] = bb[5] + 1
          for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
            local nx, ny = c[1] + d[1], c[2] + d[2]
            if nx >= 0 and ny >= 0 and nx < cw and ny < ch and not seen[ny * cw + nx] and pred(self:cget(nx, ny)) then
              seen[ny * cw + nx] = true
              st[#st + 1] = { nx, ny }
            end
          end
        end
        out[#out + 1] = bb
      end
    end
  end
  return out
end

-- Export: frames = list of Pix. Writes strip PNG + .aseprite (one frame each, 1/6 s).
function A.export(name, frames, stripPath, asePath)
  local w, h, n = frames[1].w, frames[1].h, #frames
  local strip = Image(w * n, h, ColorMode.RGBA)
  local spr = Sprite(w, h, ColorMode.RGBA)
  for i = 1, n - 1 do spr:newFrame() end
  local layer = spr.layers[1]
  layer.name = "frame"
  for i, f in ipairs(frames) do
    local im = Image(w, h, ColorMode.RGBA)
    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local v = f.d[y * w + x]
        im:putPixel(x, y, v)
        strip:putPixel((i - 1) * w + x, y, v)
      end
    end
    spr:newCel(layer, i, im, Point(0, 0))
    spr.frames[i].duration = 1 / 6
  end
  strip:saveAs(stripPath)
  spr:saveAs(asePath)
  spr:close()
  print(string.format("%s: %d frames %dx%d strip %dx%d", name, n, w, h, w * n, h))
end

-- Count colours in frames that are not in the static image (should be 0).
function A.offPalette(static, frames, extra)
  local ok = {}
  for _, h in ipairs(extra or {}) do ok[A.hex(h)] = true end
  for i = 0, static.w * static.h - 1 do ok[static.d[i]] = true end
  local bad = {}
  for fi, f in ipairs(frames) do
    for i = 0, f.w * f.h - 1 do
      if not ok[f.d[i]] then bad[A.unhex(f.d[i]) .. "@" .. fi] = true end
    end
  end
  local n = 0
  for k in pairs(bad) do n = n + 1; print("  new colour", k) end
  return n
end
return A
