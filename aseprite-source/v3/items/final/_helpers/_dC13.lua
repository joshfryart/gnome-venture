-- dC13 helper: first-draft toolkit over _dC10 / batch2/_b2.lua (shared files untouched).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dC10.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- auto 6-tone ramp from a base hex (cool-violet shade, warm light)
function D.R(base)
  local deep = H.mix(base, "#2b1c3a", .62)
  local shade = H.mix(base, "#4a3a86", .32)
  local hi = H.mix(base, "#fff0a0", .42)
  return { deep, shade, H.mix(shade, base, .5), base, H.mix(base, hi, .55), hi }
end
function D.leafS(c, cx, cy, rx, ry, ang, ramp, serrk, nv)
  local m = B.ell(cx, cy, rx, ry, ang)
  if serrk then
    local ed = m:edge() local list, i = {}, 0
    ed:each(function(x, y) i = i + 1 if i % serrk == 0 then list[#list + 1] = { x, y } end end)
    for _, p in ipairs(list) do m:cut(c:rect(p[1], p[2], p[1], p[2])) end
  end
  local r = H.ramp(ramp) B.lit(c, m, r, 1.8)
  local ca, sa = cos(ang), sin(ang)
  for i = -rx + 1, rx - 1 do
    local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
    if m:has(x, y) then c:px(x, y, r[6]) end
  end
  for k = 1, (nv or 2) do
    local u = -rx + 2 + (k - 1) * 3
    for s = 1, ry - 1 do for _, sg in ipairs{ -1, 1 } do
      local x = floor(cx + ca * (u + s) - sa * s * sg + .5) local y = floor(cy + sa * (u + s) + ca * s * sg + .5)
      if m:has(x, y) then c:px(x, y, sg < 0 and r[5] or r[2]) end
    end end
  end
  return m
end
-- leaf scrap base (V fold, midrib) bottom of canvas
function D.scrapBase(c, ramp, cx, cy, rx, ry, ang)
  return D.scrap(c, cx or 30, cy or 52, rx or 22, ry or 7, ang or -0.08, ramp or "moss")
end
-- seed with shadow, 6-ramp, glint
function D.sd(c, cx, cy, rx, ry, ang, ramp, sh, glint) return B.seed(c, cx, cy, rx, ry, ang, ramp, sh or "#1f553f", glint) end
-- stem then leaves: list of {fn args}
function D.stem(c, x0, y0, x1, y1, hex) B.ln(c, x0, y0, x1, y1, hex or "#3f9150") end
-- lobed leaf: n round lobes radiating from (cx,cy), radius r
function D.lobed(c, cx, cy, r, a0, n, ramp, spread, lr)
  local m = B.ell(cx, cy, r * .55, r * .55, 0)
  for i = 0, n - 1 do
    local a = a0 + (i - (n - 1) / 2) * (spread or 0.9)
    m:add(B.ell(cx + cos(a) * r * .6, cy + sin(a) * r * .6, lr or r * .5, (lr or r * .5) * .75, a))
  end
  local rr = H.ramp(ramp) B.lit(c, m, rr, 2)
  for i = 0, n - 1 do local a = a0 + (i - (n - 1) / 2) * (spread or 0.9)
    for t = 0, r * .95 do local x, y = floor(cx + cos(a) * t + .5), floor(cy + sin(a) * t + .5) if m:has(x, y) then c:px(x, y, rr[6]) end end end
  return m
end
return D
