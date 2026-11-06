-- dC10 helper: first-draft toolkit over batch2/_b2.lua (shared files untouched).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new, D.lit, D.ell, D.ln, D.polyline, D.seam, D.ramp, D.sweep, D.blade = B.new, B.lit, B.ell, B.ln, B.polyline, B.seam, H.ramp, H.sweep, B.blade
function D.fin() H.fin(B.c) end
function D.rect(c, x0, y0, x1, y1, ramp, R) local m = c:rect(x0, y0, x1, y1) B.lit(c, m, ramp, R or 3) return m end
function D.rrect(c, x0, y0, x1, y1, r, ramp, R) local m = c:rrect(x0, y0, x1, y1, r) B.lit(c, m, ramp, R or 3) return m end
function D.cyl(c, m, ramp, x0, x1) H.vcyl(c, m, ramp, x0, x1) return m end
-- leaf scrap with midrib + veins
function D.scrap(c, cx, cy, rx, ry, ang, ramp)
  local r = H.ramp(ramp or "moss")
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, r, 3.2)
  local ca, sa = cos(ang), sin(ang)
  for i = -rx + 2, rx - 2 do
    local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
    if m:has(x, y) then c:px(x, y, r[6]) end
  end
  for i = -rx + 4, rx - 4, 4 do for s = 1, ry - 2 do for _, sg in ipairs{ -1, 1 } do
    local u, v = i + s * 0.9, s * sg
    local x, y = floor(cx + ca * u - sa * v + .5), floor(cy + sa * u + ca * v + .5)
    if m:has(x, y) then c:px(x, y, sg < 0 and r[5] or r[2]) end
  end end end
  return m
end
-- ribbed leaf ellipse
function D.leafE(c, cx, cy, rx, ry, ang, ramp, nv)
  local r = H.ramp(ramp)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, r, 1.8)
  local ca, sa = cos(ang), sin(ang)
  for i = -rx + 1, rx - 1 do
    local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
    if m:has(x, y) then c:px(x, y, r[6]) end
  end
  for k = 1, (nv or 1) do
    local u = -rx + 2 + (k - 1) * 3
    for s = 1, ry - 1 do for _, sg in ipairs{ -1, 1 } do
      local uu, v = u + s, s * sg
      local x, y = floor(cx + ca * uu - sa * v + .5), floor(cy + sa * uu + ca * v + .5)
      if m:has(x, y) then c:px(x, y, sg < 0 and r[5] or r[2]) end
    end end
  end
  return m
end
-- glass pane fill: pale sky with a shade strip lower-right and two diagonal glints
function D.glass(c, m, tint)
  local t = tint or { "#e4f6ff", "#cdeaf5", "#a9d6ea" }
  local b1, b2, b3, b4 = m:bbox()
  local bb = { b1, b2, b3, b4 }
  m:each(function(x, y)
    local k = (x - bb[1]) + (y - bb[2])
    c:px(x, y, (x - bb[1]) + (bb[4] - y) < 3 and t[3] or ((x - bb[3]) ^ 2 < 2 or (bb[4] - y) < 2) and t[3] or t[2])
  end)
  m:each(function(x, y) if (x - bb[1]) + (y - bb[2]) == 4 or (x - bb[1]) + (y - bb[2]) == 6 then c:px(x, y, t[1]) end end)
end
-- steam curl
function D.steam(c, x, y, h, hex)
  for i = 0, h do c:px(x + floor(sin(i * 0.9) * 1.6 + .5), y - i, hex or "#fff4d6") end
end
-- glasshouse builder. o: x0,x1,wt (eaves y),fl (glass bottom y),pk (peak y),roof gable|hip|dome,fr {hi,base,shade},mull,plinth,tint,plants
function D.house(c, o)
  local FR = o.fr or { "#fff4d6", "#e2e0e6", "#aaa9b8" }
  local cx = (o.x0 + o.x1) // 2
  local pl = c:rect(o.x0 - 1, o.fl, o.x1 + 1, o.fl + 5)
  B.lit(c, pl, o.plinth or "stone", 2)
  for x = o.x0 + 1, o.x1, 5 do c:px(x, o.fl + 3, "#444663") end
  local wall = c:rect(o.x0, o.wt, o.x1, o.fl - 1)
  local roof
  if o.roof == "gable" then roof = c:poly{ { o.x0 - 1, o.wt }, { cx, o.pk }, { o.x1 + 1, o.wt } }
  elseif o.roof == "hip" then roof = c:poly{ { o.x0 - 1, o.wt }, { o.x0 + 7, o.pk }, { o.x1 - 7, o.pk }, { o.x1 + 1, o.wt } }
  else roof = c:ellipse(cx + 0.5, o.wt, (o.x1 - o.x0) / 2 + 1, o.wt - o.pk):clip(c:rect(0, 0, 63, o.wt)) end
  local all = wall:copy():add(roof)
  D.glass(c, all, o.tint)
  -- plants inside
  if o.plants ~= false then
    for x = o.x0 + 3, o.x1 - 2, 6 do
      local bm = B.ell(x, o.fl - 4, 4, 3, 0)
      B.lit(c, bm, "moss", 2)
      c:px(x + 1, o.fl - 4, "#e8493b") c:px(x - 2, o.fl - 3, "#ff8a5c")
    end
  end
  -- frame
  local n = o.mull or 7
  for x = o.x0, o.x1, n do for y = o.wt, o.fl - 1 do c:px(x, y, FR[2]) end end
  for x = o.x0 + 1, o.x1, n do for y = o.wt, o.fl - 1 do c:px(x, y, FR[1]) end end
  for x = o.x0, o.x1 do c:px(x, o.wt, FR[1]) c:px(x, o.wt + 1, FR[3]) c:px(x, o.fl - 1, FR[3]) end
  c:px(o.x1, o.wt, FR[2])
  if o.roof == "dome" then
    for x = o.x0, o.x1, n do for y = o.pk, o.wt do if roof:has(x, y) then c:px(x, y, FR[2]) end end end
    roof:edge():each(function(x, y) if y < o.wt then c:px(x, y, FR[2]) end end)
    for x = o.x0, o.x1, n do c:px(x, o.wt, FR[1]) end
  else
    local rx = { o.x0 - 1, o.x1 + 1 }
    local ax, bx = o.roof == "gable" and cx or o.x0 + 7, o.roof == "gable" and cx or o.x1 - 7
    B.ln(c, o.x0 - 1, o.wt, ax, o.pk, FR[1]) B.ln(c, o.x0, o.wt, ax + 1, o.pk + 1, FR[2])
    B.ln(c, o.x1 + 1, o.wt, bx, o.pk, FR[3]) B.ln(c, o.x1, o.wt, bx - 1, o.pk + 1, FR[3])
    if o.roof == "hip" then for x = ax, bx do c:px(x, o.pk, FR[1]) c:px(x, o.pk + 1, FR[2]) end end
    for i = 1, 2 do local rr = i / 3
      local ex = floor(o.x0 + (o.x1 - o.x0) * rr + .5)
      B.ln(c, ex, o.wt, floor(ax + (bx - ax) * rr + .5), o.pk + 1, FR[2], roof)
    end
  end
  return all, roof, wall
end
return D
