-- _trail.lua: tiny shared helper for the Opus trail markers (32x32). Loads hp.lua, adds
-- T.vol (per-pixel round lighting from a row/column distance field, light from the upper left),
-- T.flat (flat plane: lit top-left rim, dark bottom-right rim), T.grid (ASCII overlay), T.save.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local T = { HP = HP, P = HP.P, DIR = DIR }
local floor, max, min = math.floor, math.max, math.min

function T.new(name) return HP.canvas{ w = 32, h = 32, scale = 1, name = name } end

-- runs inside the mask from (x,y) stepping (dx,dy)
local function run(m, x, y, dx, dy) local n = 0 while m:has(x + dx * (n + 1), y + dy * (n + 1)) do n = n + 1 end return n end

-- ramp R = { darkest .. lightest } (any length). o.lx,o.ly light dir (default -0.7,-0.7), o.bias, o.cuts
function T.vol(c, m, R, o)
  o = o or {}
  local lx, ly = o.lx or -0.75, o.ly or -0.65
  local n = #R
  local bias = o.bias or 0
  local out = {}
  m:each(function(x, y)
    local dl, dr = run(m, x, y, -1, 0), run(m, x, y, 1, 0)
    local dt, db = run(m, x, y, 0, -1), run(m, x, y, 0, 1)
    local tx = (dl - dr) / (dl + dr + 1)
    local ty = (dt - db) / (dt + db + 1)
    local L = (tx * lx + ty * ly) * (o.k or 1) + bias -- -1..1
    if o.f then L = o.f(x, y, L) end
    local t = (L + 1) / 2
    local i = floor(t * n) + 1
    i = max(1, min(n, i))
    -- lower-right silhouette rim one darker
    if o.rim ~= false and (not m:has(x + 1, y) or not m:has(x, y + 1)) and not (not m:has(x - 1, y) or not m:has(x, y - 1)) then i = max(1, i - 1) end
    out[#out + 1] = { x, y, i }
  end)
  for _, p in ipairs(out) do c:put(p[1], p[2], R[p[3]], o.tok) end
  return m
end

-- flat plane: base, upper-left rim lit, lower-right rim shaded. R = {shade, base, hi}
function T.flat(c, m, R, o)
  o = o or {}
  m:each(function(x, y)
    local ul = not m:has(x - 1, y) or not m:has(x, y - 1)
    local lr = not m:has(x + 1, y) or not m:has(x, y + 1)
    local h = R[2]
    if lr then h = R[1] elseif ul and o.lit ~= false then h = R[3] end
    c:put(x, y, h, o.tok)
  end)
  return m
end

function T.fill(c, m, hex) m:each(function(x, y) c:put(x, y, hex) end) return m end

-- ASCII overlay; map char -> hex
function T.grid(c, x0, y0, rows, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch ~= "." and ch ~= " " then
        local v = map[ch] or error("grid: no map for " .. ch)
        c:put(x0 + i - 1, y0 + j - 1, v)
      end
    end
  end
end

-- dark seam on pixels of m that touch mask o
function T.seam(c, m, o, hex)
  m:each(function(x, y)
    if o:has(x - 1, y) or o:has(x + 1, y) or o:has(x, y - 1) or o:has(x, y + 1) then c:put(x, y, hex) end
  end)
end

function T.done(c)
  c:finish{ outline = true }
  HP.report(c)
  HP.assertClean(c)
  local out = app.params.out or (DIR .. "/")
  c:save{ aseprite = out .. c.name .. ".aseprite", png = out .. c.name .. ".png", scale = 1 }
end

return T
