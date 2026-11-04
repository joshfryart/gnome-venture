-- _aB20_2.lua: private helpers for choca-mocha-cosmos-seed / chocolate-cosmos-seed / chrysanthemum-seed / cinnamon.
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local A = setmetatable({}, { __index = G })
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.OUT = app.params.out or (DIR .. "/../ph/")
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
-- tear a mask: remove pixels with T beyond a jagged line. returns the torn-edge mask (pixels next to the gap)
function A.tear(m, T, S, t0, amp, seed, flip)
  local gone = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local j = (X.hash(floor((S[k] or 0) * 6 + 7), 3, seed) - 0.5) * 2 * amp + (S[k] or 0) * (flip or 0)
    local t = T[k] or 0
    if t > t0 + j then gone:set(x, y) end
  end)
  m:cut(gone)
  local e = HP.mask()
  gone:grow(1):each(function(x, y) if m:has(x, y) then e:set(x, y) end end)
  return e
end
-- slim seed along a bezier: half width wfn(t), ridged along its length (ribs = # of dark grooves)
function A.needle(c, p, wfn, ramp, tok, ribs, bias)
  local m, n, T, S = G.tube(p, wfn)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = tok, bias = bias })
  if ribs then
    m:each(function(x, y) local k = K(x, y)
      local s = S[k]
      for _, r in ipairs(ribs) do if abs(s - r) < 0.17 and T[k] > 0.08 and T[k] < 0.92 then
        c:put(x, y, ramp[max(1, idx[k] - 2)], tok) end end
    end)
  end
  return m, n, T, S, idx
end
-- line of pixels along a bezier
function A.bline(c, p, hex, tok, t0, t1, n)
  t0, t1, n = t0 or 0, t1 or 1, n or 40
  local m = HP.mask()
  for i = 0, n do local x, y = G.bez(p, t0 + (t1 - t0) * i / n)
    local xi, yi = floor(x + .5), floor(y + .5)
    m:set(xi, yi) if hex then c:put(xi, yi, hex, tok) end end
  return m
end
return A
