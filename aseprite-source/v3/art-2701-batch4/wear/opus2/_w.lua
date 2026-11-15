-- _w.lua: helpers for the batch4 wear Opus second pass (opus2). Full redraws, 64x64 Hearth Pop.
-- Builds on items/batch2/_bbg.lua (hp.lua + hpx.lua lighting, tube, oval, cast) read only.
-- Every part is lit per pixel from a normal field and snapped to a 6-tone ramp; material texture
-- goes in as tone bias (felt fuzz, knit chevrons, leather pores, canvas weave), so it follows the light.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../../items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local W = setmetatable({ DIR = DIR }, { __index = G })
W.OUT = (app.params and app.params.out) or (DIR .. "/")
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
W.INK = "#2b1c26"

function W.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- normals: vertical cylinder (x varies), horizontal cylinder (y varies), blended with a pillow edge
function W.vcylN(m, x0, x1, tilt)
  local n = {}
  m:each(function(x, y)
    local t = max(-.95, min(.95, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { G.norm(t, tilt or 0, sqrt(1 - t * t)) }
  end)
  return n
end
function W.hcylN(m, y0, y1, tilt)
  local n = {}
  m:each(function(x, y)
    local t = max(-.95, min(.95, ((y + .5 - y0) / (y1 + 1 - y0)) * 2 - 1))
    n[K(x, y)] = { G.norm(tilt or 0, t, sqrt(1 - t * t)) }
  end)
  return n
end
-- mix two normal fields (a weighted by wa)
function W.mixN(a, b, wa)
  local n = {}
  for k, v in pairs(a) do
    local u = b[k] or v
    n[k] = { G.norm(v[1] * wa + u[1] * (1 - wa), v[2] * wa + u[2] * (1 - wa), v[3] * wa + u[3] * (1 - wa)) }
  end
  return n
end

-- light + quantise. ramp = 6 hex dark..light. o.bias, o.amb, o.wrap, o.cuts
function W.lit(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.24, 0.42, 0.58, 0.73, 0.87 }, bias = o.bias })
  return idx, v
end

function W.addBias(b, x, y, a) local k = K(x, y) b[k] = (b[k] or 0) + a end
-- sparse speckle: frac of pixels get `a` (deterministic)
function W.speck(b, m, seed, frac, a)
  m:each(function(x, y) if X.hash(x, y, seed) < frac then W.addBias(b, x, y, a) end end)
  return b
end
-- AO: pixels of m within r px of `other` get amt
function W.ao(b, m, other, r, amt) return X.ao(b, m, other, r, amt) end

function W.px(c, x, y, hex) if hex then c:put(x, y, hex) else c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end
function W.get(c, x, y) if x < 0 or y < 0 or x > 63 or y > 63 then return nil end return c.pix[y * c.w + x] end
-- paint rows of chars (map char -> hex; '.' skip; '_' erase)
function W.paint(c, x0, y0, rows, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch == "_" then W.px(c, x0 + i - 1, y0 + j - 1, nil)
      elseif ch ~= "." and ch ~= " " then W.px(c, x0 + i - 1, y0 + j - 1, map[ch]) end
    end
  end
end
-- 1 px separation line: pixels of m touching mask `other` (4-conn) get hex
function W.sep(c, m, other, hex)
  local pts = {}
  m:each(function(x, y)
    if other:has(x + 1, y) or other:has(x - 1, y) or other:has(x, y + 1) or other:has(x, y - 1) then pts[#pts + 1] = { x, y } end
  end)
  for _, p in ipairs(pts) do c:put(p[1], p[2], hex) end
end
-- remap colours of pixels inside m via map
function W.remap(c, m, map)
  m:each(function(x, y) local h = W.get(c, x, y) if h and map[h] then c:put(x, y, map[h]) end end)
end
-- step a pixel along a ramp by d (if its colour is on the ramp)
function W.step(c, x, y, ramp, d)
  local h = W.get(c, x, y)
  for i, r in ipairs(ramp) do if r == h then c:put(x, y, ramp[max(1, min(#ramp, i + d))]) return end end
end

-- ramps (dark .. light, 6 tones)
W.FLEECE = { "#8a7468", "#b89c84", "#d4b890", "#ead4aa", "#f8e8c6", "#fff4d6" }
W.GOLD = { "#6e3a1c", "#a8581e", "#d98322", "#f5b82e", "#ffe38a", "#fff0b0" }

-- curly fleece band: fills m with fleece; bumps every few px read as curls
function W.fleece(c, m, seed)
  local n = X.pillow(m, 2)
  local b = {}
  m:each(function(x, y)
    local h = X.hash(x, y, seed or 7)
    if (x + y * 2) % 4 == 0 then W.addBias(b, x, y, -1) end
    if h < 0.12 then W.addBias(b, x, y, -1) elseif h > 0.9 then W.addBias(b, x, y, 1) end
  end)
  return W.lit(c, m, n, W.FLEECE, { bias = b, amb = 0.3, wrap = 0.4, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
end

-- move every painted pixel (before finish)
function W.shift(c, dx, dy)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % 64, i // 64 pix[(y + dy) * 64 + x + dx] = v own[(y + dy) * 64 + x + dx] = c.own[i] end
  c.pix, c.own = pix, own
end

-- finish (outline), keep position, check, save
function W.save(c, name)
  c:finish{ outline = true }
  local x0, y0, x1, y1 = 99, 99, -1, -1
  for i in pairs(c.pix) do local x, y = i % 64, i // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  print(string.format("%s bbox %d,%d..%d,%d", name, x0, y0, x1, y1))
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = W.OUT .. name .. ".aseprite", png = W.OUT .. name .. ".png", scale = 1 }
end
return W
