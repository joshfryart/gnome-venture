-- _dC15: helper for chunk dC15 (ph/k..l). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local HP, X, H = B.HP, B.X, B.H
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local D = { B = B, HP = HP, X = X, H = H, K = B.K, P = H.P }
function D.new(name) return B.new(name) end
function D.R(r) return H.ramp(r) end
D.ell, D.lit, D.ln, D.blade, D.seed = B.ell, B.lit, B.ln, B.blade, B.seed
function D.fin() B.fin() end
-- cast a hard shadow of mask m, offset dx,dy, onto mask `onto` (or anywhere)
function D.cast(c, m, onto, dx, dy, hex)
  local s = m:shift(dx, dy)
  if onto then s:clip(onto) end
  c:fillMask(s, hex)
end
-- union of ellipses {cx,cy,rx,ry,ang}
function D.blob(list)
  local m = HP.mask()
  for _, e in ipairs(list) do m:add(B.ell(e[1], e[2], e[3], e[4], e[5])) end
  return m
end
D.LAV = { "#26433f", "#3b6358", "#5a8470", "#7fa88b", "#a6c8a4", "#cfe3bd" }
-- lavender spike: stem from (x,y) up h px, flower head the top `hd` px
function D.spike(c, x, y, h, hd)
  local P = D.P
  hd = hd or 6
  for i = 0, h - hd do c:px(x, y - i, "#5a8470") end
  local top = y - h
  for i = 0, hd - 1 do
    local yy = top + i
    local w2 = (i == 0) and 0 or 1
    if w2 == 0 then c:px(x, yy, P.dusk.hi)
    else
      c:px(x - 1, yy, (i % 2 == 0) and P.dusk.hi or P.dusk.base)
      c:px(x, yy, (i % 2 == 0) and P.dusk.base or P.dusk.shade)
      c:px(x + 1, yy, (i % 2 == 0) and P.dusk.shade or P.dusk.deep)
    end
  end
end
-- lavender clump: grey-green tuft with 3 spikes
function D.clump(c, cx, cy, hs)
  hs = hs or { 11, 15, 12 }
  local m = B.ell(cx, cy, 6, 3.4)
  B.lit(c, m, D.LAV, 2)
  for i = 1, 6 do local x = cx - 5 + i * 1.6 c:px(floor(x), cy - 1 + (i % 2), D.LAV[6]) end
  D.spike(c, cx - 4, cy - 1, hs[1], 6)
  D.spike(c, cx, cy - 2, hs[2], 7)
  D.spike(c, cx + 4, cy - 1, hs[3], 6)
end
function D.bee(c, x, y)
  local P = D.P
  c:px(x, y - 1, P.cream) c:px(x + 1, y - 2, P.cream)
  for i = 0, 3 do c:px(x + i, y, (i % 2 == 0) and P.gold.base or P.ink) end
  c:px(x, y + 1, P.gold.shade) c:px(x + 1, y + 1, P.ink) c:px(x + 2, y + 1, P.gold.shade)
end
function D.ladybird(c, x, y)
  local P = D.P
  c:fillMask(c:ellipse(x + 1, y + 1, 2, 1.4), P.ember.base)
  c:px(x + 1, y, P.ember.hi) c:px(x, y + 1, P.ink) c:px(x + 2, y + 2, P.ink) c:px(x + 3, y + 1, P.ink)
end
-- lavender-border run builder. runs = list of {x0,y0,x1,y1,dir}; clumps along centre line
function D.runs(c, runs, o)
  local P = D.P
  o = o or {}
  local band = HP.mask()
  for _, r in ipairs(runs) do band:add(c:rect(r[1], r[2], r[3], r[4])) end
  local kerb = band:copy():grow(2)
  c:fillMask(kerb, P.stone.shade)
  c:fillMask(band:copy():grow(1), P.stone.base)
  -- kerb top-left highlight row
  kerb:each(function(x, y) if not band:copy():grow(1):has(x, y) and not band:has(x, y) and not kerb:has(x - 1, y - 1) then end end)
  local soil = D.R("wood")
  B.lit(c, band, { soil[1], soil[2], soil[2], soil[3], soil[3], soil[4] }, 3)
  for y = band:bbox() and 0 or 0, 0 do end
  local pts, seen = {}, {}
  for _, r in ipairs(runs) do
    if r[5] == "h" then
      local cy = r[4] - 4
      local x = r[1] + 5
      while x <= r[3] - 4 do local k = x .. "," .. cy if not seen[k] then seen[k] = 1 pts[#pts + 1] = { x, cy } end x = x + 10 end
    else
      local cx = floor((r[1] + r[3]) / 2)
      local y = r[2] + 8
      while y <= r[4] - 2 do local k = cx .. "," .. y if not seen[k] then seen[k] = 1 pts[#pts + 1] = { cx, y } end y = y + 10 end
    end
  end
  table.sort(pts, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
  local hv = { { 11, 15, 12 }, { 13, 11, 15 }, { 12, 16, 10 } }
  for i, p in ipairs(pts) do D.clump(c, p[1], p[2], hv[i % 3 + 1]) end
  return band, pts
end
return D
