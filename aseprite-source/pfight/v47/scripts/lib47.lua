-- lib47.lua : tiny hard-pixel raster + piece geometry for the 56x47 puzzle pieces (Aseprite 1.3 Lua)
local M = {}
M.INK, M.CREAM, M.CREAMSH = 0x2a1a10, 0xfff1c8, 0xd9bd7e
M.GOLD, M.GOLDSH = 0xf6c453, 0xb07a10
M.FAM = { body = 0xe0574a, mind = 0xa982ec, craft = 0xf0b429 }
M.FAMLIGHT = { body = 0xf08a7c, mind = 0xc9aef6, craft = 0xf9d56e }
M.ERASE = 0xff00ff
M.TYPES = {  -- from game/assets/img/pfight/parts/atlas.json (base / light / shade / mark)
  hurt   = { base = 0xd55e00, light = 0xf08a3c, shade = 0x8a2c0a, mark = 0x9c3608 },
  guard  = { base = 0x00639e, light = 0x3f9bd0, shade = 0x0a3d6e, mark = 0x3f9bd0 },
  heal   = { base = 0x009e73, light = 0x4cc79a, shade = 0x066a55, mark = 0x7fe0b4 },
  charm  = { base = 0xcc79a7, light = 0xeaa6c8, shade = 0x8a3f70, mark = 0x9a4a7c },
  soothe = { base = 0x62bcee, light = 0xa4dcf8, shade = 0x2f84bd, mark = 0xd8f1fb },
  trick  = { base = 0xf0e442, light = 0xfbf5a0, shade = 0xa8860e, mark = 0xd2bd1e },
  item   = { base = 0xe69f00, light = 0xf8c552, shade = 0xa05c08, mark = 0xb06a08 },
}
M.ORDER = { "hurt", "guard", "heal", "charm", "soothe", "trick", "item" }

M.CFG = {
  strip = { name = "strip", BW = 56, BH = 47, T = 13, lenTB = 20, lenLR = 21, R = 6, k = 1, stitchIn = 3, gW = 16, gH = 17, badge = 11, ring = 3 },
  hand  = { name = "hand", BW = 96, BH = 80, T = 22, lenTB = 34, lenLR = 34, R = 10, k = 22 / 13, stitchIn = 5, gW = 30, gH = 30, badge = 18, ring = 4 },
}
for _, c in pairs(M.CFG) do c.W = c.BW + 2 * c.T; c.H = c.BH + 2 * c.T end

-- raster -------------------------------------------------------------
local Cv = {}; Cv.__index = Cv
function M.cv(w, h) return setmetatable({ w = w, h = h, d = {} }, Cv) end
function Cv:set(x, y, c)
  x = math.floor(x); y = math.floor(y)
  if x >= 0 and y >= 0 and x < self.w and y < self.h then self.d[y * self.w + x + 1] = c or false end
end
function Cv:get(x, y)
  if x < 0 or y < 0 or x >= self.w or y >= self.h then return nil end
  return self.d[y * self.w + x + 1] or nil
