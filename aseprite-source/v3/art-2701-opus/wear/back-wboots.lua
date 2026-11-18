-- back-wboots: Flood Boots avatar layer, back view (Opus pass, art-2701 / 2.7.02). 512x80 = 8 frames of 64x80, lined up with gnome25.
-- Matches front-wboots.lua: the same waxed green, the same 11-column shaft with straight walls on the hip line, a lipped rim at row 60
-- and the long lit stripe (light from the upper left, so the stripe stays on the viewer's left from behind too).
-- Back-only cues: an ink line over the rim (the mouth of the boot against the tunic), a back seam down the shaft, a heel counter (raised band
-- around the heel) and the brown heel block under it in place of the front's toe cap. The layer draws OVER the tunic
-- (GNOME25_WEAR_AFTER back wboots => tunic), so the shaft shows from the rim down. Quirk: flood-road mud kicked up the
-- heel of the right boot (the same foot that carries the mud in front view).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = O.W
local G = { "#1f4440", "#2c6550", "#3c8458", "#58a36a", "#7fc07a", "#d4f0b0" }   -- = front-wboots
local SOLE = { "#3a2629", "#51342f", "#6a4537" }
local COL = { 4, 5, 6, 5, 4, 4, 3, 3, 3, 2, 1 }

local function clamp(i) return math.max(1, math.min(6, i)) end

local function boot(px, mine, x0, dy, mud)
  local function put(u, v, c) local k = (v + dy) * W + x0 + u px[k] = c mine[k] = true end
  for v = 60, 70 do
    for u = 0, 10 do
      local t = COL[u + 1]
      local skip = (v == 70 and (u == 0 or u == 10))
      if not skip then
        if v == 60 then t = (u <= 8) and t + 1 or t end            -- lipped rim
        if v == 61 then t = t - 1 end                              -- shadow under the lip
        if u == 5 and v >= 62 and v <= 65 then t = t - 1 end       -- back seam
        if v == 66 and u >= 1 and u <= 9 then t = t - 1 end        -- top edge of the heel counter (its shadow line)
        if v == 67 and u >= 1 and u <= 4 then t = t + 1 end
        if v == 68 then t = t - 1 end                              -- heel counter rounds under
        local c = G[clamp(t)]
        if v == 69 then c = (u <= 3) and SOLE[3] or SOLE[2] end     -- heel block
        if v == 70 then c = ((u % 3) == 2) and SOLE[1] or SOLE[2] end   -- tread edge
        if v == 70 and u == 1 then c = SOLE[3] end
        put(u, v, c)
      end
    end
  end
  -- the mouth of the boot: an ink line over the rim, so its top edge reads against the tunic (the front has the beard there)
  for u = 0, 10 do put(u, 59, O.INK) end
  if mud then   -- mud kicked up the heel from the flooded road
    local M = { "#51342f", "#6a4537", "#864c33" }
    local function at(u, v, c) local k = (v + dy) * W + x0 + u if mine[k] then px[k] = c end end
    at(6, 68, M[2]) at(7, 68, M[1]) at(7, 67, M[3])
  end
end

local frames = {}
for f = 0, 7 do
  local p = O.F[f + 1]
  local px, mine = {}, {}
  boot(px, mine, 20, p.ly, false)
  boot(px, mine, 34, p.ry, true)
  local old = O.mask("back", { "boots" }, f)
  local body = O.mask("back", O.BODY, f)
  local over = {}
  for k in pairs(old) do if not mine[k] then over[k] = true end end
  frames[#frames + 1] = O.finish(px, body, over)
end
O.saveStrip("back-wboots", frames)
