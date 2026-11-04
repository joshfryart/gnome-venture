-- _dC34: jar/pickle helper (chunk C34). Wraps batch2/_b2.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K }
function D.ramp(hi, base, shade, deep) return H.ramp({ hi = hi, base = base, shade = shade, deep = deep }) end
local R = D.ramp
D.R = {
  glass = { "#4f7fb0", "#7fb4dc", "#a8d6ee", "#c9ebf8", "#e4f6ff", "#fbfeff" },
  green = R("#c4e07a", "#5fae4c", "#2f7a47", "#1c4a40"),
  dgreen = R("#8fcf6a", "#3f8f45", "#245f43", "#143a3a"),
  red = R("#ff9a7a", "#e2412e", "#a8243a", "#5c1830"),
  orange = R("#ffc16a", "#f08a28", "#c25a22", "#6e3322"),
  cream = R("#fffbe8", "#f3e6c0", "#cdb98e", "#8a7060"),
  white = R("#fffcf4", "#f0ecde", "#c8c2bc", "#8c829a"),
  purple = R("#e08ad0", "#a8387c", "#732860", "#3e1a45"),
  pink = R("#ffc8dc", "#f07a9c", "#c0487c", "#702a58"),
  brown = R("#e0b27a", "#a8703f", "#764328", "#43241f"),
  tan = R("#f6dca4", "#d9a868", "#a8743f", "#5c3a2c"),
  yellow = R("#fff2a0", "#f5c93a", "#d08a20", "#82481f"),
  gold = R("#ffe9a0", "#f5b82e", "#d98322", "#8f4a1f"),
  stone = R("#e8e6ee", "#aaa9b8", "#74758c", "#444663"),
  wood = R("#e8b982", "#b97a4a", "#864c33", "#51302b"),
  blue = R("#b8e0ff", "#5a9ae0", "#3a64b0", "#243a78"),
}
-- brine ramps (light translucent liquid)
D.BR = {
  clear = R("#f2fbe0", "#c8e8c0", "#8cc4ae", "#4f8a96"),
  amber = R("#fff0b8", "#f0c060", "#c88a3a", "#7a4a30"),
  pink = R("#ffd8e4", "#f090b4", "#c05a8c", "#783462"),
  green = R("#e8f6b0", "#a4d466", "#5c9c52", "#2f6048"),
  rose = R("#ffe2d0", "#f4a8a0", "#c8707c", "#80405a"),
  cream = R("#fff8e0", "#ecdcaa", "#c0a878", "#7c6458"),
}
function D.new(name) D.c = B.new(name) D.occ = HP.mask() D.name = name return D.c end
function D.fin() B.fin() end
-- jar from profile points {{y,hw},...}; returns J {body,inside,y0,y1,level}
function D.jar(o)
  local c, cx, pts = D.c, o.cx or 32, o.pts
  local function hw(y)
    for i = 1, #pts - 1 do
      local a, b = pts[i], pts[i + 1]
      if y >= a[1] and y <= b[1] then
        local t = (y - a[1]) / max(1, b[1] - a[1])
        if o.smooth then t = t * t * (3 - 2 * t) end
        return a[2] + (b[2] - a[2]) * t
      end
    end
    return pts[#pts][2]
  end
  local y0, y1 = pts[1][1], pts[#pts][1]
  local body = HP.mask()
  for y = y0, y1 do local w = floor(hw(y) + .5) for x = cx - w, cx + w - 1 do body:set(x, y) end end
  local inside = body:shrink(1)
  local wall = body:copy():cut(inside)
  local GL = D.R.glass
  local J = { body = body, inside = inside, y0 = y0, y1 = y1, cx = cx, level = o.level or (y0 + 6) }
  wall:each(function(x, y)
    local col = x < cx and GL[5] or GL[3]
    if x >= cx + 1 and body:has(x - 1, y) and not inside:has(x, y) and not body:has(x + 1, y) then col = GL[2] end
    if y == y1 or (y == y0) then col = GL[4] end
    if y >= y1 - 1 and x > cx then col = GL[2] end
    c:put(x, y, col)
  end)
  -- headspace + brine
  local br = o.brine or D.BR.clear
  local air, liq = HP.mask(), HP.mask()
  inside:each(function(x, y) if y < J.level then air:set(x, y) else liq:set(x, y) end end)
  air:each(function(x, y) c:put(x, y, x < cx - 2 and "#eefaff" or "#d8f0fa") end)
  local mx = 0 inside:each(function(x, y) mx = max(mx, abs(x - cx + .5)) end)
  H.vcyl(c, liq, br, cx - mx - 1, cx + mx + 1, { amb = .22, wrap = .35, cuts = { 0.3, 0.46, 0.6, 0.76, 0.9 } })
  liq:each(function(x, y) if y == J.level then c:put(x, y, br[6]) end if y == J.level + 1 and x > cx - 3 then c:put(x, y, br[5]) end end)
  J.liq = liq
  D.occ = HP.mask()
  return J
end
-- finishing glints over the contents
function D.glass(J, o)
  o = o or {}
  local c = D.c
  local ys = J.level + 3
  local ye = J.y1 - 4
  for y = ys, ye do
    local x = nil
    for xx = J.cx - 30, J.cx do if J.inside:has(xx, y) then x = xx break end end
    if x then c:put(x + 1, y, o.spec or "#fffbea") end
  end
  for y = J.level + 5, J.y1 - 3 do
    local x = nil
    for xx = J.cx + 30, J.cx, -1 do if J.inside:has(xx, y) then x = xx break end end
    if x and (y % 3 ~= 0) then c:put(x, y, o.bounce or "#78c8dc") end
  end
end
-- paint an item inside the jar (clipped), separated from earlier items
function D.part(J, m, ramp, Rr, o)
  o = o or {}
  local c = D.c
  if J then m:clip(J.inside) end
  if m:count() == 0 then return m end
  B.lit(c, m, ramp, Rr or 2.5)
  local rr = H.ramp(ramp)
  m:edge():each(function(x, y)
    if D.occ:has(x + 1, y) or D.occ:has(x - 1, y) or D.occ:has(x, y + 1) or D.occ:has(x, y - 1) then
      if not D.occ:has(x, y) then c:px(x, y, o.line or rr[1]) end
    end
  end)
  D.occ:add(m)
  return m
end
-- lid: rect x0..x1, y0..y1 cylinder lit, ridges
function D.lid(x0, y0, x1, y1, ramp, o)
  o = o or {}
  local c = D.c
  local m = c:rrect(x0, y0, x1, y1, o.r or 1)
  H.vcyl(c, m, ramp, x0, x1 + 1, { amb = .15, wrap = .3 })
  local r = H.ramp(ramp)
  if o.ridges then
    for x = x0 + 1, x1 - 1, 2 do for y = y0 + 1, y1 - 1 do c:px(x, y, r[2]) end end
    c:px(x0 + 1, y0 + 1, r[6]) c:px(x0 + 1, y0 + 2, r[6])
  end
  for x = x0 + 1, x1 - 1 do c:px(x, y1, r[1]) end
  c:px(x0 + 1, y0, r[6]) c:px(x0 + 2, y0, r[6])
  return m
end
-- cork/stopper (tapered)
function D.cork(cx, y0, y1, hw, ramp)
  local c = D.c
  local m = HP.mask()
  for y = y0, y1 do local w = hw + (y1 - y) * -0 for x = cx - w, cx + w - 1 do m:set(x, y) end end
  H.vcyl(c, m, ramp, cx - hw, cx + hw, { amb = .15, wrap = .3 })
  local r = H.ramp(ramp)
  for i = 0, 5 do local x, y = cx - hw + 1 + (i * 3) % (2 * hw - 1), y0 + 1 + (i * 2) % (y1 - y0) c:px(x, y, r[i % 2 == 0 and 1 or 2]) end
  return m
end
-- label: cream rect with a small motif row
function D.label(x0, y0, w, h, motif)
  local c = D.c
  local m = c:rect(x0, y0, x0 + w - 1, y0 + h - 1)
  c:fillMask(m, "#f6ecd0")
  m:edge():each(function(x, y) c:px(x, y, "#b89a78") end)
  c:px(x0 + 1, y0 + 1, "#fffbea")
  if motif then motif(x0, y0, w, h) end
end
function D.shadow(cx, cy, rx, ry) D.c:groundShadow(cx, cy, rx, ry) end
-- sprinkles/dots inside mask
function D.dots(m, hex, seed, p)
  m:each(function(x, y) if X.hash(x, y, seed) > (p or .9) then D.c:px(x, y, hex) end end)
end
function D.ln(x0, y0, x1, y1, hex, clip) B.ln(D.c, x0, y0, x1, y1, hex, clip) end
function D.ell(cx, cy, rx, ry, a) return B.ell(cx, cy, rx, ry, a or 0) end
return D
