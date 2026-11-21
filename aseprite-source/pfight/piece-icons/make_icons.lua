-- aseprite -b --script make_icons.lua
-- Reads icons.jsonl, writes out/ico-<key>.png, .aseprite (32x32) and -s.png (20x20).
local SRC, OUT = 32, 20
local SCALE = OUT / SRC -- 0.625

local function rgba(hex)
  hex = tostring(hex or ""):gsub("#", "")
  if #hex ~= 6 then return nil end
  local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
  if not (r and g and b) then return nil end
  return app.pixelColor.rgba(r, g, b, 255)
end

local function round(v) return math.floor(v + 0.5) end

local function plot(img, x, y, c)
  if x >= 0 and y >= 0 and x < img.width and y < img.height then img:drawPixel(x, y, c) end
end

local function line(img, x0, y0, x1, y1, c)
  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    plot(img, x0, y0, c)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end

-- p = {shape,x,y,w,h,color} already in target-pixel units
local function drawPart(img, p, c)
  local x, y, w, h = p.x, p.y, p.w, p.h
  if p.shape == "rect" then
    for j = y, y + h - 1 do for i = x, x + w - 1 do plot(img, i, j, c) end end
  elseif p.shape == "circle" then -- filled ellipse inside the box
    local cx, cy, rx, ry = x + (w - 1) / 2, y + (h - 1) / 2, w / 2, h / 2
    for j = y, y + h - 1 do
      for i = x, x + w - 1 do
        local dx, dy = (i - cx) / rx, (j - cy) / ry
        if dx * dx + dy * dy <= 1 then plot(img, i, j, c) end
      end
    end
  elseif p.shape == "line" then -- (x,y) to (x+w,y+h), 1px
    line(img, x, y, x + w, y + h, c)
  elseif p.shape == "tri" then -- apex top-centre, base along the bottom of the box
    local ax = x + (w - 1) / 2
    for j = y, y + h - 1 do
      local t = h > 1 and (j - y) / (h - 1) or 1
      local half = t * (w - 1) / 2
      for i = math.ceil(ax - half - 1e-9), math.floor(ax + half + 1e-9) do plot(img, i, j, c) end
    end
  else
    return false
  end
  return true
end

-- convert a part to target size; k = 1 for 32px, SCALE for 20px (rounded edges, min 1px)
local function conv(p, k)
  local q = { shape = p.shape }
  if k == 1 then
    q.x, q.y, q.w, q.h = p.x, p.y, p.w, p.h
  elseif p.shape == "line" then
    q.x, q.y = round(p.x * k), round(p.y * k)
    q.w, q.h = round((p.x + p.w) * k) - q.x, round((p.y + p.h) * k) - q.y
  else
    q.x, q.y = round(p.x * k), round(p.y * k)
    q.w = math.max(1, round((p.x + p.w) * k) - q.x)
    q.h = math.max(1, round((p.y + p.h) * k) - q.y)
  end
  return q
end

local function render(parts, size, k)
  local img = Image(size, size, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  for _, p in ipairs(parts) do
    drawPart(img, conv(p, k), rgba(p.color))
  end
  return img
end

local function validate(o)
  if o == nil or type(o.key) ~= "string" or o.key == "" then return "missing key" end
  if o.parts == nil or #o.parts == 0 then return "no parts" end
  for i, p in ipairs(o.parts) do
    if p == nil then return "part " .. i .. " not an object" end
    for _, f in ipairs({ "x", "y", "w", "h" }) do
      if type(p[f]) ~= "number" then return "part " .. i .. " bad " .. f end
    end
    if not rgba(p.color) then return "part " .. i .. " bad color" end
    if not (p.shape == "rect" or p.shape == "line" or p.shape == "circle" or p.shape == "tri") then
      return "part " .. i .. " bad shape"
    end
  end
  return nil
end

local f = io.open("icons.jsonl", "r")
if not f then print("ERROR: icons.jsonl not found"); return end
local n, skipped = 0, 0
local lineNo = 0
for text in f:lines() do
  lineNo = lineNo + 1
  if text:match("%S") then
    local ok, o = pcall(json.decode, text)
    local err = (not ok or o == nil) and "invalid JSON" or validate(o)
    if err then
      skipped = skipped + 1
      print(("SKIP line %d: %s"):format(lineNo, err))
    else
      local key = o.key:gsub("[^%w%-_]", "_")
      local spr = Sprite(SRC, SRC, ColorMode.RGB)
      spr.cels[1].image = render(o.parts, SRC, 1)
      spr:saveAs("out/ico-" .. key .. ".aseprite"); print("wrote out/ico-" .. key .. ".aseprite")
      spr:saveCopyAs("out/ico-" .. key .. ".png"); print("wrote out/ico-" .. key .. ".png")
      spr:close()
      local s = Sprite(OUT, OUT, ColorMode.RGB)
      s.cels[1].image = render(o.parts, OUT, SCALE)
      s:saveAs("out/ico-" .. key .. "-s.png"); print("wrote out/ico-" .. key .. "-s.png")
      s:close()
      n = n + 1
    end
  end
end
f:close()
print(("done: %d icons, %d skipped"):format(n, skipped))
