-- _dC12: helper for chunk C12 (h* items). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local HP, X, H = B.HP, B.X, B.H
local D = { B = B, HP = HP, X = X, H = H, K = B.K }
local floor, abs, max, min, sin, cos = math.floor, math.abs, math.max, math.min, math.sin, math.cos
D.BRN = { "#2a1a14", "#4a2c1e", "#6e4328", "#8e5a34", "#b07a48", "#d2a068" }
D.BLK = { "#120c18", "#1f1626", "#30243a", "#443552", "#5e4c6e", "#7d6a90" }
D.TAN = { "#6e4a2c", "#9a6a3e", "#c18f54", "#dcae6e", "#efca8c", "#fbe3b0" }
D.CREAM = { "#9a8466", "#c0aa86", "#dcc8a0", "#efdfb8", "#f8ecce", "#fffaea" }
D.STEEL = { "#3a3c52", "#555a74", "#7a809a", "#a0a6bc", "#c8ccdc", "#eceef6" }
D.GREEN = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
D.SAGE = { "#2a4a3a", "#44705a", "#6a9878", "#92bc92", "#bcd8a8", "#e0eec0" }
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) return B.lit(D.c, m, ramp, R, o) end
function D.ell(cx, cy, rx, ry, ang, ramp, R) local m = B.ell(cx, cy, rx, ry, ang) B.lit(D.c, m, ramp, R or min(rx, ry) + .6) return m end
function D.dots(list, hex) for _, p in ipairs(list) do D.c:px(p[1], p[2], p[3] or hex) end end
function D.ln(x0, y0, x1, y1, hex, w) B.ln(D.c, x0, y0, x1, y1, hex) if w then B.ln(D.c, x0 + 1, y0, x1 + 1, y1, hex) end end
function D.fin(nocenter)
  local c = D.c
  if not nocenter then
    local x0, y0, x1, y1 = 99, 99, -1, -1
    for y = 0, c.h - 1 do for x = 0, c.w - 1 do if c.pix[y * c.w + x] ~= nil then
      x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end end end
    if x1 >= 0 then
      local dx, dy = floor((63 - (x0 + x1)) / 2 + .5), floor((63 - (y0 + y1)) / 2 + .5)
      local pix, own = {}, {}
      for y = 0, c.h - 1 do for x = 0, c.w - 1 do
        local sx, sy = x - dx, y - dy
        if sx >= 0 and sy >= 0 and sx < c.w and sy < c.h then pix[y * c.w + x] = c.pix[sy * c.w + sx] own[y * c.w + x] = c.own[sy * c.w + sx] end
      end end
      c.pix, c.own = pix, own
    end
  end
  B.fin()
end
-- sprout: stem (2px) up to tip, leaves list {ax,ay,bx,by,w}
function D.sprout(x, y, tx, ty, stemHex, leaves, ramp, o)
  D.ln(x, y, tx, ty, stemHex, true)
  for _, L in ipairs(leaves) do B.blade(D.c, L[1], L[2], L[3], L[4], L[5], ramp, o or { veins = { 3, 6 } }) end
end
-- seed with fuzz hairs
function D.seed(cx, cy, rx, ry, ang, ramp, shadow, glint) return B.seed(D.c, cx, cy, rx, ry, ang, ramp, shadow, glint) end

-- top-down hedge band tile. rects = list of {x0,y0,x1,y1}; berries = list of {x,y}; returns mask
D.HR = { "#0e2e2c", "#173f33", "#225a3d", "#2f7744", "#46954b", "#6ab458" }
function D.hedge(rects, berries, o)
  o = o or {}
  local c = D.c
  local m = HP.mask()
  for _, r in ipairs(rects) do for y = r[2], r[4] do for x = r[1], r[3] do m:set(x, y) end end end
  -- round corners and spiky edge
  local sp = HP.mask()
  local full = m:copy()
  m:each(function(x, y)
    local nb = 0
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do if not m:has(x + d[1], y + d[2]) then nb = nb + 1 end end
    if nb >= 1 and (x * 3 + y * 5) % 7 == 0 then
      for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
        if not m:has(x + d[1], y + d[2]) and x + d[1] >= 0 and x + d[1] <= 63 and y + d[2] >= 0 and y + d[2] <= 63 then sp:set(x + d[1], y + d[2]) end
      end
    end
  end)
  full:add(sp)
  B.lit(c, full, D.HR, o.R or 5)
  -- leaf marks
  full:each(function(x, y)
    local k = (x * 7 + y * 13) % 11
    if k == 0 then c:px(x, y, D.HR[6]) c:px(x + 1, y, D.HR[5]) elseif k == 5 then c:px(x, y, D.HR[1]) end
  end)
  for _, p in ipairs(berries or {}) do
    c:px(p[1], p[2], "#e8493b") c:px(p[1] + 1, p[2], "#e8493b") c:px(p[1], p[2] + 1, "#b52e3f") c:px(p[1] + 1, p[2] + 1, "#6e2038") c:px(p[1], p[2] - 0, "#ff8a5c")
  end
  return full
end
return D
