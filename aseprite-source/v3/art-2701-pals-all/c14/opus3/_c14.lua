-- _c14.lua: c14/opus3 richness-pass helpers on top of _opus.lua (tools only, no drawing).
--   local O = dofile(dir .. "/_c14.lua")   -- same table as _opus.lua plus:
--   O.nudge(c, list, d, ramp)    shift painted pixels at {{x,y},..} by d tones within ramp (only if they use that ramp)
--   O.bump(c, x, y, ramp)        tubercle / pebble: lit pixel up-left, shaded pixel under it
--   O.pit(c, x, y, ramp)         dent: dark pixel with a lit lip below-right
--   O.rows(c, x0, y0, rows, map, name)  paint a small char grid (map char -> hex) as one solid part
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local max, min = math.max, math.min

local function findIdx(h, ramp)
  if not h then return nil end
  h = h:lower()
  for i, v in ipairs(ramp) do if v:lower() == h then return i end end
end
function O.nudge(c, list, d, ramp)
  for _, p in ipairs(list) do
    local x, y = p[1], p[2]
    local i = findIdx(c:get(x, y), ramp)
    if i then c.pix[y * c.w + x] = ramp[max(1, min(#ramp, i + d))]:lower() end
  end
end
function O.bump(c, x, y, ramp, k)
  k = k or 2
  O.nudge(c, { { x, y } }, 1, ramp)
  O.nudge(c, { { x, y + 1 }, { x + 1, y + 1 } }, -k, ramp)
end
function O.pit(c, x, y, ramp)
  O.nudge(c, { { x, y } }, -2, ramp)
  O.nudge(c, { { x + 1, y + 1 } }, 1, ramp)
end
function O.rows(c, x0, y0, rows, map, name)
  local tok = { r = { name = name or "rows" } }
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if map[ch] then c:put(x0 + i - 1, y0 + j - 1, map[ch], tok) end
    end
  end
  return tok
end
-- O.radial(c, m, ramp, lx, ly, R, o): dome shading with curved (not straight) tone steps: brightness falls off
--   with distance from a highlight point (lx,ly), times a pillow edge falloff. Registers rim/bounce like O.shade.
function O.radial(c, m, ramp, lx, ly, R, o)
  o = o or {}
  local X, K = O.X, O.K
  local pn = X.pillow(m, o.edge or 4)
  local v = {}
  m:each(function(x, y)
    local d = math.sqrt((x - lx) ^ 2 + (y - ly) ^ 2) / R
    local z = pn[K(x, y)] and pn[K(x, y)][3] or 1
    v[K(x, y)] = math.max(0, math.min(1, (o.top or 1.02) - d * d * .9 - (1 - z) * (o.ef or .6)))
  end)
  local tok = { r = { name = o.name or "dome" } }
  local idx = X.tone(c, m, v, ramp, { cuts = O.CUTS, tok = tok })
  if o.rim or o.bounce then
    c._lit = c._lit or {}
    c._lit[#c._lit+1] = { idx = idx, tok = tok, ramp = ramp, rim = o.rim, bounce = o.bounce, bmax = o.bmax or 3 }
  end
  return idx, tok
end
return O
