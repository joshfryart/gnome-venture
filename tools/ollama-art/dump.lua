-- dump.lua: palette legend + bbox summary, and a character map of a PNG (one char per colour).
-- params: png=<path>  [x0 y0 x1 y1 = region]. No region: map printed only if the image is <= 96px wide.
local spr = app.open(app.params.png)
local img = Image(spr.spec)
img:drawSprite(spr, 1)
local pc = app.pixelColor
local P = app.params
local x0, y0 = tonumber(P.x0 or 0), tonumber(P.y0 or 0)
local x1, y1 = tonumber(P.x1 or img.width - 1), tonumber(P.y1 or img.height - 1)
local wantMap = P.x0 ~= nil or img.width <= 96
local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local map, legend, n = {}, {}, 0
local rows = {}
local bx0, by0, bx1, by1 = 1e9, 1e9, -1, -1
for y = 0, img.height - 1 do
  local r = {}
  for x = 0, img.width - 1 do
    local v = img:getPixel(x, y)
    if pc.rgbaA(v) == 0 then r[#r+1] = "."
    else
      bx0, by0, bx1, by1 = math.min(bx0, x), math.min(by0, y), math.max(bx1, x), math.max(by1, y)
      if not map[v] then
        n = n + 1
        map[v] = n <= #chars and chars:sub(n, n) or "?"
        legend[#legend+1] = string.format("%s=#%02x%02x%02x", map[v], pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
      end
      r[#r+1] = map[v]
    end
  end
  if y >= y0 and y <= y1 then rows[#rows+1] = table.concat(r):sub(x0 + 1, x1 + 1) end
end
print(string.format("size %dx%d  opaque bbox %d,%d..%d,%d  colours %d", img.width, img.height, bx0, by0, bx1, by1, n))
if wantMap then print(table.concat(rows, "\n")) end
print("legend: " .. table.concat(legend, " "))
