-- variety-act-g3-lib.lua : flat pixel helpers for the Do-tab act cards (144x108 = 72x54 grid at 2x), matching the
-- existing act-hand/rod/fire cards: simple flat colour, 1 px brown outline, wood frame copied from act-rod.png.
-- Inner picture area on the grid: x 5..67, y 5..49. Everything is clipped to it; the frame is pasted last.
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local L = { GV = GV, X0 = 5, Y0 = 5, X1 = 67, Y1 = 49 }
local floor, abs, max, min = math.floor, math.abs, math.max, math.min

L.C = {
  sky1 = "#a8d4e0", sky2 = "#bcdde4", sky3 = "#cfe8e6", sky4 = "#e2f0e0",
  grass = "#7ea85a", grassL = "#9cc070", grassD = "#5e8a44", grassDD = "#4e7a3c",
  hill = "#5e8a44", hillL = "#7ea85a",
  water = "#4a88b0", waterL = "#8cc4dc", waterD = "#356a94",
  ol = "#4a2c1a", ol2 = "#2a1a10",
  wood = "#c08a52", woodL = "#e0b070", woodD = "#a06a3a", woodDD = "#744626",
  hat = "#c0442e", hatD = "#8e2e1e", skin = "#f0c8a0", beard = "#f4eee0", beardD = "#cfc6b0", pink = "#e08a7a",
  blue = "#4a6e9a", blueD = "#345072", boot = "#5a3a22",
  gold = "#f4c84a", goldD = "#c89a2a", stone = "#8a909a", stoneL = "#c9c5bc", stoneD = "#5b6470",
  cream = "#f4eee0", white = "#f8f4ec", red = "#c0442e", leaf = "#4e8a3c", leafL = "#7ab55c",
}
local C = L.C

local function hex2rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function L.dim(h, f, bl) -- darken a colour: f<1 darkens; bl adds blue
  local r, g, b = hex2rgb(h)
  return string.format("#%02x%02x%02x", floor(r*f), floor(g*f), min(255, floor(b*f) + (bl or 0)))
end

function L.new()
  local self = { c = GV.canvas{ w = 72, h = 54, mode = "scene", out = 2 }, tint = nil }
  setmetatable(self, { __index = L })
  return self
end

function L:px(x, y, col)
  if self.mirror then x = self.X0 + self.X1 - x end
  if x >= self.X0 and x <= self.X1 and y >= self.Y0 and y <= self.Y1 then
    self.c:px(x, y, self.tint and self.tint(col) or col)
  end
