-- Route mockup sprites: tiny shared helpers (Stitched Toy, Part D + addenda).
-- Hard pixels only. Shapes are filled, then shaded (one lower-right crescent, rim upper-left, gloss),
-- then `outline` adds the selective umber edge and `border` the 1 px #000000 sticker border.
local L = {}

function L.hex(h)
  h = h:gsub("#", "")
  return Color{ r = tonumber(h:sub(1,2),16), g = tonumber(h:sub(3,4),16), b = tonumber(h:sub(5,6),16), a = 255 }
end

local pc = app.pixelColor
local cache = {}
local function C(h) if not cache[h] then cache[h] = L.hex(h) end return cache[h] end
L.C = C

function L.new(w, h)
  local spr = Sprite(w, h, ColorMode.RGB)
  return spr, spr.cels[1].image
end

function L.px(img, x, y, h)
  if x >= 0 and y >= 0 and x < img.width and y < img.height then img:drawPixel(x, y, C(h)) end
end

function L.solid(img, x, y)
  if x < 0 or y < 0 or x >= img.width or y >= img.height then return false end
  return pc.rgbaA(img:getPixel(x, y)) > 0
end

function L.get(img, x, y)
  local v = img:getPixel(x, y)
  return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
end

-- ascii rows; legend char -> hex; "." / space = skip
function L.rows(img, x0, y0, rows, legend)
  for y = 1, #rows do
    local r = rows[y]
    for x = 1, #r do
      local ch = r:sub(x, x)
      if legend[ch] then L.px(img, x0 + x - 1, y0 + y - 1, legend[ch]) end
    end
  end
end

function L.rect(img, x, y, w, h, col)
  for j = y, y + h - 1 do for i = x, x + w - 1 do L.px(img, i, j, col) end end
end

local function inEl(x, y, cx, cy, rx, ry)
  local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
  return dx * dx + dy * dy <= 1
end
L.inEl = inEl

