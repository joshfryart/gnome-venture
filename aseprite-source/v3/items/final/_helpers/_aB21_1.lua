-- _aB21_1.lua: private helpers for cold-brew-coffee, collard, collard-seed, columbine-seed (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Output goes to app.params.out.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs

-- row-based cylinder normals for a vertical body of revolution; tilt(y) -> ny (neg = faces up)
function G.rowN(m, tilt)
  local rows = {}
  m:each(function(x, y) local r = rows[y]
    if not r then rows[y] = { x, x } else r[1] = min(r[1], x) r[2] = max(r[2], x) end end)
  local n = {}
  m:each(function(x, y)
    local r = rows[y] local mid = (r[1] + r[2]) / 2 local hw = (r[2] - r[1]) / 2 + 0.5
    local t = max(-0.95, min(0.95, (x - mid) / hw))
    local ny = tilt and tilt(y) or 0
    n[K(x, y)] = { G.norm(t, ny, sqrt(1 - t * t)) }
  end)
  return n, rows
end

-- torn edge: remove pixels of m beyond a jagged line. f(x,y) -> signed distance (positive = keep side);
-- the cut is offset by a stepped noise of amplitude amp, step len px
function G.tear(m, f, amp, step, seed)
  local cut = HP.mask()
  m:each(function(x, y)
    local d = f(x, y)
    local q = floor((x + y * 0.5) / (step or 2))
    local j = (X.hash(q, 7, seed or 1) - 0.5) * 2 * (amp or 1.5)
    if d + j < 0 then cut:set(x, y) end
  end)
  m:cut(cut)
  -- drop lone pixels left by the jag
  local lone = HP.mask()
  m:each(function(x, y)
    local nb = 0
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if m:has(x + d[1], y + d[2]) then nb = nb + 1 end end
    if nb <= 1 then lone:set(x, y) end
  end)
  m:cut(lone)
  return m
end

-- glossy sphere-ish seed: ramp tones + cream glint
function G.ball(c, cx, cy, rx, ry, ang, ramp, tok, bias)
  local m, n = G.oval(cx, cy, rx, ry, ang, 0.9)
  local idx = G.toneN(c, m, n, ramp, { tok = tok, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  return m, n, idx
end
return G