end
function L:get(x, y) return self.c:get(x, y) end
function L:rect(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do self:px(x, y, col) end end end
function L:ell(cx, cy, rx, ry, col)
  ry = ry or rx
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local dx, dy = (x - cx) / (rx + 0.35), (y - cy) / (ry + 0.35)
    if dx*dx + dy*dy <= 1 then self:px(x, y, col) end
  end end
end
function L:line(x0, y0, x1, y1, col)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    self:px(x0, y0, col)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end
-- thick line: 2 px wide (offset in y)
function L:line2(x0, y0, x1, y1, col) self:line(x0, y0, x1, y1, col); self:line(x0, y0 + 1, x1, y1 + 1, col) end
function L:poly(pts, col) -- filled polygon, even-odd scanline
  local ymin, ymax = 1e9, -1e9
  for _, p in ipairs(pts) do ymin = min(ymin, p[2]); ymax = max(ymax, p[2]) end
  for y = ymin, ymax do
    local xs = {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= y and b[2] > y) or (b[2] <= y and a[2] > y) then
        xs[#xs+1] = a[1] + (y - a[2]) * (b[1] - a[1]) / (b[2] - a[2])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do for x = floor(xs[i] + 0.5), floor(xs[i+1] - 0.5) do self:px(x, y, col) end end
  end
end
-- 1 px outline ring of a mask built from fills: draw shape in `col` then call self:edge(function) - kept simple:
function L:ring(cx, cy, rx, ry, col) -- ellipse outline only
  ry = ry or rx
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local function inside(xx, yy) local dx, dy = (xx - cx) / (rx + 0.35), (yy - cy) / (ry + 0.35) return dx*dx + dy*dy <= 1 end
    if inside(x, y) and not (inside(x-1,y) and inside(x+1,y) and inside(x,y-1) and inside(x,y+1)) then self:px(x, y, col) end
  end end
end
-- ascii painter: legend char -> colour (names from C or "#hex"); `flip` mirrors horizontally
function L:ascii(rows, x0, y0, legend, flip)
  local w = 0
  for _, r in ipairs(rows) do w = max(w, #r) end
  for j, row in ipairs(rows) do for i = 1, #row do
    local v = legend[row:sub(i, i)]
    if v then
      local col = (v:sub(1,1) == "#") and v or C[v]
      local xx = flip and (x0 + w - i) or (x0 + i - 1)
      self:px(xx, y0 + j - 1, col)
    end
  end end
end
function L:bands(x0, y0, x1, y1, cols) -- horizontal bands, equal height
  local n, h = #cols, y1 - y0 + 1
  for y = y0, y1 do
    local i = min(n, floor((y - y0) * n / h) + 1)
    for x = x0, x1 do self:px(x, y, cols[i]) end
  end
end
function L:hill(base, amp, per, ph, col, x0, x1)
  for x = x0 or self.X0, x1 or self.X1 do
    local h = floor(amp * (0.5 + 0.5 * math.sin((x + ph) / per)) + 0.5)
    for y = base - h, self.Y1 do self:px(x, y, col) end
  end
end
function L:cloud(x, y, col)
  col = col or C.white
  self:ell(x, y, 4, 1.5, col); self:ell(x - 2, y - 1, 2.5, 1.8, col); self:ell(x + 2, y - 1, 3, 2, col)
end

---------------------------------------------------------------- gnome
local LEG = { o = "ol", h = "hat", r = "hatD", k = "skin", d = "ol2", w = "beard", v = "beardD", p = "pink", b = "blue", n = "blueD", t = "boot", u = "ol2", g = "gold", G = "goldD" }
-- side view facing right: hat (9 rows), brim, face, beard, tunic, boots. 12 wide x 19 tall.
L.SIDE = {
  ".....oo.....",
  "....ohho....",
  "....ohhho...",
  "...ohhhhro..",
  "...ohhhhhro.",
  "..ohhhhhhro.",
  "..ohhhhhhhro",
  ".orrrrrrrrro",
  "..okkkkkdko.",
  "..okkkkkdkpo",
  "..owwwwwwwo.",
  ".owwwwwwwwvo",
  ".owwwwwwwwvo",
  ".obwwwwwwvno",
  ".obbwwwwvbno",
  ".obbbbbbbbno",
  ".obbbbbbbnno",
  ".ottttotttto",
  ".ouuuuouuuuo",
}
-- the same without legs (rows 1..17) for seated poses
L.SIDE_SIT = {}
for i = 1, 17 do L.SIDE_SIT[i] = L.SIDE[i] end
-- front view, 11 wide x 19 tall
L.FRONT = {
  "....ooo....",
  "...ohhho...",
  "...ohhhro..",
  "..ohhhhhro.",
  "..ohhhhhro.",
  ".ohhhhhhhro",
  ".ohhhhhhhro",
  "orrrrrrrrro",
  ".okkkkkkko.",
  ".okdkkkdko.",
  ".okkkpkkko.",
  ".owwwwwwwo.",
  "owwwwwwwwwo",
  "owwwwwwwwvo",
  "obwwwwwwwbo",
  "obbwwwwwbno",
  "obbbbbbbbno",
  "ottto.ottto",
  "ouuuo.ouuuo",
}
-- draws the gnome; x,y = top-left. opts: dir=1 right / -1 left, sit=true (no legs), front=true, dimf
function L:gnome(x, y, o)
  o = o or {}
  local rows = o.front and L.FRONT or (o.sit and L.SIDE_SIT or L.SIDE)
  local old = self.tint
  if o.night then self.tint = function(c) return L.dim(c, o.night, 6) end end
  self:ascii(rows, x, y, LEG, (not o.front) and o.dir == -1)
  self.tint = old
end
-- eye position helpers (top-left of the sprite -> hand/shoulder anchors) are chosen per scene.

---------------------------------------------------------------- frame + save
function L:frame()
  local img = Image{ fromFile = REPO .. "game/assets/img/acts/act-rod.png" }
  local pc = app.pixelColor
  for gy = 0, 53 do for gx = 0, 71 do
    if gx < self.X0 or gx > self.X1 or gy < self.Y0 or gy > self.Y1 then
      local v = img:getPixel(gx * 2, gy * 2)
      if pc.rgbaA(v) > 0 then
        self.c:px(gx, gy, string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)))
      end
    end
  end end
end
function L:save(slug, outdir, asedir)
  self.tint = nil; self.mirror = false
  self:frame()
  local t = self.c:save(asedir .. "/variety-act-" .. slug .. ".aseprite", outdir .. "/act-" .. slug .. ".png")
  print(slug .. " " .. GV.report(t))
  assert(t.semi == 0 and t.w == 144 and t.h == 108)
  return t
end
return L
