-- Family 4 shared auto-join geometry (families.md "Apron and outline geometry").
-- Each sheet quarter is rendered as the matching quadrant of a virtual 42x42 tile whose
-- empty sides / inner-corner notch are given by cfg. The skeleton is a function of the
-- quarter-local coordinate (tx % 21, ty % 21), so every quarter joins every other.
local A = {}

-- arc pixels (tile coords) from families.md
local ARC = {
  TL = { {9,3},{8,3},{7,4},{6,4},{5,5},{4,6},{4,7},{3,8},{3,9} },
  TR = { {32,3},{33,3},{34,4},{35,4},{36,5},{37,6},{37,7},{38,8},{38,9} },
  BL = { {9,38},{8,38},{7,37},{6,37},{5,36},{4,35},{4,34},{3,33},{3,32} },
  BR = { {32,38},{33,38},{34,37},{35,37},{36,36},{37,35},{37,34},{38,33},{38,32} },
}
local ARCSET, ARCROW = {}, {}
for k, pts in pairs(ARC) do
  ARCSET[k], ARCROW[k] = {}, {}
  for _, p in ipairs(pts) do
    ARCSET[k][p[1] .. "," .. p[2]] = true
    local r = ARCROW[k][p[2]] or { lo = 99, hi = -1 }
    r.lo, r.hi = math.min(r.lo, p[1]), math.max(r.hi, p[1])
    ARCROW[k][p[2]] = r
  end
end

-- outline colour keys: n = umber1, w/e = umber2, s = umber3
-- classify(cfg, x, y) -> "apron" | "ol", side | "in"
function A.classify(cfg, x, y)
  if x < 0 or y < 0 or x > 41 or y > 41 then return "in" end
  local N, E, S, W = cfg.N, cfg.E, cfg.S, cfg.W
  -- outer corner boxes (both sides empty)
  local box
  if N and W and x <= 9 and y <= 9 then box = "TL"
  elseif N and E and x >= 32 and y <= 9 then box = "TR"
  elseif S and W and x <= 9 and y >= 32 then box = "BL"
  elseif S and E and x >= 32 and y >= 32 then box = "BR" end
  if box then
    if ARCSET[box][x .. "," .. y] then
      local dx = (box == "TL" or box == "BL") and x or 41 - x
      local dy = (box == "TL" or box == "TR") and y or 41 - y
      if dy <= dx then return "ol", (box:sub(1, 1) == "T") and "n" or "s" end
      return "ol", (box:sub(2, 2) == "L") and "w" or "e"
    end
    local r = ARCROW[box][y]
    if not r then
      -- rows outside the arc's 3..9 span: rows < 3 (or > 38) are apron, others inside
      if (box:sub(1,1) == "T" and y < 3) or (box:sub(1,1) == "B" and y > 38) then return "apron" end
      if (box:sub(2,2) == "L" and x < 3) or (box:sub(2,2) == "R" and x > 38) then return "apron" end
      return "in"
    end
    if box:sub(2, 2) == "L" then
      if x < r.lo then return "apron" end
    else
      if x > r.hi then return "apron" end
    end
    return "in"
  end
  local d = 99
  local side
  if N and y < d then d, side = y, "n" end
  if S and 41 - y < d then d, side = 41 - y, "s" end
  if W and x < d then d, side = x, "w" end
  if E and 41 - x < d then d, side = 41 - x, "e" end
  if d < 3 then return "apron" end
  if d == 3 then return "ol", side end
  local n = cfg.notch
  if n == "TL" then
    if x < 3 and y < 3 then return "apron" end
    if y == 3 and x <= 3 then return "ol", "n" end
    if x == 3 and y <= 3 then return "ol", "w" end
  elseif n == "TR" then
    if x > 38 and y < 3 then return "apron" end
    if y == 3 and x >= 38 then return "ol", "n" end
    if x == 38 and y <= 3 then return "ol", "e" end
  elseif n == "BL" then
    if x < 3 and y > 38 then return "apron" end
    if y == 38 and x <= 3 then return "ol", "s" end
    if x == 3 and y >= 38 then return "ol", "w" end
  elseif n == "BR" then
    if x > 38 and y > 38 then return "apron" end
    if y == 38 and x >= 38 then return "ol", "s" end
    if x == 38 and y >= 38 then return "ol", "e" end
  end
  return "in"
