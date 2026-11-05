-- Hearth Pop v3: wander/places icons, 24x24, self-contained (no shared lib).
-- run: AppRun -b --script-param out=<dir>/ --script icons.lua
local OUT = (app.params and app.params.out) or "./"
local W = 24
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min

local R = {
  green  = { "#1c3622", "#2f6b3a", "#4a9a46", "#7cc45a", "#c4ec8a" },
  lime   = { "#24421e", "#6aae3e", "#9ad86a", "#c8f090", "#f2ffd0" },
  amber  = { "#4a2810", "#a0581c", "#d88a2a", "#f2b84a", "#ffe39a" },
  fern   = { "#1e3a1c", "#3c7a30", "#5ea840", "#8cd05a", "#d0f49a" },
  red    = { "#3e1420", "#8a2230", "#c83a3a", "#ec6a4a", "#ffb08a" },
  bone   = { "#4a3226", "#c9ae86", "#ecdcb4", "#fff1d0", "#fffbea" },
  violet = { "#24143c", "#4f2e7a", "#7a4ab0", "#a77ad8", "#e2c2ff" },
  glow   = { "#163a44", "#2a8a90", "#4cc8c0", "#90ecdc", "#dcfff4" },
  wood   = { "#3a2216", "#6e4228", "#9a6238", "#c4864e", "#e6b27a" },
  road   = { "#3b2c26", "#7a6450", "#a88e70", "#cdb592", "#eadbbe" },
  gold   = { "#5a3810", "#b07a1c", "#e6b030", "#ffd85a", "#fff2a8" },
  boot   = { "#2e1a14", "#5e3424", "#8a4e30", "#b8723e", "#e0a060" },
  dark   = { "#1c1222", "#2e2034", "#3e2e44", "#54405a", "#6a5470" },
  iron   = { "#26202a", "#4a4250", "#6e6676", "#9890a0", "#c8c0d0" },
}

local function K(x, y) return y * W + x end
local function inb(x, y) return x >= 0 and y >= 0 and x < W and y < W end

-- masks -------------------------------------------------------------------
local function mk(fn)
  local m = {}
  for y = 0, W - 1 do for x = 0, W - 1 do if fn(x + 0.5, y + 0.5, x, y) then m[K(x, y)] = true end end end
  return m
end
local function disc(cx, cy, r) return mk(function(px, py) return (px - cx) ^ 2 + (py - cy) ^ 2 <= r * r end) end
local function ell(cx, cy, rx, ry) return mk(function(px, py) return ((px - cx) / rx) ^ 2 + ((py - cy) / ry) ^ 2 <= 1 end) end
local function rect(x0, y0, x1, y1) return mk(function(_, _, x, y) return x >= x0 and x <= x1 and y >= y0 and y <= y1 end) end
local function poly(p)
  return mk(function(px, py)
    local inside, j = false, #p
    for i = 1, #p do
      local xi, yi, xj, yj = p[i][1], p[i][2], p[j][1], p[j][2]
      if (yi > py) ~= (yj > py) and px < (xj - xi) * (py - yi) / (yj - yi) + xi then inside = not inside end
      j = i
    end
    return inside
  end)
end
local function seg(x0, y0, x1, y1, w)
  return mk(function(px, py)
    local dx, dy = x1 - x0, y1 - y0
    local t = max(0, min(1, ((px - x0) * dx + (py - y0) * dy) / (dx * dx + dy * dy)))
    local ex, ey = x0 + t * dx - px, y0 + t * dy - py
    return ex * ex + ey * ey <= (w / 2) ^ 2
  end)
