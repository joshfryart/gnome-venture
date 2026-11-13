-- socks.lua : sock-<size>-<family>-<knob|hole>  (edge-only layers; all four sides in one file, layers top/right/bottom/left)
-- knob: pixels to stamp (outline + family fill, incl. one junction row on the body edge).  hole: family rim ring on body pixels + ERASE marker (#ff00ff) on the cut-out.
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua")
local S = {}
local FAMSH = { body = 0xb03e34, mind = 0x7a5cc0, craft = 0xc08a10 }

function S.knobSide(c, side, fam)
  local len = L.sideLen(c, side)
  local cv = L.cv(c.W, c.H)
  local inK2 = function(u, v) return u >= 0 and u <= len - 1 and (v == 0 or (v >= 1 and L.inK(c, fam, len, u, v - 1))) end
  local list = {}
  for v = 0, c.T do for u = 0, len - 1 do if inK2(u, v) then
    local x, y = L.sideXY(c, side, u, v)
    local edge = not (inK2(u - 1, v) and inK2(u + 1, v) and inK2(u, v + 1))
    list[#list + 1] = { x, y, edge }
  end end end
  local isEdge = {}
  for _, p in ipairs(list) do cv:set(p[1], p[2], p[3] and L.INK or L.FAM[fam]); isEdge[p[2] * 1000 + p[1]] = p[3] end
  for _, p in ipairs(list) do   -- 1 px lit edge up-left, 1 px shaded edge down-right (inside the outline)
    local x, y = p[1], p[2]
    if not p[3] then
      local function ink(xx, yy) return cv:get(xx, yy) == L.INK end
      if ink(x - 1, y) or ink(x, y - 1) then cv:set(x, y, L.FAMLIGHT[fam])
      elseif ink(x + 1, y) or ink(x, y + 1) then cv:set(x, y, FAMSH[fam]) end
    end
  end
  return cv
end

function S.holeSide(c, side, fam)
  local len = L.sideLen(c, side)
  local ring, cut = L.cv(c.W, c.H), L.cv(c.W, c.H)
  local inH = {}
  local function hxy(u, d) if u < 0 or u > len - 1 or d < 0 or d > c.T - 1 or not L.inK(c, fam, len, u, d) then return nil end; return L.sideXY(c, side, u, -d) end
  for d = 0, c.T - 1 do for u = 0, len - 1 do
    local x, y = hxy(u, d)
    if x then cut:set(x, y, L.ERASE); inH[y * 1000 + x] = true end
  end end
  for d = -1, c.T do for u = -1, len do
    if not hxy(u, d) then
      local x, y = L.sideXY(c, side, u, -d)
      local nb = false
      for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do if inH[(y + o[2]) * 1000 + x + o[1]] then nb = true end end
      if nb and L.inBody(c, x - c.T, y - c.T) then ring:set(x, y, L.FAM[fam]) end
    end
  end end
  return ring, cut
end

function S.build(c, fam, kind)
  local layers = {}
  local tile = L.cv(c.W, c.H)   -- hidden neutral test tile
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do if L.inBody(c, x, y) then tile:set(c.T + x, c.T + y, L.isRim(c, x, y) and L.INK or 0x8a7a66) end end end
  layers[#layers + 1] = { name = "test-tile (hidden)", cv = tile, hidden = true }
  local cuts = L.cv(c.W, c.H)
  for _, side in ipairs(L.SIDES) do
    if kind == "knob" then layers[#layers + 1] = { name = "knob-" .. side, cv = S.knobSide(c, side, fam) }
    else
      local ring, cut = S.holeSide(c, side, fam)
      layers[#layers + 1] = { name = "hole-rim-" .. side, cv = ring }
      cuts:blit(cut, 0, 0)
    end
  end
  if kind == "hole" then layers[#layers + 1] = { name = "erase-marker", cv = cuts } end
  L.save(D .. "../" .. c.name .. "/sock-" .. c.name .. "-" .. fam .. "-" .. kind, c.W, c.H, layers)
end
return S
