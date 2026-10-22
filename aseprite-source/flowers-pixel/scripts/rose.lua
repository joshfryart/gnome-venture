-- Gnome Venture flower head: rose (Stitched Toy). Petals neutral grey (tinted at runtime), core + outline fixed.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }

-- neutral grey ramps (no hue so a multiply tint takes any colour)
local outer = { gloss = "#ececec", dot = "#f6f6f6", rim = "#dedede", base = "#c2c2c2",
  shade = "#9c9c9c", deep = "#747474", bounce = "#acacac", pale = true }
local disc = { gloss = "#f4f4f4", dot = "#fafafa", rim = "#e8e8e8", base = "#d6d6d6",
  shade = "#b0b0b0", deep = "#848484", bounce = "#bcbcbc", pale = true }

-- five outer petals (svg circles r10.5) then the cupped bloom (svg circle r20); svg centre 32 -> pixel 31.5
local P = { {32, 17.5}, {45.79, 27.52}, {40.52, 43.73}, {23.48, 43.73}, {18.21, 27.52} }
local parts = {}
for i, p in ipairs(P) do
  parts[#parts+1] = { "petal" .. i, c:ellipse(p[1] - 0.5, p[2] - 0.5, 10.5), outer, { gloss = false, cres = 3, stitch = true } }
end
local bloom = c:ellipse(31.5, 31.5, 20)
parts[#parts+1] = { "bloom", bloom, disc, { contour = "#3c3c3c", gloss = { 17, 18 } } }
local pp = c:build(parts)

-- spiral groove (svg path: semicircles r6.5, r10, r13.5 alternating centres), 1 px pixel-perfect
local pts, seen = {}, {}
local function arc(cx, cy, r, t0, t1)
  local n = math.ceil(r * math.abs(t1 - t0) * 3)
  for i = 0, n do
    local t = t0 + (t1 - t0) * i / n
    local x, y = math.floor(cx + r * math.cos(t)), math.floor(cy + r * math.sin(t))
    local k = x .. "," .. y
    if not seen[k] then seen[k] = true; pts[#pts+1] = { x, y } end
  end
end
local pi = math.pi
arc(28.5, 32, 6.5, 0, pi)          -- around the core, via bottom
arc(32, 32, 10, pi, 2 * pi)        -- via top
arc(28.5, 32, 13.5, 0, pi)         -- via bottom, out to the left rim
-- pixel-perfect: drop L-corner pixels
local pp2, i = {}, 1
while i <= #pts do
  local a, b, n = pp2[#pp2], pts[i], pts[i+1]
  if a and n and (a[1] == b[1] or a[2] == b[2]) and (n[1] == b[1] or n[2] == b[2]) and a[1] ~= n[1] and a[2] ~= n[2] then
    i = i + 1
  else pp2[#pp2+1] = b; i = i + 1 end
end
for _, q in ipairs(pp2) do
  local x, y = q[1], q[2]
  local s = (x - 31.5) + (y - 31.5)
  c:px(x, y, s < -6 and "#8c8c8c" or "#6a6a6a")
  -- felt fold catches light just outside the groove on its lit (upper-left) neighbour
  if bloom:has(x - 1, y - 1) and c:get(x - 1, y - 1) ~= "#6a6a6a" and c:get(x - 1, y - 1) ~= "#8c8c8c" and s < 4 then
    if c:get(x - 1, y - 1) == disc.base then c:px(x - 1, y - 1, disc.rim) end
  end
  -- and the curl tucks into shadow on its lower-right side
  if s > -10 and c:get(x + 1, y + 1) == disc.base then c:px(x + 1, y + 1, outer.base) end
end

-- fixed core: the gold button sewn into the heart of the rose
c:button(30, 29)

local t = c:save(O .. "aseprite/rose.aseprite", O .. "png/rose.png")
print(GV.report(t))

-- split layers: neutral greys -> petals; everything with hue (button, umber outline) -> centre
local function split(path, wantNeutral)
  local img = Image(64, 64, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  for k, h in pairs(c.pix) do
    local x, y = c:xy(k)
    if c:inside(x, y) then
      local r, g, b = tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16)
      local neutral = (r == g and g == b)
      if neutral == wantNeutral then img:putPixel(x, y, app.pixelColor.rgba(r, g, b, 255)) end
    end
  end
  img:saveAs(path)
  print(path, GV.report(GV.check(img)))
end
split(O .. "png/rose-petals.png", true)
split(O .. "png/rose-centre.png", false)
