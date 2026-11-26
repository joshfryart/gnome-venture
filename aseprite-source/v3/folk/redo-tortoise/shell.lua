-- shared domed scuted shell for the tortoise portraits (hard pixels, ramp S.shell)
local M = {}
function M.dome(c, S, cx, cy, rx, ry, INK, o)
  o = o or {}
  local K = o.k or 1
  local sh = c:ellipse(cx, cy, rx, ry):clip(c:rect(0, 0, c.w - 1, c.h - 1))
  c:part(sh, S.shell, { band = 3, nopop = true })
  local sr = S.shell
  local rimIn = sh:shrink(o.rim or 5)
  local colr = {}
  local SX, SY = o.sx or 11, o.sy or 9
  local function centers(x, y)
    local best, second, bi = 1e9, 1e9, nil
    for row = -8, 8 do
      local ry0 = cy - (o.top or 30) + row * SY
      if math.abs(ry0 - y) < SY * 1.6 then
        local off = (row % 2 == 0) and 0 or SX / 2
        for k = -8, 8 do
          local px = cx + off + k * SX
          if math.abs(px - x) < SX * 1.6 then
            local d = math.sqrt((px - x) ^ 2 + ((ry0 - y) * 1.25) ^ 2)
            if d < best then second = best best = d bi = { px, ry0 } elseif d < second then second = d end
          end
        end
      end
    end
    return best, second, bi
  end
  sh:each(function(x, y)
    local X, Y = x + .5, y + .5
    local dx, dy = (X - cx) / rx, (Y - cy) / ry
    local r = math.sqrt(dx * dx + dy * dy)
    local a = math.atan(Y - cy, X - cx)
    local col
    if not rimIn:has(x, y) then
      -- marginal rim band: alternating scutes, deep seams, dark underside lower down
      local seg = (a / (2 * math.pi) + 1) * (o.nseg or 30)
      local f = seg - math.floor(seg)
      local edge = not sh:shrink(1):has(x, y)
      local low = Y > cy - ry * 0.35
      if f < 0.16 then col = sr.deep
      elseif edge then col = low and sr.deep or sr.hi
      elseif not sh:shrink(2):has(x, y) and (o.rim or 5) > 3 then col = low and sr.shade or sr.base
      else col = low and sr.shade or ((math.floor(seg) % 2 == 0) and sr.base or sr.hi) end
      if not edge and not low and not sh:shrink(2):has(x, y) then col = sr.hi end
    else
      local d1, d2, c0 = centers(X, Y)
      if d2 - d1 < 1.5 * K then col = sr.deep
      elseif d2 - d1 < 2.4 * K and not o.noshade then col = sr.shade
      else
        local ox, oy = X - c0[1], (Y - c0[2]) * 1.25
        local t = ox * 0.6 + oy * 0.8
        if t < -3.2 * K then col = sr.hi elseif t > 3.4 * K then col = sr.shade else col = sr.base end
        if S.ray then
          if d1 < 1.9 then col = S.ray.hi
          elseif d1 < 3.6 and (math.abs(ox) < 0.7 or math.abs(oy) < 0.9) then col = S.ray.base end
        end
      end
      -- inner ring seam where rim band begins
      if not sh:shrink((o.rim or 5) + 1):has(x, y) then col = sr.deep end
    end
    colr[#colr + 1] = { x, y, col }
  end)
  for _, q in ipairs(colr) do c:put(q[1], q[2], q[3]) end
  return sh
end
-- ink seam where the plastron meets the shell
function M.seam(c, sh, tor, INK)
  tor:grow(1):cut(tor):each(function(x, y) if sh:has(x, y) then c:put(x, y, INK) end end)
end
return M
