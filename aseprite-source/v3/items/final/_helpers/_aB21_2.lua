-- _aB21_2.lua: private helpers for ph/compost-scoop + compost_bin-1..3 (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sin, sqrt = math.floor, math.max, math.min, math.sin, math.sqrt
local A = setmetatable({}, { __index = G })
A.WOOD  = { "#2f1d1f", "#51302b", "#7a4732", "#a2653e", "#c68c55", "#e6b880" }
A.WOODG = { "#2a2124", "#47362f", "#6a5040", "#8b6c52", "#ad8f6c", "#cfb58e" }  -- weathered grey oak
A.SOIL  = { "#1c1316", "#2c1d1b", "#412c25", "#583d2f", "#73543b", "#93714c" }
A.STEEL = { "#2b2c42", "#444663", "#6c6e88", "#9496ab", "#c0c0d0", "#e8e7ef" }
A.BRASS = { "#4a2a1c", "#7e4a1f", "#b4782a", "#dca53c", "#f3cf68", "#fff0b0" }
A.CREAM = "#fff4d6"

-- lit plank with grain. o: seed, R, bias, cap (end grain on top, vertical planks)
function A.plank(c, x0, y0, x1, y1, ramp, o)
  o = o or {}
  ramp = ramp or A.WOOD
  local m = c:rect(x0, y0, x1, y1)
  local idx = G.lit(c, m, ramp, { R = o.R or 1.6, bias = o.bias, amb = 0.1 })
  local horiz = (x1 - x0) >= (y1 - y0)
  local L = horiz and (x1 - x0 + 1) or (y1 - y0 + 1)
  local W = horiz and (y1 - y0 + 1) or (x1 - x0 + 1)
  local s = o.seed or 1
  local function dark(x, y, d)
    local t = idx[K(x, y)]
    if t and t > 2 then c:px(x, y, ramp[max(1, t - (d or 1))]) end
  end
  if W >= 3 then
    for g = 1, max(1, floor(W / 2.5)) do
      local off = 1 + floor(X.hash(g, s, 3) * (W - 2))
      local a = floor(X.hash(g, s, 5) * L * 0.35)
      local b = min(L - 2, a + floor(L * 0.4 + X.hash(g, s, 7) * L * 0.45))
      for i = a, b do
        local wob = (sin((i + s * 7 + g * 3) * 0.5) > 0.75) and 1 or 0
        if off + wob > W - 2 then wob = 0 end
        if horiz then dark(x0 + i, y0 + off + wob) else dark(x0 + off + wob, y0 + i) end
      end
    end
    -- one knot
    if L > 10 then
      local i = 3 + floor(X.hash(s, 9, 11) * (L - 6))
      local j = 1 + floor(X.hash(s, 13, 2) * (W - 2))
      if horiz then dark(x0 + i, y0 + j, 2) dark(x0 + i + 1, y0 + j, 1) else dark(x0 + j, y0 + i, 2) dark(x0 + j, y0 + i + 1, 1) end
    end
  end
  if o.cap then -- paler end grain on top with a ring dot
    for x = x0, x1 do c:px(x, y0, x == x0 and ramp[5] or ramp[6]) end
    for x = x0, x1 do c:px(x, y0 + 1, x == x1 and ramp[3] or ramp[5]) end
    c:px(floor((x0 + x1) / 2), y0, ramp[4])
  end
  return m, idx
end

function A.nail(c, x, y) c:px(x, y, A.STEEL[2]) c:px(x - 1, y - 1 >= 0 and y or y, A.STEEL[5]) end

-- compost dome: flat bottom at by. bits = { {x,y,kind}, ... }
function A.heap(c, cx, by, rx, ry, bits, o)
  o = o or {}
  local m, n = G.oval(cx, by, rx, ry, 0, 0.8)
  m:clip(c:rect(cx - rx - 2, by - ry - 2, cx + rx + 2, by + (o.below or 0)))
  local bias = o.bias or {}
  m:each(function(x, y)
    local h = X.hash(x, y, o.seed or 4)
    local k = K(x, y)
    if h < 0.14 then bias[k] = (bias[k] or 0) + 1 elseif h > 0.86 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local v = X.light(n, { amb = 0.08, wrap = 0.3 })
  X.tone(c, m, v, A.SOIL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias })
  for _, b in ipairs(bits or {}) do A.bit(c, b[1], b[2], b[3]) end
  return m
end

function A.bit(c, x, y, kind)
  if kind == "egg" then c:px(x, y, A.CREAM) c:px(x + 1, y, "#e9d8b4") c:px(x + 1, y + 1, "#b8a07c")
  elseif kind == "peel" then c:px(x, y, "#fb983a") c:px(x + 1, y, "#ee6c22") c:px(x + 1, y + 1, "#a2332e")
  elseif kind == "leaf" then c:px(x, y, "#9dd06c") c:px(x + 1, y, "#6ab455") c:px(x + 1, y - 1, "#45954c") c:px(x + 2, y - 1, "#2e7646")
  elseif kind == "twig" then c:px(x, y, A.WOOD[5]) c:px(x + 1, y + 1, A.WOOD[4]) c:px(x + 2, y + 1, A.WOOD[3]) c:px(x + 3, y + 2, A.WOOD[3])
  elseif kind == "crumb" then c:px(x, y, A.SOIL[6]) end
end

-- hand pixel map
function A.map(c, rows, x0, y0, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:px(x0 + xx - 1, y0 + yy - 1, pal[ch]) end end end
end

-- dark ambient row: pixels of `target` region directly below/next to mask `m` get darkened to ramp col
function A.aoRow(c, m, under, hex)
  m:grow(1):cut(m):each(function(x, y) if under:has(x, y) then c:px(x, y, hex) end end)
end
return A
