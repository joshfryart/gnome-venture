-- front-wboots: Flood Boots avatar layer, front view (Opus pass, art-2701). 512x80 = 8 frames of 64x80, lined up with gnome25.
-- Design: tall waxed green wellies with STRAIGHT walls that carry the hip line of the tunic straight down to the sole,
-- so the leg reads as booted right up under the hem (the old clogs pinched in under the hem and read as short).
-- Cues for height inside the few visible rows: hem shadow on the shaft (the shaft goes on under the tunic), a long
-- waxed stripe, the outer wall showing 1 px beside the hip, a creased instep and a lit toe cap below, a brown tread sole.
-- The shaft is drawn up to a lipped rim at row 60, so the same strip also works if the layer is moved over the tunic
-- (see MANIFEST.md). quirk: flood-road mud splashed up the right boot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = O.W
-- waxed rubber: 1 deep .. 6 specular
local G = { "#1f4440", "#2c6550", "#3c8458", "#58a36a", "#7fc07a", "#d4f0b0" }
local SOLE = { "#3a2629", "#51342f", "#6a4537" }
-- column tones across the shaft, lit from the upper left (11 columns)
local COL = { 4, 5, 6, 5, 4, 4, 3, 3, 3, 2, 1 }
local OVER = { "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }   -- layers drawn after this one

local function clamp(i) return math.max(1, math.min(6, i)) end

-- one boot: x0 = outer-left column, dy = foot lift; returns nothing (writes px, mine)
local function boot(px, mine, x0, dy, after, mud)
  local top, bot = 60 + dy, 70 + dy
  for y = top, bot do
    local v = y - dy   -- row as if planted
    for u = 0, 10 do
      local x, t = x0 + u, COL[u + 1]
      local skip = (v == 70 and (u == 0 or u == 10)) or (v == 69 and false)
      if not skip then
        if v == 60 then t = (u <= 8) and t + 1 or t end                -- lipped rim
        if v == 61 then t = t - 1 end                                  -- shadow under the lip
        if v == 67 and u >= 1 and u <= 9 then t = t - 1 end            -- instep crease
        if v == 68 then t = (u <= 3) and 5 or (u <= 7 and 4 or (u <= 8 and 3 or 2)) end   -- toe cap, faces up
        if v == 69 then t = (u <= 3) and 4 or (u <= 7 and 3 or 2) end
        if v == 68 and u == 2 then t = 6 end                           -- toe specular
        if v == 68 and u == 3 then t = 5 end
        local c = G[clamp(t)]
        if v == 70 then c = ((u % 3) == 2) and SOLE[1] or SOLE[2] end   -- tread sole
        if v == 70 and u == 1 then c = SOLE[3] end
        local k = y * W + x
        -- 2.7.01: no hem shadow any more: the layer now draws OVER the tunic (GNOME25_WEAR_AFTER front wboots => tunic), so the rim at row 60 shows
        px[k] = c; mine[k] = true
      end
    end
  end
  if mud then   -- mud splashed up the boot from the flooded road: a splat on the toe, flecks on the shaft
    local M = { "#51342f", "#6a4537", "#864c33" }
    local function at(u, v, c) local k = (v + dy) * W + x0 + u if mine[k] then px[k] = c end end
    at(5, 69, M[2]) at(6, 69, M[1]) at(7, 69, M[2]) at(6, 68, M[3]) at(7, 68, M[2])
    at(4, 66, M[3]) at(8, 65, M[2]) at(8, 66, M[3])
  end
end

local frames = {}
for f = 0, 7 do
  local p = O.F[f + 1]
  local px, mine = {}, {}
  local after = O.mask("front", OVER, f)
  boot(px, mine, 20, p.ly, after, false)
  boot(px, mine, 34, p.ry, after, true)
  local old = O.mask("front", { "boots" }, f)
  local body = O.mask("front", O.BODY, f)
  local over = {}
  for k in pairs(old) do if not mine[k] then over[k] = true end end
  frames[#frames + 1] = O.finish(px, body, over)
end
O.saveStrip("front-wboots", frames)
