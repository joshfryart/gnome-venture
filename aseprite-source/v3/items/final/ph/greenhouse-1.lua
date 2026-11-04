-- greenhouse-1 (aC10_1, Opus single pass). Tier 1: a small timber-framed glasshouse in 3/4 view, gable end to the
-- viewer. Three lit planes: front gable (mid), side wall (shade side, darker glass), side roof (brightest, facing
-- the sky). Slim 2 px oak posts and rafters with grain dashes and pale end grain on the beam ends; 1 px glazing
-- bars. Glass: sky tint lighter at the top, diagonal reflection streaks, a pale core; seedlings in clay pots on a
-- bench read through the glass. Half-glazed door with a raised wood panel and a brass knob (bevel + specular).
-- Red brick plinth (mortar joints, lit top course, AO under the sill). Ground shadow.
-- quirk: the little gable vent is propped open with a stick and a pea tendril has curled out of it.
local NAME = "greenhouse-1"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = G.new2(NAME)

local GL   = { "#2a4c6c", "#3a6e8e", "#5a9ab4", "#86c2d0", "#b6e0e2", "#e8f8f0" }
local WOOD = { "#3e2522", "#5e3828", "#864c33", "#b07444", "#d49a62", "#efc690" }
local BR   = { "#4a2030", "#742c34", "#9e4038", "#c45a3e", "#de8256", "#f2ac80" }
local MOR  = { "#6a5a62", "#9a8a88", "#c8b8a8" }
local POT  = { "#6e3a3c", "#94524a", "#b8705a" }
local PLT  = { "#2c5a4a", "#3e7c56", "#62a464", "#94c87a" }
local BENCH = "#4e3e46"
local BRASS = { "#6a4422", "#a8742a", "#e0b04a", "#fff0b0" }
local VINE = { "#2a6a3c", "#4a9a48", "#86c45c" }
local DARK = { "#1e2438", "#2c3650" }

c:groundShadow(31, 51.5, 21, 1.6)
local T = { r = { name = "house" } }
local function P(x, y, col) c:put(x, y, col, T) end

local AX, AY = 25, 14         -- gable apex
local function gl(y) return AX - (y - AY) * 13 / 16 end
local function gr(y) return AX + (y - AY) * 13 / 16 end

---------------------------------------------------------------- side roof (u along ridge, v down the slope)
local RX_, RY_, DX_, DY_ = 12, -5, 13, 16
local det = RX_ * DY_ - RY_ * DX_
for y = 6, 32 do for x = 24, 52 do
  local u = ((x - AX) * DY_ - (y - AY) * DX_) / det
  local v = (RX_ * (y - AY) - RY_ * (x - AX)) / det
  if u >= -0.02 and u <= 1.04 and v >= -0.03 and v <= 1.0 then
    local pu, pv = u * 13, v * 20.6
    local col
    if pv < 1.6 then col = (pv < 0.8) and WOOD[6] or WOOD[5]                       -- ridge beam
    elseif pv > 18.6 then col = (pv > 19.6) and WOOD[3] or WOOD[4]                 -- eave beam
    elseif pu > 11.6 then col = (pu > 12.4) and WOOD[3] or WOOD[4]                 -- back rafter
    elseif abs(pu - 6.2) < 0.55 then col = WOOD[5]                                 -- glazing bar
    else
      col = (pv < 7) and GL[6] or GL[5]
      if pv > 14 then col = GL[4] end
      local s = (pu * 1.3 + pv) % 9
      if s < 0.9 then col = GL[6] elseif s < 1.8 and pv >= 7 then col = GL[5] end
      if pv > 16.8 then col = GL[3] end                                           -- AO above the eave
    end
    P(x, y, col)
  end
end end
-- ridge end grain + finial
P(25, 13, WOOD[6]) P(24, 13, WOOD[5]) P(25, 12, WOOD[5]) P(24, 12, WOOD[4]) P(25, 11, BRASS[3]) P(24, 11, BRASS[2]) P(25, 10, BRASS[4])