end
local function U(...) local o = {} for _, m in ipairs({ ... }) do for k in pairs(m) do o[k] = true end end return o end
local function S(a, b) local o = {} for k in pairs(a) do if not b[k] then o[k] = true end end return o end
local function I(a, b) local o = {} for k in pairs(a) do if b[k] then o[k] = true end end return o end
local function where(m, fn) local o = {} for k in pairs(m) do if fn(k % W, k // W) then o[k] = true end end return o end

-- painting ----------------------------------------------------------------
local function canvas() return { px = {} } end
local function put(C, x, y, col) if inb(x, y) then C.px[K(x, y)] = col end end

-- tone ramp: upper-left lit, lower-right shaded, 1px own-dark outline
local function paint(C, m, r, o)
  o = o or {}
  local x0, y0, x1, y1 = 99, 99, -1, -1
  for k in pairs(m) do local x, y = k % W, k // W x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local cx, cy, sz = (x0 + x1) / 2, (y0 + y1) / 2, max(2, (x1 - x0 + y1 - y0) / 2)
  for k in pairs(m) do
    local x, y = k % W, k // W
    local t = ((x - cx) + (y - cy)) / sz
    local col = (t > 0.45) and r[2] or ((t < -0.45) and r[4] or r[3])
    if o.flat then col = r[o.flat] end
    local dl = not m[K(x + 1, y)] or not m[K(x, y + 1)]
    local ul = not m[K(x - 1, y)] or not m[K(x, y - 1)]
    if not o.flat then
      if dl and not ul then col = r[2] elseif ul and not dl then col = r[4] end
    end
    C.px[k] = col
  end
  if o.outline ~= false then
    local oc = o.ink or r[1]
    for k in pairs(m) do
      local x, y = k % W, k // W
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = x + d[1], y + d[2]
        if inb(nx, ny) and not m[K(nx, ny)] and (o.over or not C.px[K(nx, ny)]) then C.px[K(nx, ny)] = oc end
      end
    end
  end
  if o.spec then put(C, o.spec[1], o.spec[2], r[5]) end
end

local function sparkle(C, x, y, r, big)
  local arms = big and 2 or 1
  local m = {}
  for i = -arms, arms do m[K(x + i, y)] = true m[K(x, y + i)] = true end
  paint(C, m, r, { flat = 4 })
  put(C, x, y, r[5])
end

local function badge(C, r)
  local d = disc(12, 12, 10)
  paint(C, d, r)
  -- bevel ring
  local ring = S(disc(12, 12, 8.6), disc(12, 12, 7.6))
  for k in pairs(ring) do local x, y = k % W, k // W C.px[k] = ((x + y) < 23) and r[2] or r[4] end
  put(C, 6, 5, r[5]) put(C, 5, 6, r[4])
end

-- icons -------------------------------------------------------------------
local icons = {}

icons["wander-tier-gentle"] = function(C)
  badge(C, R.green)
  paint(C, ell(12, 17.5, 4.5, 1.6), R.wood, { over = true })
  paint(C, rect(11, 11, 12, 16), R.lime, { over = true })
  paint(C, poly { { 11.5, 13 }, { 8, 12.5 }, { 5.5, 9.5 }, { 7, 8 }, { 10, 9 } }, R.lime, { over = true })
  paint(C, poly { { 12.5, 12 }, { 14, 8 }, { 18, 6 }, { 18.5, 8.5 }, { 16, 11.5 } }, R.lime, { over = true, spec = { 16, 8 } })
end

icons["wander-tier-wild"] = function(C)
  badge(C, R.amber)
  local leaf = poly { { 6, 18.5 }, { 6.5, 13 }, { 10, 8 }, { 17.5, 5 }, { 17.5, 10 }, { 14.5, 15 }, { 9, 18 } }
  paint(C, leaf, R.fern, { over = true, ink = R.amber[1] })
  for k in pairs(I(seg(6.5, 18, 16, 7, 1), leaf)) do C.px[k] = R.fern[2] end
  for _, v in ipairs { { 9, 14, 8, 11 }, { 11, 12, 11, 9 }, { 13, 10, 13, 7 }, { 10, 14, 13, 15 }, { 12, 12, 15, 12 } } do
    for k in pairs(I(seg(v[1], v[2], v[3], v[4], 0.8), leaf)) do C.px[k] = R.fern[2] end
  end
  put(C, 14, 7, R.fern[5])
  paint(C, seg(5, 20, 7, 17.5, 1.2), R.fern, { over = true, ink = R.amber[1] })
end

icons["wander-tier-dangerous"] = function(C)
  badge(C, R.red)
  for i, ox in ipairs { 6, 10, 14 } do
    local claw = poly { { ox, 5 + (i == 2 and -0.5 or 0.5) }, { ox + 2.6, 5.5 }, { ox + 3.5, 12 }, { ox + 2, 18.5 }, { ox + 1.2, 12 } }
    paint(C, claw, R.bone, { over = true, ink = R.red[1], spec = { ox + 1, 6 } })
  end
end

icons["wander-tier-deep"] = function(C)
  badge(C, R.violet)
  paint(C, rect(11, 12, 13, 17), R.bone, { over = true, ink = R.violet[1] })
  local cap = I(ell(12, 12, 6.5, 5.5), rect(0, 0, 23, 12))
  paint(C, cap, R.glow, { over = true, ink = R.violet[1] })
  put(C, 9, 9, R.glow[5]) put(C, 14, 8, R.glow[5]) put(C, 15, 11, R.glow[4]) put(C, 8, 8, R.glow[4])
  put(C, 10, 8, R.glow[4])
  sparkle(C, 18, 16, R.glow)
  put(C, 6, 15, R.glow[4])
end

icons["wander-deeper"] = function(C)
  local path = poly { { 3, 22 }, { 21, 22 }, { 14.5, 10 }, { 9.5, 10 } }
  paint(C, path, R.road)
  for _, y in ipairs { 12, 15, 18, 21 } do put(C, 12, y, R.road[5]) put(C, 11, y, R.road[4]) end
  local arrow = U(rect(9, 1, 14, 9), poly { { 4, 9 }, { 20, 9 }, { 12, 17.5 } })
  paint(C, arrow, R.gold, { over = true, spec = { 10, 2 } })
end

icons["wander-roam"] = function(C)
  local ring = S(disc(12, 12.5, 9.5), disc(12, 12.5, 5.5))
  ring = S(ring, poly { { 12, 12.5 }, { 24, 0 }, { 24, 9 } })
  paint(C, ring, R.gold)
  local head = poly { { 15.5, 1 }, { 22.5, 11.5 }, { 14, 10 } }
  paint(C, head, R.gold, { over = true, spec = { 16, 3 } })
  put(C, 6, 7, R.gold[5])
end

icons["wander-back"] = function(C)
  local body = U(where(S(disc(12, 12.5, 8.5), disc(12, 12.5, 4.5)), function(x) return x >= 11 end), rect(5, 17, 11, 20))
  paint(C, body, R.amber)
  local head = poly { { 1.5, 6.5 }, { 11, 0.5 }, { 11, 12.5 } }
  paint(C, head, R.amber, { over = true, spec = { 9, 3 } })
  put(C, 18, 7, R.amber[5])
end

icons["wander-return"] = function(C)
  local road = poly { { 0.5, 16 }, { 23.5, 16 }, { 23.5, 22 }, { 0.5, 22 } }
  paint(C, road, R.road)
  for _, x in ipairs { 2, 7, 12, 17, 21 } do put(C, x, 19, R.road[5]) put(C, x + 1, 19, R.road[4]) end
  local boot = U(rect(7, 2, 12, 13), poly { { 6.5, 9 }, { 13, 9 }, { 17, 10.5 }, { 19.5, 12.5 }, { 19.5, 15 }, { 6.5, 15 } })
  paint(C, boot, R.boot, { over = true, spec = { 8, 3 } })
  for k in pairs(I(rect(6, 15, 20, 16), U(boot, rect(6, 15, 19, 15)))) do C.px[k] = R.boot[1] end
  for k in pairs(rect(7, 2, 12, 3)) do C.px[k] = R.boot[4] end
  put(C, 7, 2, R.boot[5]) put(C, 10, 7, R.gold[3]) put(C, 10, 9, R.gold[3])
  put(C, 3, 14, R.road[4]) put(C, 22, 14, R.road[4])
end

icons["wander-visit"] = function(C)
  paint(C, rect(5, 3, 7, 22), R.wood, { spec = { 5, 4 } })
  paint(C, rect(5, 3, 19, 5), R.wood, { over = true })
  paint(C, rect(5, 6, 7, 22), R.wood, { outline = false })
  paint(C, ell(6, 22, 3.5, 1), R.road, {})
  paint(C, rect(16, 6, 16, 7), R.iron, { over = true })
  paint(C, rect(13, 9, 19, 10), R.iron, { over = true })
  local glass = rect(14, 11, 18, 16)
  paint(C, glass, R.gold, { over = true, ink = R.iron[1] })
  put(C, 15, 12, R.gold[5]) put(C, 16, 13, R.gold[5]) put(C, 16, 14, R.gold[4])
  paint(C, rect(13, 17, 19, 17), R.iron, { over = true })
  put(C, 11, 13, R.gold[4]) put(C, 21, 12, R.gold[4]) put(C, 21, 16, R.gold[3])
end

icons["wander-found"] = function(C)
  paint(C, rect(10, 9, 12, 22), R.wood)
  paint(C, ell(11, 22, 4, 1), R.road, {})
  local sign = poly { { 3, 6 }, { 15.5, 6 }, { 19, 9.5 }, { 15.5, 13 }, { 3, 13 } }
  paint(C, sign, R.wood, { over = true, spec = { 4, 7 } })
  for x = 5, 14 do put(C, x, 9, R.wood[2]) end
  put(C, 7, 11, R.wood[2]) put(C, 8, 11, R.wood[2]) put(C, 12, 11, R.wood[2])
  sparkle(C, 19, 3, R.gold, true)
  sparkle(C, 20, 16, R.gold)
  put(C, 2, 3, R.gold[4]) put(C, 6, 17, R.gold[4])
end

-- export ------------------------------------------------------------------
local order = { "wander-tier-gentle", "wander-tier-wild", "wander-tier-dangerous", "wander-tier-deep",
  "wander-deeper", "wander-roam", "wander-back", "wander-return", "wander-visit", "wander-found" }

local function toImage(C, img)
  for k, col in pairs(C.px) do
    img:drawPixel(k % W, k // W, Color { r = tonumber(col:sub(2, 3), 16), g = tonumber(col:sub(4, 5), 16), b = tonumber(col:sub(6, 7), 16), a = 255 })
  end
end

local sheet = Sprite(W, W, ColorMode.RGB)
for i, name in ipairs(order) do
  local C = canvas()
  icons[name](C)
  local spr = Sprite(W, W, ColorMode.RGB)
  toImage(C, spr.cels[1].image)
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
  if i > 1 then sheet:newEmptyFrame() end
  local cel = sheet:newCel(sheet.layers[1], i)
  toImage(C, cel.image)
  print("saved " .. name)
end
sheet:saveAs(OUT .. "icons.aseprite")
sheet:close()
