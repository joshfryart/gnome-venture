-- _aR20_5.lua: private helpers for ph/blackcurrant-seed, ph/bladderwrack, ph/blight-shard, ph/blood-lily-seed
-- (final pass, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib). No shared edits.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.HP, A.X, A.K = HP, X, K
A.FINAL = DIR .. "/../ph/"
A.OUT = app.params.out
A.CREAM, A.INK = "#fff4d6", "#2b1c26"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- tear a blade: remove pixels with t beyond a jagged line (tear at the tip end if side=1, at the base if side=0)
-- returns the torn rim mask (pixels of the remaining blade on the tear)
function A.tear(m, T, S, tcut, amp, seed, atBase)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local j = (X.hash(floor(S[k] * 5 + 0.5), 0, seed) - 0.5) * amp + (S[k] * 0.06)
    local zig = ((floor(S[k] * 6) % 2 == 0) and 0.02 or -0.02)
    local lim = tcut + j + zig
    if (not atBase and T[k] > lim) or (atBase and T[k] < lim) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local rim = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local kk = K(x + d[1], y + d[2])
      for _, q in ipairs(cut) do if q == kk then rim:set(x, y) return end end
    end
  end)
  return rim
end

-- glossy sphere (berry / seed): returns mask, idx
function A.ball(c, cx, cy, r, ramp, tok, o)
  o = o or {}
  local m = o.mask or c:ellipse(cx, cy, r, o.ry or r)
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local v = X.light(n, { amb = o.amb or 0.05, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = tok })
  -- cool reflected light on the lower-right rim
  if o.rim then
    local rr = X.rim(n)
    m:edge():each(function(x, y) local k = K(x, y) if rr[k] > 0.55 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, tok) end end)
  end
  return m, idx, n
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.FINAL .. name .. ".aseprite", png = A.FINAL .. name .. ".png", scale = 1 }
  if A.OUT then c:save{ png = A.OUT .. name .. ".png", aseprite = A.OUT .. name .. ".aseprite", scale = 1 } end
end
return A
