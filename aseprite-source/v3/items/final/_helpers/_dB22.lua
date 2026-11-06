-- dB22 helper: thin layer over batch2/_b2.lua (not edited). First-draft items ph/co*,cr*,cu*.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, P = H.P, K = B.K }
D.new = B.new
D.fin = B.fin
D.ell, D.ln, D.lit, D.seam, D.blade, D.seed = B.ell, B.ln, B.lit, B.seam, B.blade, B.seed
-- 6-tone ramps, dark -> light
D.R = {
  wood = { "#3b2229", "#5e3a2e", "#864c33", "#a8693f", "#cf9159", "#ecbd82" },
  soil = { "#1f1418", "#32211e", "#4a2f26", "#68402f", "#8a5a3d", "#ad7b52" },
  leaf = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" },
  blue = { "#17383f", "#245456", "#33766a", "#4f9a7c", "#7dbc92", "#b4dcab" },
  lime = { "#24544a", "#3f7a4a", "#5e9e4e", "#7cc35a", "#a4de72", "#d0f090" },
  cream = { "#7a5a52", "#a8826a", "#cfa886", "#ebc9a0", "#f8e2b8", "#fff4d6" },
  bean = { "#2a1618", "#46231f", "#683427", "#8a4a30", "#ad6a42", "#d08f5e" },
  red = { "#4a1c34", "#7d2a3e", "#b0343c", "#d8483c", "#f06c4c", "#ff9c70" },
  gold = { "#6e3a1f", "#a35f22", "#d98322", "#f5b82e", "#ffd060", "#ffeaa0" },
  stone = { "#35384f", "#545774", "#74758c", "#9798aa", "#bcbccb", "#e2e0e6" },
  glass = { "#2f5d8a", "#4a86b0", "#6fb0cc", "#97d2dc", "#c4ecee", "#eefcf6" },
  copper = { "#4d2121", "#7e3a2b", "#b45c34", "#d9803f", "#f0a65a", "#ffd290" },
  pink = { "#5a2250", "#8a2f66", "#c04a7c", "#e46a90", "#f896ae", "#ffc8d2" },
  seedtan = { "#6a4a30", "#8f6a42", "#b48c58", "#d4ae74", "#ecca94", "#fae6b8" },
  black = { "#150f1c", "#21172a", "#32243a", "#473450", "#624d70", "#85709a" },
  green2 = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" },
}
-- contact/drop shadow of a mask, shifted
function D.sh(c, m, dx, dy, hex) c:fillMask(m:shift(dx or 1, dy or 1), hex or "#1f1a2e") end
-- ground shadow ellipse (2 tone)
function D.ground(c, cx, cy, rx, ry)
  c:fillMask(c:ellipse(cx, cy, rx, ry), "#8f8aa6")
  c:fillMask(c:ellipse(cx, cy, max(1, rx - 3), max(1, ry - 1)), "#6c6890")
end
-- rect lit with a vertical-ish bevel (plank etc.)
function D.rect(c, x0, y0, x1, y1, ramp, R, o) local m = c:rect(x0, y0, x1, y1) D.lit(c, m, ramp, R or 1.6, o) return m end
-- horizontal plank row with grain + nails
function D.plank(c, x0, y0, x1, y1, ramp, seed)
  local m = c:rect(x0, y0, x1, y1)
  D.lit(c, m, ramp, 1.6)
  for i = 0, 2 do
    local gy = y0 + 1 + floor(X.hash(i, seed or 1, 4) * max(1, y1 - y0 - 1))
    local gx = x0 + 2 + floor(X.hash(i, seed or 1, 9) * max(1, x1 - x0 - 10))
    D.ln(c, gx, gy, gx + 4 + floor(X.hash(i, seed or 1, 2) * 4), gy, ramp[2])
  end
  c:px(x0 + 1, (y0 + y1) // 2, ramp[1]) c:px(x1 - 1, (y0 + y1) // 2, ramp[1])
  return m
end
-- mound (soil heap) as half ellipse with flecks
function D.heap(c, cx, by, rx, ry, ramp, fl)
  local m = c:ellipse(cx, by, rx, ry):clip(c:rect(cx - rx - 1, by - ry - 1, cx + rx + 1, by))
  D.lit(c, m, ramp or D.R.soil, min(ry, 4))
  for i, f in ipairs(fl or {}) do
    local x, y = cx + f[1], by + f[2]
    if m:has(x, y) then c:px(x, y, f[3]) if f[4] then c:px(x + 1, y, f[3]) end end
  end
  return m
end
-- leaf scrap blade with veins
function D.scrap(c, ramp, ax, ay, bx, by, w, veins, o)
  o = o or {} o.veins = veins or { 8, 14, 20, 26, 32, 38 } o.slant = o.slant or 2.2
  return D.blade(c, ax, ay, bx, by, w, ramp, o)
end
-- round-ish leaf (ellipse) lit, with midrib toward base (bx,by)
function D.eleaf(c, cx, cy, rx, ry, ang, ramp, rib)
  local m = D.ell(cx, cy, rx, ry, ang)
  D.lit(c, m, ramp, min(rx, ry) + .4)
  if rib ~= false then
    local ca, sa = cos(ang), sin(ang)
    D.ln(c, floor(cx - ca * rx * .8 + .5), floor(cy - sa * rx * .8 + .5), floor(cx + ca * rx * .8 + .5), floor(cy + sa * rx * .8 + .5), H.ramp(ramp)[6], m)
  end
  return m
end
-- trefoil / lobed leaf: n ellipses around (cx,cy)
function D.lobed(c, cx, cy, r, n, a0, ramp, lr)
  local all = HP.mask()
  for i = 0, n - 1 do
    local a = a0 + (i / n) * 2 * pi
    local m = D.ell(cx + cos(a) * r, cy + sin(a) * r, lr or r * .8, (lr or r * .8) * .8, a)
    all:add(m) D.lit(c, m, ramp, (lr or r * .8) * .8)
  end
  return all
end
function D.stem(c, pts, hexes) -- polyline stem 1px + shade px beside
  for i = 1, #pts - 1 do D.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hexes[1]) end
end
-- tube of const width via H.cyl
function D.tube(c, ax, ay, bx, by, w, ramp, o) return H.cyl(c, ax, ay, bx, by, function() return w end, ramp, o) end
function D.px(c, list) for _, p in ipairs(list) do c:px(p[1], p[2], p[3]) end end
function D.spark(c, x, y) c:sparkle(x, y) end
return D
