-- aged-goat-cheese (final, Opus). A tall truncated-pyramid goat cheese (Valencay style) with a wrinkled ash-grey rind
-- dusted in white bloom, a wedge cut from the front corner showing the chalky ivory pate, a thin creamline under the
-- rind and a darker paste where the two cut faces meet. It stands on a log-slice board (end-grain rings, pale pith,
-- furrowed bark side) with a contact shadow. quirk: a little sprig of thyme left on the board.
local NAME = "aged-goat-cheese"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local RIND = { "#2a2a38", "#424458", "#5e6076", "#82859c", "#aeb0c2", "#dcdde6" }
local PATE = { "#8c7a58", "#b6a276", "#d6c698", "#ebdfb8", "#f7efd4", "#fff9e8" }
local CREAM = "#e2cc8e"
local WOOD = { "#4a2a22", "#6c3e2a", "#905c38", "#b4804c", "#d4a466", "#efc88a" }
local BARK = { "#2e1c1c", "#44281f", "#5e3a28", "#7a5034" }
local THYME = { "#2f5a3e", "#4f8250", "#7cae62", "#b4d68a" }

---------------------------------------------------------------- board (log slice)
local bx, by, brx, bry = 32, 50, 23, 6.5
local top = c:ellipse(bx, by, brx, bry)
local side = HP.mask()
for d = 1, 3 do side:add(top:shift(0, d)) end
side:cut(top)
local btok = { r = { name = "board" } }
side:each(function(x, y)
  local i = 3
  if (x * 7 + floor(y / 2) * 3) % 5 == 0 then i = 1 elseif x > bx + 8 then i = 2 elseif x < bx - 14 then i = 4 end
  c:put(x, y, BARK[i], btok)
end)
-- end grain: rings around an off-centre pith, lit upper-left, darker toward the shade rim
local px0, py0 = bx + 3, by + 0.5
top:each(function(x, y)
  local dx, dy = (x - px0) / 1.0, (y - py0) * (brx / bry)
  local r = sqrt(dx * dx + dy * dy)
  local e = ((x - bx) / (brx + .5)) ^ 2 + ((y - by) / (bry + .5)) ^ 2
  local i = 5
  if (x - bx) + (y - by) * 2.2 > 10 then i = 4 end
  if (x - bx) + (y - by) * 2.2 > 22 then i = 3 end
  if floor(r / 3.4 + 0.3 * sin(y * 1.3)) % 2 == 1 then i = i - 1 end
  if e > 0.8 then i = (x - bx) + (y - by) * 3 > 0 and 2 or 6 end      -- sapwood/cambium rim
  if r < 1.3 then i = 6 end
  c:put(x, y, WOOD[max(1, min(6, i))], btok)
end)
-- radial check crack in the end grain
for t = 0, 7 do local x, y = floor(px0 - 3 - t * 1.4 + .5), floor(py0 + 1 + t * 0.45 + .5) if top:has(x, y) then c:put(x, y, WOOD[2], btok) end end

---------------------------------------------------------------- cheese geometry
local BL, BF, BR = { 15, 48 }, { 33, 52 }, { 46, 46 }
local TL, TF, TR, TB = { 22, 24 }, { 30, 27 }, { 38, 23 }, { 30, 20 }
local Lfb, Lft = { 24, 50.4 }, { 26, 25.5 }       -- cut line on the left (lit) face
local Lrb, Lrt = { 40.5, 48.6 }, { 34.5, 24.9 }   -- cut line on the right (shade) face
local Ib, It = { 30.5, 47 }, { 30, 23.5 }         -- notch reaches the cheese's axis (quarter cut)
local faceL = c:poly{ BL, BF, TF, TL }
local faceR = c:poly{ BF, BR, TR, TF }
local faceT = c:poly{ TL, TF, TR, TB }
local notch = c:poly{ Lfb, { 33, 55 }, Lrb, Lrt, { 31, 27.5 }, It, Lft }
notch:add(c:poly{ Ib, Lfb, Lft, It }):add(c:poly{ Ib, Lrb, Lrt, It })
local planeA = c:poly{ Lfb, Ib, It, Lft }   -- faces right: shaded pate
local planeB = c:poly{ Ib, Lrb, Lrt, It }   -- faces front-left: lit pate
faceL:cut(notch) faceR:cut(notch) faceT:cut(notch)
planeA:cut(planeB)
local cheese = faceL:copy():add(faceR):add(faceT):add(planeA):add(planeB)

-- contact shadow on the board (cast lower-right) under the cheese
local shadow = HP.mask()
for _, d in ipairs{ {1, 0}, {2, 1}, {3, 1}, {1, 1}, {4, 2} } do shadow:add(cheese:shift(d[1], d[2])) end
shadow:clip(top):cut(cheese)
shadow:each(function(x, y) c:put(x, y, A.step(WOOD, c:get(x, y), -2), btok) end)

---------------------------------------------------------------- rind: wrinkled ash with white bloom
local rtok = { r = { name = "rind" } }
local function wrinkle(x, y, s)
  local w = sin(x * 0.95 + sin(y * 0.62 + s) * 2.4) + sin(y * 0.8 - x * 0.35 + s * 2)
  return w
