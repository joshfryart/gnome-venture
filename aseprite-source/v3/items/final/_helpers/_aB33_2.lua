-- _aB33_2.lua: private helpers for ph/garden-gate-gate, garden-gate-straight, garden-gate-tee, garden-hoe (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
-- 6-tone ramps, dark -> light
A.OAK   = { "#3c2228", "#5c3328", "#844c2f", "#ad7144", "#d39a5e", "#f0c88c" }
A.CEDAR = { "#3d2026", "#62302b", "#8e4632", "#b9663f", "#da8d55", "#f5bd7f" }
A.SILV  = { "#3a3240", "#5c5260", "#857a82", "#ad9f9c", "#d2c4b6", "#f0e6d0" }
A.BARK  = { "#2f1d22", "#4a2c27", "#6b3f2c", "#8e5a38", "#b07a4c", "#d4a46c" }
A.IRON  = { "#232234", "#38374e", "#56566f", "#7f7f99", "#adadc2", "#dedeea" }
A.MOSS  = { "#1d4238", "#2a5e42", "#3f8549", "#5fa652", "#8cc463", "#c0de82" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- bias pixels of `target` covered by `caster` shifted (dx,dy) but not by caster itself
function A.cast(bias, target, caster, dx, dy, amt)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end
  end)
  return bias
end

-- bevelled wooden board: pillow normals, 6 tones, grain streaks along `dir` ("v" or "h"), optional knots
function A.board(c, m, ramp, o)
  o = o or {}
  local n, d = X.pillow(m, o.R or 1.6)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  local tok = o.tok or { r = { name = o.name or "wood" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = tok })
  local seed = o.seed or 1
  if o.grain ~= false then
    local dir = o.dir or "v"
    local per = o.per or 3
    m:each(function(x, y)
      local k = K(x, y)
      if (d[k] or 0) >= 0.9 then
        local a, b = x, y
        if dir == "h" then a, b = y, x end
        local w = floor(sin(b * 0.31 + seed * 1.7) * 1.1 + 0.5)
        if (a + w + seed) % per == 0 and X.hash(x, y, seed) > 0.28 then
          local i = idx[k] or 3
          c:put(x, y, ramp[max(1, i - 1)], tok)
        end
      end
    end)
  end
  for _, kn in ipairs(o.knots or {}) do
    local x, y = kn[1], kn[2]
    if m:has(x, y) then
      c:put(x, y, ramp[1], tok)
      if m:has(x + 1, y) then c:put(x + 1, y, ramp[2], tok) end
      if m:has(x, y - 1) then c:put(x, y - 1, ramp[min(6, (idx[K(x, y - 1)] or 3) + 1)], tok) end
    end
  end
  return idx, tok, d
end

-- round pole/log/handle along a straight axis: cylinder normals, 6 tones; returns m, idx, T, S
function A.pole(c, ax, ay, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  if o.cut then m:cut(o.cut) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local tok = o.tok or { r = { name = o.name or "pole" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = tok })
  return m, idx, T, S, tok, n
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- bolt/nail head: 2x2 iron with a lit corner
function A.nail(c, x, y, tok)
  c:put(x, y, A.IRON[5], tok) c:put(x + 1, y, A.IRON[3], tok)
  c:put(x, y + 1, A.IRON[3], tok) c:put(x + 1, y + 1, A.IRON[1], tok)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
