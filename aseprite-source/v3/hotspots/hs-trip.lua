-- Hotspot button: 48x48 round wooden plaque + 32px icon. Self-contained (no lib). Hard pixels, light upper-left.
local OUT = app.params.out or "./"
local W = 48
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
  o = o or {}
  -- ink outline round the icon (8-neighbour), then compose on the plaque
  local O = {}
  for k, c in pairs(I) do O[k] = c end
  for k in pairs(I) do local x, y = k % W, floor(k / W)
    for dy = -1, 1 do for dx = -1, 1 do local nx, ny = x + dx, y + dy
      if inb(nx, ny) and not I[K(nx, ny)] then O[K(nx, ny)] = INK end end end end
  local rimD, rim = "#7a5a3a", { "#fff0c8", "#ecd49c", "#c8a468" }
  local faceD, face = "#2e3350", { "#59628a", "#464e72", "#383e5c" }
  if o.goal then rimD, rim = "#7a4e10", { "#fff0a0", "#f6c648", "#c88a20" } end
  local img = {}
  local function setp(x, y, c) img[K(x, y)] = c end
  for y = 0, W - 1 do for x = 0, W - 1 do
    local dx, dy = x + .5 - 24, y + .5 - 24
    local d = sqrt(dx * dx + dy * dy)
    local lit = (-dx - dy) / (d + .001)           -- >0 upper-left
    if d <= 24 then
      if d > 23.2 then setp(x, y, rimD)
      elseif d > 21 then setp(x, y, (lit > .55 and d > 22.2) and rim[1] or ((lit < -.55 and d < 22.4) and rim[3] or rim[2]))
      elseif d > 20 then setp(x, y, faceD)
      else setp(x, y, (lit > .6 and d > 18) and face[1] or ((lit < -.6 and d > 18) and face[3] or face[2])) end
    end
  end end
  local over = 0
  for k, c in pairs(O) do local x, y = k % W, floor(k / W)
    local dx, dy = x + .5 - 24, y + .5 - 24
    if sqrt(dx * dx + dy * dy) <= 20 then img[k] = c else over = over + 1 end end
  -- save
  local spr = Sprite(W, W, ColorMode.RGBA)
  local im = spr.cels[1].image
  for k, c in pairs(img) do
    local r, g, b = hex(c)
    assert(not (r == 0 and g == 0 and b == 0) and not (r == 255 and g == 255 and b == 255), "pure black/white at " .. k)
    im:putPixel(k % W, floor(k / W), app.pixelColor.rgba(r, g, b, 255))
  end
  spr:saveAs(OUT .. name .. ".aseprite")
  spr:saveCopyAs(OUT .. name .. ".png")
  io.stdout:write(name .. " ok, clipped icon px: " .. over .. "\n")
end


fill(rect(12,10,36,16), R.blue) fill(rect(10,10,12,16), R.cream) fill(rect(36,10,38,16), R.cream)
fill(U(rect(13,23,34,38), ell(23.5,23,10.5,6)), R.orange)
fill(rect(13,26,34,31), {R.orange[2],R.orange[2],R.orange[3]})
fill(rect(22,29,25,33), R.gold)
fill(rect(15,17,17,23), R.bark) fill(rect(30,17,32,23), R.bark)

finish('hs-trip', {goal=false})