end
local function rindFace(m, base, seed, aoEdge)
  m:each(function(x, y)
    local i = base
    local w = wrinkle(x, y, seed)
    if w > 1.35 then i = i + 1 elseif w < -1.55 then i = i - 1 end
    if X.hash(x, y, seed) > 0.965 then i = i + 1 end           -- bloom specks
    if aoEdge and aoEdge(x, y) then i = i - 1 end
    c:put(x, y, RIND[max(1, min(6, i))], rtok)
  end)
end
rindFace(faceT, 5, 1)
rindFace(faceL, 4, 2, function(x, y) return y >= 48 or (x >= 28 and not faceL:has(x + 1, y)) end)
rindFace(faceR, 3, 3, function(x, y) return y >= 46 and not faceR:has(x, y + 1) end)
-- bevelled edges: bright left-top edge, soft ridge on the left arris, dark arris between L and R faces below
faceT:edge():each(function(x, y) if not faceT:has(x - 1, y) or not faceT:has(x, y - 1) then c:put(x, y, RIND[6], rtok) end end)
for y = 23, 48 do local x = floor(TL[1] + (BL[1] - TL[1]) * (y - TL[2]) / (BL[2] - TL[2]) + .5) + 1
  if faceL:has(x, y) and y % 3 ~= 0 then c:put(x, y, RIND[5], rtok) end end
faceT:each(function(x, y) if faceL:has(x, y + 1) and not faceT:has(x, y + 1) then c:put(x, y, RIND[4], rtok) end end)

---------------------------------------------------------------- pate: chalky core, creamline, rind skin on the cut
local ptok = { r = { name = "pate" } }
local function pateFace(m, base, seed, rindSide)
  local e = m:edge()
  m:each(function(x, y)
    local i = base
    if X.hash(x, y, seed) > 0.88 then i = i - 1 end           -- chalky pores
    if X.hash(x, y, seed + 9) > 0.95 then i = i + 1 end
    c:put(x, y, PATE[max(1, min(6, i))], ptok)
  end)
  -- rind skin (2 px) and creamline (1 px) along the outer side of each cut face
  m:each(function(x, y)
    if rindSide(x, y, 0) then c:put(x, y, RIND[3], ptok)
    elseif rindSide(x, y, 1) then c:put(x, y, CREAM, ptok) end
  end)
end
pateFace(planeA, 3, 21, function(x, y, d) return not planeA:has(x - 1 - d, y) and not planeB:has(x - 1 - d, y) end)
pateFace(planeB, 5, 22, function(x, y, d) return not planeB:has(x + 1 + d, y) and not planeA:has(x + 1 + d, y) end)
-- top rind lip over both cut faces, inner crease where the cut faces meet (ambient)
cheese:each(function(x, y) if (planeA:has(x, y) or planeB:has(x, y)) and not cheese:has(x, y - 1) then c:put(x, y, RIND[4], ptok) end
  if (planeA:has(x, y) or planeB:has(x, y)) and not cheese:has(x, y - 2) and cheese:has(x, y - 1) then c:put(x, y, CREAM, ptok) end end)
planeA:each(function(x, y) if planeB:has(x + 1, y) then c:put(x, y, PATE[2], ptok) end end)
-- base of the cut sits on the board: ambient row
cheese:each(function(x, y) if (planeA:has(x, y) or planeB:has(x, y)) and not cheese:has(x, y + 1) then c:put(x, y, PATE[2], ptok) end end)
-- one moist sheen on the lit cut face
c:put(34, 31, PATE[6], ptok) c:put(34, 32, PATE[6], ptok)

-- a crumb fallen from the cut
c:paint({ "ab", "bc" }, 41, 53, { a = PATE[5], b = PATE[4], c = PATE[2] })

---------------------------------------------------------------- quirk: thyme sprig on the board
local ttok = { r = { name = "thyme" } }
local tp = { { 10, 51 }, { 14, 53 }, { 18, 54 }, { 23, 54 } }
for i = 0, 24 do local x, y = A.bez(tp, i / 24) c:put(floor(x + .5), floor(y + .5), "#6e4e34", ttok) end
-- paired oval leaves, lit side up, AO dot where each leaf meets the stem
for i, q in ipairs{ { 0.1, -1 }, { 0.26, 1 }, { 0.42, -1 }, { 0.58, 1 }, { 0.74, -1 }, { 0.9, 1 } } do
  local x, y = A.bez(tp, q[1]) x, y = floor(x + .5), floor(y + .5)
  if q[2] < 0 then
    c:paint({ ".hl", "lmm", "s.." }, x - 1, y - 2, { h = THYME[4], l = THYME[3], m = THYME[2], s = THYME[1] })
  else
    c:paint({ "s..", "lmm", ".md" }, x - 1, y + 1, { l = THYME[3], m = THYME[2], d = THYME[1], s = THYME[1] })
  end
end
c:paint({ "hl", "lm" }, 23, 52, { h = THYME[4], l = THYME[3], m = THYME[2] })

A.save(c, NAME)