---------------------------------------------------------------- side wall
for x = 39, 50 do
  local u = (x - 38) / 12
  local top, bot, sill = floor(30 - 5 * u + 0.5), floor(50 - 4 * u + 0.5), floor(44 - 4 * u + 0.5)
  for y = top, bot do
    local col
    local pv = y - top
    if x >= 49 then col = (x == 49) and WOOD[3] or WOOD[2]                         -- back corner post
    elseif pv < 2 then col = (pv == 0) and WOOD[4] or WOOD[3]                      -- eave beam
    elseif y == sill then col = WOOD[3]
    elseif y > sill then                                                          -- brick plinth (shade)
      local row = y - sill - 1
      if row % 3 == 2 then col = MOR[1]
      else
        local off = (floor(row / 3) % 2) * 2
        if (x + off) % 5 == 0 then col = MOR[1]
        else col = BR[(row % 3 == 0) and 3 or 2]
          if X.hash(floor((x + off) / 5), floor(row / 3), 9) > 0.7 then col = BR[3] end end
      end
    elseif x == 44 then col = WOOD[3]                                              -- mid post
    else
      col = (pv < 7) and GL[3] or GL[2]
      if (x * 1.6 + y) % 10 < 1 and pv > 3 then col = GL[4] end
      if y == sill - 1 then col = GL[1] end
      -- interior: bench + pots seen through the darker glass
      local by = sill - 4
      if y == by then col = BENCH end
      if y < by and y >= by - 2 and (x == 40 or x == 41 or x == 46 or x == 47) then col = (y == by - 1) and POT[1] or POT[2] end
      if y < by - 2 and y >= by - 4 and (x >= 39 and x <= 42 or x >= 45 and x <= 48) and X.hash(x, y, 4) > 0.3 then col = PLT[(y == by - 4) and 2 or 1] end
    end
    P(x, y, col)
  end
end
-- end grain on the side eave beam (back end)
P(50, 25, WOOD[6]) P(50, 26, WOOD[5])

---------------------------------------------------------------- front face (gable end)
local glass = HP.mask()
for y = AY, 50 do for x = 12, 38 do
  if y >= 30 or (x >= floor(gl(y) + 0.5) and x <= floor(gr(y) + 0.5)) then glass:set(x, y) end
end end
glass:each(function(x, y)
  local col = (y < 26) and GL[5] or (y < 36) and GL[4] or GL[3]
  local s = (x + y) % 13
  if y >= 32 and y < 44 and (s == 0) then col = GL[6] elseif y >= 32 and y < 44 and s == 1 then col = GL[5] end
  if y < 30 and (x - y) % 9 == 0 then col = GL[6] end
  P(x, y, col)
end)
-- interior through the front glass: bench, pots, seedlings
for x = 14, 36 do P(x, 41, BENCH) P(x, 42, GL[2]) P(x, 43, GL[2]) end
for _, px in ipairs{ 15, 18, 32, 35 } do
  P(px - 1, 39, POT[3]) P(px, 39, POT[2]) P(px + 1, 39, POT[1])
  P(px - 1, 40, POT[2]) P(px, 40, POT[2]) P(px + 1, 40, POT[1])
  P(px - 1, 38, PLT[3]) P(px, 38, PLT[2]) P(px + 1, 38, PLT[1])
  P(px - 1, 37, PLT[4]) P(px + 1, 37, PLT[2]) P(px, 36, PLT[3])
end
-- glass AO under the tie beam
for x = 14, 36 do P(x, 32, GL[2]) end

-- wood frame (front)
local function woodV(x, y0, y1, lit) for y = y0, y1 do P(x, y, lit and WOOD[5] or WOOD[4]) end end
-- rafters (2 px, follow the slopes)
for y = AY, 31 do
  local l, r = floor(gl(y) + 0.5), floor(gr(y) + 0.5)
  P(l, y, WOOD[5]) P(l + 1, y, WOOD[4]) P(r, y, WOOD[4]) P(r - 1, y, WOOD[3])
  if y > AY then P(l + 2, y, GL[3]) end                         -- AO along the inner edge of the left rafter
