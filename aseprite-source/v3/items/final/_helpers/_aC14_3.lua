-- _aC14_3.lua: private helpers for ph/kitchen-lantern, kitchen-mossy, kitchen-painted, kiwi (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- light a mask with a normal function nf(x,y) -> nx,ny,nz ; bias table optional; returns idx
function A.lightN(c, m, nf, ramp, o)
  o = o or {}
  local n = {}
  m:each(function(x, y) n[K(x, y)] = { norm(nf(x, y)) } end)
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, n
end

-- polygon mask from float points (pixel centres)
function A.poly(pts) return HP.poly(pts) end

-- per-pixel helpers on an idx map
function A.setT(c, idx, ramp, x, y, i, tok)
  local k = K(x, y)
  if idx[k] then i = max(1, min(#ramp, i)) idx[k] = i c:put(x, y, ramp[i], tok) end
end
function A.addT(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  if idx[k] then A.setT(c, idx, ramp, x, y, idx[k] + d, tok) end
end

-- union-of-blobs (moss, fuzz, lumps): circles list {x,y,r}; sphere height max -> normals
function A.blobs(list)
  local m, h = HP.mask(), {}
  for _, b in ipairs(list) do
    local bx, by, r = b[1], b[2], b[3]
    for y = floor(by - r - 1), floor(by + r + 1) do for x = floor(bx - r - 1), floor(bx + r + 1) do
      local q = ((x - bx)^2 + (y - by)^2) / ((r + .45)^2)
      if q <= 1 then
        m:set(x, y)
        local hv = sqrt(1 - q) * r + (b[4] or 0)
        local k = K(x, y)
        if not h[k] or hv > h[k] then h[k] = hv end
      end
    end end
  end
  local n = {}
  local function H(x, y) return h[K(x, y)] or -0.5 end
  m:each(function(x, y)
    local gx = (H(x + 1, y) - H(x - 1, y)) / 2
    local gy = (H(x, y + 1) - H(x, y - 1)) / 2
    n[K(x, y)] = { norm(-gx, -gy, 1.1) }
  end)
  return m, n, h
end

function A.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