end
function Cv:rect(x0, y0, x1, y1, c) for y = math.floor(y0), math.floor(y1) do for x = math.floor(x0), math.floor(x1) do self:set(x, y, c) end end end
function Cv:disc(cx, cy, r, c)
  for y = math.floor(cy - r - 1), math.ceil(cy + r + 1) do for x = math.floor(cx - r - 1), math.ceil(cx + r + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    if dx * dx + dy * dy <= r * r then self:set(x, y, c) end
  end end
end
function Cv:poly(pts, c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = math.min(x0, p[1]); x1 = math.max(x1, p[1]); y0 = math.min(y0, p[2]); y1 = math.max(y1, p[2]) end
  for y = math.floor(y0), math.ceil(y1) do for x = math.floor(x0), math.ceil(x1) do
    local px, py, inside, n = x + .5, y + .5, false, #pts
    local j = n
    for i = 1, n do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
      j = i
    end
    if inside then self:set(x, y, c) end
  end end
end
function Cv:blit(o, ox, oy) for y = 0, o.h - 1 do for x = 0, o.w - 1 do local c = o:get(x, y); if c then self:set(x + ox, y + oy, c) end end end end
function Cv:bbox()
  local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
  for y = 0, self.h - 1 do for x = 0, self.w - 1 do if self:get(x, y) then x0 = math.min(x0, x); x1 = math.max(x1, x); y0 = math.min(y0, y); y1 = math.max(y1, y) end end end
  return x0, y0, x1, y1
end
function Cv:ascii(rows, ox, oy, leg)
  for j, r in ipairs(rows) do for i = 1, #r do
    local ch = r:sub(i, i); local c = leg[ch]
    if c then self:set(ox + i - 1, oy + j - 1, c) end
  end end
end

function M.save(path, w, h, layers)
  app.fs.makeAllDirectories(app.fs.filePath(path))
  local spr = Sprite(w, h, ColorMode.RGB)
  for i, L in ipairs(layers) do
    local layer = (i == 1) and spr.layers[1] or spr:newLayer()
    layer.name = L.name
    local img = Image(w, h, ColorMode.RGB)
    for y = 0, h - 1 do for x = 0, w - 1 do
      local c = L.cv:get(x, y)
      if c then img:putPixel(x, y, app.pixelColor.rgba((c >> 16) & 255, (c >> 8) & 255, c & 255, 255)) end
    end end
    spr:newCel(layer, 1, img, Point(0, 0))
    if L.hidden then layer.isVisible = false end
  end
  spr:saveAs(path .. ".aseprite")
  spr:saveAs(path .. ".png")
  spr:close()
end
function M.savelayer(path, cv)  -- single-layer debug png (used by check.py)
  M.save(path, cv.w, cv.h, { { name = "l", cv = cv } })
  os.remove(path .. ".aseprite")
  os.remove(path .. "__.png")  -- leftover of an earlier draft of this helper
end

-- body geometry --------------------------------------------------------
function M.inBody(c, x, y)
  if x < 0 or y < 0 or x >= c.BW or y >= c.BH then return false end
  local R = c.R
  local dx, dy
  if x < R then dx = R - x - .5 elseif x >= c.BW - R then dx = x - (c.BW - R) + .5 end
  if y < R then dy = R - y - .5 elseif y >= c.BH - R then dy = y - (c.BH - R) + .5 end
  if dx and dy and dx * dx + dy * dy > R * R then return false end
  return true
end
function M.isRim(c, x, y)
  return M.inBody(c, x, y) and not (M.inBody(c, x - 1, y) and M.inBody(c, x + 1, y) and M.inBody(c, x, y - 1) and M.inBody(c, x, y + 1))
end
function M.distBody(c, x, y)  -- image coords -> euclid distance to nearest body pixel (0 inside)
  local bx, by = x - c.T, y - c.T
  if M.inBody(c, bx, by) then return 0 end
  local best = 1e9
  for yy = by - 7, by + 7 do for xx = bx - 7, bx + 7 do
    if M.inBody(c, xx, yy) then local d = math.sqrt((xx - bx) ^ 2 + (yy - by) ^ 2); if d < best then best = d end end
  end end
  return best
end

-- socket (knob / hole) profile ------------------------------------------
-- local coords: u along the edge 0..len-1, i = depth from the base 0..T-1.  fam body = square, mind = round, craft = triangle
function M.inK(c, fam, len, u, i)
  if u < 0 or u > len - 1 or i < 0 or i > c.T - 1 then return false end
  local k = c.k
  local dx, y = math.abs(u - (len - 1) / 2), (i + .5) * (k == 1 and 1.045 or 1)  -- strip: tabs end 1 px short of the glyph row
  if fam == "body" then       -- classic jigsaw: narrow neck, round head (circle r 6, centre ~7 px out)
    if dx <= 2.8 * k and y <= 2.4 * k then return true end
    return dx * dx + (y - 7.0 * k) ^ 2 <= (5.85 * k) ^ 2
  elseif fam == "mind" then   -- keyhole: flared base 18 wide, thin neck at 4.6 out, small round head
    if y <= 4.6 * k and dx <= (9 - 7.0 * y / (4.6 * k)) * k then return true end
    return dx * dx + (y - 7.9 * k) ^ 2 <= (4.7 * k) ^ 2
  else                        -- craft: blunt wedge 18 wide to 4 wide
    return y <= 13 * k and dx <= (9 - 7 * y / (13 * k)) * k
  end
end
-- side geometry: local (u,v) -> image coords; v = outward distance from the body edge row (0 = edge row)
function M.sideXY(c, side, u, v)
  local sTB, sLR = (c.BW - c.lenTB) // 2, (c.BH - c.lenLR) // 2
  if side == "top" then return c.T + sTB + u, c.T - v
  elseif side == "bottom" then return c.T + sTB + u, c.T + c.BH - 1 + v
  elseif side == "left" then return c.T - v, c.T + sLR + u
  else return c.T + c.BW - 1 + v, c.T + sLR + u end
end
function M.sideLen(c, side) if side == "top" or side == "bottom" then return c.lenTB else return c.lenLR end end
M.SIDES = { "top", "right", "bottom", "left" }
return M
