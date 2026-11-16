-- Gold Spike Tiara (pl-bjq-4), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Thornblade, uncommon, Reef of the Box-Jelly Queen. "Four gold spikes from a crown that is mostly bubbles."
-- A tiara seen a little from above: the circlet is a ring of sea-glass bubbles (small dim ones along the back,
-- bigger bright ones round the front, the biggest in the middle holding the face). Exactly four bevelled gold
-- spikes stand up out of the ring (two tall inner, two shorter outer), each with a lit left face, a shaded right
-- face and a gold band at its foot.
-- Haiku weakness fixed: five spikes on a lumpy bubble cloud with no ring read; now four spikes and a clear
-- circlet (back and front arcs), bubbles with glass glints and reflection crescents.
-- quirk: the crown is mostly bubbles, and one has just come loose and is drifting up off the top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-4-yard", 64)

local GOLD = { "#6e3416", "#a85a1c", "#d98322", "#f5b82e", "#ffe38a", "#fff4c0" }
local BUB  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ae4e0", "#d0f6f0", "#f0fffa" }

c:groundShadow(32, 55, 19, 2)
local CX, CY, RX, RY = 32, 40, 20, 7

local function bubble(x, y, r, dim)
  local m = c:ellipse(x, y, r, r)
  local I, T = O.shade(c, m, BUB, { sphere = { x - r * .4, y - r * .5, r + 2 }, amb = dim and .12 or .3, wrap = .45, rim = not dim, sep = BUB[1] })
  if dim then O.tex(c, I, T, BUB, function() return -1 end) end
  -- glass: glint upper left, reflection crescent lower right
  local gx, gy = math.floor(x - r * .45), math.floor(y - r * .45)
  O.mark(c, { { gx, gy } }, BUB[6])
  if r >= 4 then
    O.mark(c, { { gx + 1, gy } }, BUB[6])
    for a = .2, 1.2, .25 do O.mark(c, { { math.floor(x + math.cos(a) * (r - 1.5) + .5), math.floor(y + math.sin(a) * (r - 1.5) + .5) } }, BUB[5]) end
  end
end

-- back arc bubbles (small, dim)
for _, th in ipairs({ -2.9, -2.45, -2.0, -1.57, -1.14, -.69, -.24 }) do
  bubble(CX + RX * math.cos(th), CY + RY * math.sin(th) - 1, 2.6, true)
end

-- four gold spikes, bevelled
local spikes = { { 15, 23, 4 }, { 25, 11, 5 }, { 39, 11, 5 }, { 49, 23, 4 } }
local bases = { 18, 27, 37, 46 }
for i, sp in ipairs(spikes) do
  local bx, by, w = bases[i], 39, sp[3]
  local tx, ty = sp[1], sp[2]
  local m = c:poly{ { bx - w, by }, { bx + w, by }, { tx + .5, ty } }
  local tok = { r = { name = "spike" } }
  m:each(function(x, y)
    -- the ridge line from tip to base centre splits lit / shaded faces
    local f = (y - ty) / (by - ty)
    local rx = tx + (bx - tx) * f
    local d = x + .5 - rx
    local idx
    if d < -w * f * .55 then idx = 5 elseif d < 0 then idx = 4 elseif d < w * f * .5 then idx = 3 else idx = 2 end
    if y > by - 3 then idx = math.max(1, idx - 1) end -- AO where it sinks into the ring
    c:put(x, y, GOLD[idx], tok)
  end)
  -- ridge glint near the tip
  O.mark(c, { { math.floor(tx + (bx - tx) * .2), math.floor(ty + (by - ty) * .2) } }, GOLD[6])
  -- gold collar at its foot
  O.shade(c, c:rrect(bx - w - 1, by - 1, bx + w + 1, by + 1, 1), GOLD, { R = 1, amb = .3, wrap = .4, sep = GOLD[1] })
end

-- front arc bubbles, outer to inner
for _, b in ipairs({ { 1.52, 3 }, { 1.62, 3 }, { 1.0, 4.2 }, { 2.14, 4.2 }, { .55, 5.2 }, { 2.59, 5.2 } }) do
  local th, r = b[1], b[2]
  if th > 1.5 and th < 1.7 then th = (b[2] == 3 and b[1] == 1.52) and .12 or 3.02 end
  bubble(CX + RX * math.cos(th), CY + RY * math.sin(th) - 1, r)
end
-- the big centre bubble with the face
bubble(32, 45, 8.5)

c:eyeLocked(26, 42)
c:eyeLocked(34, 42)
c:cheek(25, 48) c:cheek(38, 48)
O.mark(c, { { 31, 49 }, { 32, 50 }, { 33, 49 } }, P.ink)

-- the loose bubble drifting off the top
bubble(51, 14, 2.6)

O.done(c, "pl-bjq-4-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  for _, p in ipairs({ { 54, 8 }, { 55, 8 }, { 53, 9 }, { 56, 9 }, { 54, 10 }, { 55, 10 } }) do put(p[1], p[2], "#5fc4c8") end
  for _, p in ipairs({ { 48, 19 }, { 47, 21 } }) do put(p[1], p[2], "#9ae4e0") end
end)