-- A shaded ellipse "part". ramp = {gloss=, rim=, base=, bounce=, shade=, deep=}
-- k = crescent shift (default 2). glossAt = {x,y} optional comma position (defaults upper-left).
function L.blob(img, cx, cy, rx, ry, ramp, o)
  o = o or {}
  local k = o.k or math.max(1, math.floor(math.min(rx, ry) / 3 + 0.5))
  local pts = {}
  for y = math.floor(cy - ry) - 1, math.ceil(cy + ry) + 1 do
    for x = math.floor(cx - rx) - 1, math.ceil(cx + rx) + 1 do
      if inEl(x, y, cx, cy, rx, ry) then
        local col = ramp.base
        if not inEl(x, y, cx - k, cy - k, rx, ry) then
          col = ramp.shade
          if ramp.deep and not inEl(x, y, cx - k * 0.5, cy - k * 0.5, rx, ry) and (rx > 5) then col = ramp.deep end
        end
        pts[#pts + 1] = { x, y, col }
      end
    end
  end
  for _, p in ipairs(pts) do L.px(img, p[1], p[2], p[3]) end
  -- rim: upper-left edge pixels
  if ramp.rim then
    for _, p in ipairs(pts) do
      local x, y = p[1], p[2]
      if (not inEl(x - 1, y, cx, cy, rx, ry) or not inEl(x, y - 1, cx, cy, rx, ry)) and (x + 0.5 - cx) + (y + 0.5 - cy) < -rx * 0.4 then
        L.px(img, x, y, ramp.rim)
      end
    end
  end
  -- bounce: 1 px just inside the lower-right edge
  if ramp.bounce and rx >= 4 then
    for _, p in ipairs(pts) do
      local x, y = p[1], p[2]
      if (not inEl(x + 1, y, cx, cy, rx, ry) or not inEl(x, y + 1, cx, cy, rx, ry)) and (x + 0.5 - cx) + (y + 0.5 - cy) > rx * 0.5 then
        L.px(img, x, y, ramp.bounce)
      end
    end
  end
  -- gloss comma
  if ramp.gloss and o.gloss ~= false then
    local gx = math.floor(cx - rx * 0.45 + 0.5)
    local gy = math.floor(cy - ry * 0.45 + 0.5)
    if rx >= 5 then
      L.px(img, gx, gy, ramp.gloss); L.px(img, gx + 1, gy - 1, ramp.gloss); L.px(img, gx, gy + 1, ramp.gloss)
      if ramp.dot then L.px(img, gx + 2, gy - 1, ramp.dot) end
    else
      L.px(img, gx, gy, ramp.gloss)
    end
  end
end

-- selective outline (Part D): grows `w` px around everything solid; colour by s = (x-cx)+(y-cy)
function L.outline(img, w, lr)
  w = w or 1
  local W, H = img.width, img.height
  local cx, cy = W / 2, H / 2
  local span = (W + H) / 2
  for pass = 1, w do
    local add = {}
    for y = 0, H - 1 do for x = 0, W - 1 do
      if not L.solid(img, x, y) and (L.solid(img, x-1, y) or L.solid(img, x+1, y) or L.solid(img, x, y-1) or L.solid(img, x, y+1)) then
        local s = (x - cx) + (y - cy)
        local col = "#2a1a10"
        if s < -0.28 * span then col = "#74462a" elseif s < -0.03 * span then col = "#4a2c1a" end
        add[#add + 1] = { x, y, col }
      end
    end end
    for _, p in ipairs(add) do L.px(img, p[1], p[2], p[3]) end
  end
  if lr then   -- one extra px on the lower right
    local add = {}
    for y = 0, H - 1 do for x = 0, W - 1 do
      if not L.solid(img, x, y) and (L.solid(img, x-1, y) or L.solid(img, x, y-1)) and (x - cx) + (y - cy) > 0.2 * span then
        add[#add + 1] = { x, y }
      end
    end end
    for _, p in ipairs(add) do L.px(img, p[1], p[2], "#2a1a10") end
  end
end

-- 1 px pure black sticker border on 4-adjacent transparent pixels (the batch.py post-pass)
function L.border(img)
  local add = {}
  for y = 0, img.height - 1 do for x = 0, img.width - 1 do
    if not L.solid(img, x, y) and (L.solid(img, x-1, y) or L.solid(img, x+1, y) or L.solid(img, x, y-1) or L.solid(img, x, y+1)) then
      add[#add + 1] = { x, y }
    end
  end end
  for _, p in ipairs(add) do L.px(img, p[1], p[2], "#000000") end
end

L.SRC = (app.params["src"] or ".") .. "/"
L.OUT = (app.params["out"] or ".") .. "/"
function L.save(spr, name)
  app.fs.makeAllDirectories(L.SRC); app.fs.makeAllDirectories(L.OUT)
  spr:saveAs(L.SRC .. name .. ".aseprite")
  spr:saveCopyAs(L.OUT .. name .. ".png")
  spr:close()
end

-- ramps (gvlib brief)
L.R = {
  red   = { gloss="#ff9158", dot="#ffc27a", rim="#f2793a", base="#dd3a2a", bounce="#b8452f", shade="#ae2a2a", deep="#6b1b2c" },
  gold  = { gloss="#fff1c8", rim="#f5cf6a", base="#e8a317", bounce="#d0862a", shade="#b8661a", deep="#7a3a14" },
  thread= { gloss="#fff1c8", rim="#fff1c8", base="#f5cf6a", bounce="#d0862a", shade="#e8a317", deep="#b8661a" },
  stone = { gloss="#f1ece0", rim="#c9c5bc", base="#8b8f96", bounce="#6e6a86", shade="#5b6470", deep="#3e3a52" },
  wood  = { gloss="#ecc58a", rim="#d9a660", base="#b07a45", bounce="#a8582f", shade="#8a4f2a", deep="#5e2f1e" },
  moss  = { gloss="#c8d77a", rim="#a4b86a", base="#7ab55c", bounce="#6a9a3a", shade="#4a8a3e", deep="#2f5a2a" },
  water = { gloss="#c8ecdc", rim="#8fcbd8", base="#3f8fb0", bounce="#5a86b8", shade="#2f6290", deep="#2a3c6c" },
  dusk  = { gloss="#a894dc", rim="#7b66b4", base="#3e2f66", bounce="#54447f", shade="#291d4a", deep="#291d4a" },
  felt  = { gloss="#9a6b3f", rim="#74462a", base="#4a2c1a", bounce="#4a2c1a", shade="#3d2a1c", deep="#2a1a10" },
}

-- 2-on 1-off thread seam along a list of points
function L.seam(img, pts, col, phase)
  phase = phase or 0
  for i, p in ipairs(pts) do
    if (i - 1 + phase) % 3 ~= 2 then L.px(img, p[1], p[2], col or "#f5cf6a") end
  end
end

return L
