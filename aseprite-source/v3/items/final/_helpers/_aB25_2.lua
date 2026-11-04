-- _aB25_2.lua: private helpers for edelweiss-seed, eel-skin, egg-fried-rice, eggplant (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
-- plot a cubic bezier as 1px pixels; colfn(t) -> hex or nil
function G.plot(c, p, colfn, tok, n)
  n = n or 60
  for i = 0, n do local t = i / n local x, y = G.bez(p, t)
    local col = colfn(t) if col then c:put(floor(x + .5), floor(y + .5), col, tok) end end
end
-- paint mask with ramp index from light + bias, returns idx
function G.shade(c, m, n, ramp, cuts, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
end
-- 2-tone ground shadow drawn under everything (owner SHADOW via HP groundShadow, custom colours)
function G.shadow(c, cx, cy, rx, ry, dark, light)
  c:groundShadow(cx, cy, rx, ry)
  local m = HP.ellipse(cx, cy, rx, ry)
  local inner = HP.ellipse(cx + 1, cy, rx - 3, ry - 1)
  m:each(function(x, y) local i = y * c.w + x
    if c.pix[i] then c.pix[i] = inner:has(x, y) and dark or light end end)
end
return G