end

local function isol(cfg, x, y) return (A.classify(cfg, x, y)) == "ol" end

-- band for an inside pixel of a raised mass: "rim" | "bounce" | "shade" | nil
function A.band(cfg, x, y)
  if isol(cfg, x, y-1) or isol(cfg, x-1, y) or isol(cfg, x-1, y-1) then return "rim" end
  if isol(cfg, x, y+1) or isol(cfg, x+1, y) or isol(cfg, x+1, y+1) then return "bounce" end
  for _, o in ipairs({ {0,2},{0,3},{2,0},{3,0},{1,2},{2,1},{2,2} }) do
    if isol(cfg, x+o[1], y+o[2]) then return "shade" end
  end
  return nil
end

-- inside pixel 4-adjacent to the outline/bank line (water edge)
function A.touch(cfg, x, y)
  return isol(cfg, x, y-1) or isol(cfg, x-1, y) or isol(cfg, x, y+1) or isol(cfg, x+1, y)
end

-- sheet quarters: {qx, qy, quadrant, cfg}
A.QUARTERS = {
  { 0, 2, "TL", { N = true, W = true } },
  { 1, 2, "TL", { N = true } },
  { 2, 2, "TR", { N = true } },
  { 3, 2, "TR", { N = true, E = true } },
  { 0, 3, "TL", { W = true } },
  { 1, 3, "TL", {} },
  { 2, 3, "TR", {} },
  { 3, 3, "TR", { E = true } },
  { 0, 4, "BL", { W = true } },
  { 1, 4, "BL", {} },
  { 2, 4, "BR", {} },
  { 3, 4, "BR", { E = true } },
  { 0, 5, "BL", { S = true, W = true } },
  { 1, 5, "BL", { S = true } },
  { 2, 5, "BR", { S = true } },
  { 3, 5, "BR", { S = true, E = true } },
  { 2, 0, "TL", { notch = "TL" } },
  { 3, 0, "TR", { notch = "TR" } },
  { 2, 1, "BL", { notch = "BL" } },
  { 3, 1, "BR", { notch = "BR" } },
}
local QO = { TL = {0,0}, TR = {21,0}, BL = {0,21}, BR = {21,21} }

-- render all 20 drawn quarters. pix(cfg, x, y, lx, ly, qx, qy) -> hex
function A.render(c, pix)
  for _, q in ipairs(A.QUARTERS) do
    local qx, qy, quad, cfg = q[1], q[2], q[3], q[4]
    local o = QO[quad]
    for ly = 0, 20 do for lx = 0, 20 do
      c:px(21*qx + lx, 21*qy + ly, pix(cfg, o[1] + lx, o[2] + ly, lx, ly, qx, qy))
    end end
  end
end

-- quarter-local pixel helper
function A.q(c, qx, qy, lx, ly, hex) c:px(21*qx + lx, 21*qy + ly, hex) end

-- iso quarters = pixel copies of the corner quarters (copy, not flip)
function A.iso(c)
  for _, p in ipairs({ { {0,0},{0,2} }, { {1,0},{3,2} }, { {0,1},{0,5} }, { {1,1},{3,5} } }) do
    local d, s = p[1], p[2]
    for ly = 0, 20 do for lx = 0, 20 do
      c:px(21*d[1] + lx, 21*d[2] + ly, c:get(21*s[1] + lx, 21*s[2] + ly))
    end end
  end
end

A.UMB = { n = "#74462a", w = "#4a2c1a", e = "#4a2c1a", s = "#2a1a10" }
return A