end
-- gable glazing bars
for y = 21, 29 do P(19, y, WOOD[4]) P(31, y, WOOD[4]) end
-- tie beam
for x = 12, 38 do P(x, 30, WOOD[5]) P(x, 31, WOOD[4]) end
for x = 15, 36, 6 do P(x, 31, WOOD[3]) P(x + 1, 31, WOOD[3]) end              -- grain dashes
P(12, 30, WOOD[6]) P(12, 31, WOOD[5])                                         -- end grain
-- posts
for y = 32, 44 do P(12, y, WOOD[5]) P(13, y, WOOD[4]) P(37, y, WOOD[4]) P(38, y, WOOD[3]) end
for y = 34, 43, 4 do P(13, y, WOOD[3]) P(37, y + 2, WOOD[3]) end                -- grain
-- glazing bars
for y = 32, 43 do P(17, y, WOOD[4]) P(33, y, WOOD[4]) end
-- sill
for x = 12, 38 do P(x, 44, WOOD[5]) end

-- brick plinth (front)
for y = 45, 50 do for x = 12, 38 do
  local row = y - 45
  local col
  if row % 3 == 2 then col = MOR[2]
  else
    local off = (floor(row / 3) % 2) * 3
    if (x + off) % 6 == 0 then col = MOR[2]
    else
      col = BR[(row % 3 == 0) and 5 or 4]
      local h = X.hash(floor((x + off) / 6), floor(row / 3), 3)
      if h > 0.75 then col = BR[(row % 3 == 0) and 4 or 3] elseif h < 0.12 and row % 3 == 0 then col = BR[6] end
    end
  end
  if y == 45 then col = (col == MOR[2]) and MOR[1] or BR[3] end                -- AO under the sill
  if x >= 37 then col = (col == MOR[2]) and MOR[1] or BR[3] end
  P(x, y, col)
end end

-- door
for y = 31, 50 do P(21, y, WOOD[5]) P(29, y, WOOD[3]) end
for x = 21, 29 do P(x, 32, WOOD[4]) end
for y = 33, 50 do for x = 22, 28 do
  local col
  if y <= 39 then                                                             -- upper glass pane
    col = (y < 35) and GL[5] or GL[4]
    if x - y == -11 or x - y == -10 then col = GL[6] end
    if x == 22 or y == 33 then col = GL[2] end                                -- AO in the frame
  elseif y == 40 then col = WOOD[4]
  else                                                                        -- raised panel
    col = WOOD[4]
    if y == 41 or x == 22 then col = WOOD[3] end
    if y == 50 or x == 28 then col = WOOD[3] end
    if y >= 42 and y <= 48 and x >= 23 and x <= 27 then
      col = WOOD[4]
      if y == 42 or x == 23 then col = WOOD[5] end
      if y == 48 or x == 27 then col = WOOD[2] end
      if x == 25 and y % 3 == 0 then col = WOOD[3] end
    end
  end
  P(x, y, col)
end end
P(25, 36, GL[4]) for x = 22, 28 do P(x, 36, WOOD[4]) end for y = 33, 39 do P(25, y, WOOD[4]) end   -- muntins
-- brass knob
P(27, 44, BRASS[3]) P(28, 44, BRASS[2]) P(27, 45, BRASS[2]) P(28, 45, BRASS[1]) P(27, 43, BRASS[4])

-- quirk: propped gable vent with a pea tendril
for x = 22, 28 do P(x, 22, WOOD[5]) P(x, 27, WOOD[4]) end
for y = 22, 27 do P(22, y, WOOD[5]) P(28, y, WOOD[3]) end
for y = 23, 26 do for x = 23, 27 do P(x, y, (y == 23) and DARK[1] or DARK[2]) end end
-- the pane, hinged at the top, tilted out (foreshortened, lighter, sticks out past the frame)
for x = 22, 28 do P(x, 21, WOOD[5]) end
for x = 22, 28 do P(x, 23, GL[6]) P(x, 24, GL[5]) end
P(22, 23, WOOD[5]) P(28, 23, WOOD[4]) P(22, 24, WOOD[4]) P(28, 24, WOOD[3])
for x = 22, 28 do P(x, 25, WOOD[4]) end
-- prop stick
P(27, 26, WOOD[6])
-- tendril: two leaves out of the gap, a curl hanging over the sill
P(24, 26, VINE[2]) P(25, 26, VINE[3]) P(23, 26, VINE[1])
P(24, 27, VINE[2]) P(24, 28, VINE[2]) P(23, 29, VINE[3]) P(22, 29, VINE[2]) P(22, 28, VINE[1])

G.save2(c, NAME)
