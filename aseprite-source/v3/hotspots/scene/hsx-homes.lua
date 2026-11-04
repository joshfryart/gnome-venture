-- Hotspot button: 48x48 round wooden plaque + 32px icon. Self-contained (no lib). Hard pixels, light upper-left.
local OUT = app.params.out or "./"
local W = 64
local I = {}                                   -- icon layer: I[k] = "#hex"
local floor, ceil, sqrt, sin, cos, abs = math.floor, math.ceil, math.sqrt, math.sin, math.cos, math.abs
local function K(x, y) return y * W + x end
local function inb(x, y) return x >= 0 and y >= 0 and x < W and y < W end
local function rect(x0, y0, x1, y1) local m = {} for y = y0, y1 do for x = x0, x1 do if inb(x, y) then m[K(x, y)] = true end end end return m end
local function ell(cx, cy, rx, ry) local m = {}
  for y = 0, W - 1 do for x = 0, W - 1 do local dx, dy = (x + .5 - cx) / rx, (y + .5 - cy) / ry if dx * dx + dy * dy <= 1 then m[K(x, y)] = true end end end return m end
local function poly(p) local m = {}
  for y = 0, W - 1 do for x = 0, W - 1 do
    local px, py, c = x + .5, y + .5, false
    for i = 1, #p do local a, b = p[i], p[i % #p + 1]
      if (a[2] > py) ~= (b[2] > py) and px < (b[1] - a[1]) * (py - a[2]) / (b[2] - a[2]) + a[1] then c = not c end end
    if c then m[K(x, y)] = true end end end return m end
local function line(x0, y0, x1, y1, w) local m = {} local dx, dy = x1 - x0, y1 - y0 local l2 = dx * dx + dy * dy
  for y = 0, W - 1 do for x = 0, W - 1 do
    local px, py = x + .5 - x0, y + .5 - y0
    local t = l2 == 0 and 0 or math.max(0, math.min(1, (px * dx + py * dy) / l2))
    local qx, qy = px - t * dx, py - t * dy
    if sqrt(qx * qx + qy * qy) <= w / 2 then m[K(x, y)] = true end end end return m end
local function U(...) local r = {} for _, m in ipairs({ ... }) do for k in pairs(m) do r[k] = true end end return r end
local function Mi(a, b) local r = {} for k in pairs(a) do if not b[k] then r[k] = true end end return r end
local function X(a, b) local r = {} for k in pairs(a) do if b[k] then r[k] = true end end return r end
local function ring(cx, cy, ro, ri) return Mi(ell(cx, cy, ro, ro), ell(cx, cy, ri, ri)) end
local function flat(m, col) for k in pairs(m) do I[k] = col end end
local function dot(x, y, col) if inb(x, y) then I[K(x, y)] = col end end
local function fill(m, r)   -- bevel: light on top/left edge, shade on bottom/right edge
  for k in pairs(m) do
    local x, y = k % W, floor(k / W)
    local hi = not m[K(x - 1, y)] or not m[K(x, y - 1)]
    local lo = not m[K(x + 1, y)] or not m[K(x, y + 1)]
    I[k] = (hi and not lo) and r[1] or ((lo and not hi) and r[3] or r[2])
  end
end
local R = {
  wood = { "#d49a5a", "#a8683a", "#6e4026" }, gold = { "#ffe98a", "#f2b830", "#b87a1c" }, red = { "#ff8a74", "#d63f3a", "#8f2430" },
  green = { "#9ae060", "#4fa83c", "#2d6b34" }, blue = { "#a0d0ff", "#4a8fe0", "#2d56a0" }, stone = { "#e0dce4", "#9d98a8", "#625c78" },
  cream = { "#fffbe8", "#f4e3b5", "#c9a878" }, purple = { "#dcb0ff", "#9a5fd6", "#5e3a96" }, dark = { "#7a6884", "#4a3c58", "#2b1c26" },
  pink = { "#ffc8d4", "#ff8aa0", "#c9506a" }, orange = { "#ffc878", "#ee8a2a", "#a85218" }, glass = { "#f0fbff", "#bfe6f5", "#7fb4d0" },
  skin = { "#ffd8b0", "#f0b088", "#c07a5c" }, teal = { "#90e8d8", "#3fb0a0", "#25706c" }, bark = { "#a8785a", "#7a4e38", "#4a2e28" },
}
local function hex(h) h = h:gsub("#", "") return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16) end
local INK = "#2b1c26"

function finish(name, o)
  local O = {}
  for k, c in pairs(I) do O[k] = c end
  for k in pairs(I) do local x, y = k % W, floor(k / W)
    for dy = -1, 1 do for dx = -1, 1 do local nx, ny = x + dx, y + dy
      if inb(nx, ny) and not I[K(nx, ny)] then O[K(nx, ny)] = INK end end end end
  local spr = Sprite(W, W, ColorMode.RGBA)
  local im = spr.cels[1].image
  for k, c in pairs(O) do local r, g, b = hex(c)
    im:putPixel(k % W, floor(k / W), app.pixelColor.rgba(r, g, b, 255)) end
  spr:saveAs(OUT .. name .. ".aseprite") spr:saveCopyAs(OUT .. name .. ".png")
end


flat(ell(32,57,24,3),"#3a2a44")
fill(rect(44,8,50,24), R.stone) fill(rect(43,6,51,9), R.stone)
flat(ell(48,3,3,2),"#d8d0dc")
fill(rect(12,30,52,56), R.cream)
fill(rect(12,48,52,56), R.stone)
for x=16,48,8 do flat(rect(x,50,x+3,50), R.stone[3]) end
fill(poly{{5,32},{32,8},{59,32}}, R.red)
for y=14,30,4 do for x=0,63 do local k=K(x,y) if I[k] and I[K(x,y-1)] then I[k]=R.red[3] end end end
fill(rect(27,38,36,56), R.wood) flat(rect(31,38,31,56),R.wood[3]) fill(ell(34,48,1.2,1.2),R.gold)
fill(rect(15,38,23,46), R.gold) fill(rect(39,38,48,46), R.gold)
flat(rect(19,38,19,46),R.wood[3]) flat(rect(15,42,23,42),R.wood[3]) flat(rect(43,38,43,46),R.wood[3]) flat(rect(39,42,48,42),R.wood[3])
fill(rect(14,46,24,48), R.wood) fill(rect(38,46,49,48), R.wood)
fill(ell(17,45,2,1.5), R.pink) fill(ell(21,45,2,1.5), R.red) fill(ell(41,45,2,1.5), R.pink) fill(ell(46,45,2,1.5), R.gold)

finish("hsx-homes")
