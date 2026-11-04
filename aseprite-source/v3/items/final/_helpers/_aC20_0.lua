-- _aC20_0.lua: private helpers for ph/lemon-cordial, lemon-curd, lemon-seed, lemongrass (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.DIR = DIR
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- index of v in cuts (1..#cuts+1)
function A.q(v, cuts)
  local i = 1
  for j, t in ipairs(cuts or A.CUTS) do if v >= t then i = j + 1 end end
  return i
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- sphere normals blended with a pillow (soft-edged round things)
function A.dome(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 3)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- vertical body of revolution: wfn(y) = half width (nil/<0 = empty) about centre cx (may be .5).
-- returns mask, normals (cylinder across + slope from width change), S (signed -1..1 across)
function A.lathe(cx, y0, y1, wfn)
  local m, n, S = HP.mask(), {}, {}
  for y = y0, y1 do
    local w = wfn(y)
    if w and w >= 0 then
      local dw = ((wfn(y + 1) or w) - (wfn(y - 1) or w)) / 2
      for x = floor(cx - w - 1), floor(cx + w + 1) do
        local s = x - cx
        if abs(s) <= w + 0.01 then
          m:set(x, y)
          local sn = max(-0.97, min(0.97, s / (w + 0.6)))
          local nz = sqrt(1 - sn*sn)
          n[K(x, y)] = { norm(sn, -dw * 0.9 * nz, nz) }
          S[K(x, y)] = sn
        end
      end
    end
  end
  return m, n, S
end

function A.save(c, folder, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../" .. folder .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
