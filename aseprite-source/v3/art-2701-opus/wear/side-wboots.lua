-- side-wboots: Flood Boots avatar layer, side view, facing RIGHT (Opus pass, art-2701 / 2.7.02). 512x80 = 8 frames of 64x80, lined up with gnome25.
-- Matches front-wboots.lua: the same waxed green, straight shaft walls, a lipped rim at row 60, the long lit stripe (light from
-- the upper left), a lit toe cap with a specular, an instep crease and a brown tread sole. In profile each welly is a 7 px shaft
-- over the heel with the foot running forward to a rounded toe on the right. Feet follow the side rig (gnome-dir.lua SD table:
-- far clog x = 31 + fx lifted fl, near clog x = 33 + nx lifted nl); the far boot is a tone darker and the near one overlaps it
-- with a deep seam. The layer draws OVER the tunic (GNOME25_WEAR_AFTER side wboots => tunic). Quirk: flood-road mud on the near boot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = O.W
local G = { "#1f4440", "#2c6550", "#3c8458", "#58a36a", "#7fc07a", "#d4f0b0" }   -- = front-wboots
local SOLE = { "#3a2629", "#51342f", "#6a4537" }
-- side rig (gnome-dir.lua): idle frames use the defaults fx = -2, nx = 2
local SD = { {}, {}, { nx = 4, fx = -4 }, { nx = 2, fx = -3, fl = -2 }, { nx = -1, fx = 1, fl = -3 },
  { nx = -4, fx = 4 }, { nx = -3, nl = -2, fx = 2 }, { nx = 1, nl = -3, fx = -1 } }
-- shaft column tones (u = 0 heel side .. 6 shin side), lit from the upper left
local COL = { 4, 5, 6, 4, 3, 3, 2 }
-- profile: per row v (60..70) the last column of the boot (u from 0); foot runs forward to u = 9
local LAST = { [60] = 6, [61] = 6, [62] = 6, [63] = 6, [64] = 6, [65] = 6, [66] = 7, [67] = 8, [68] = 9, [69] = 9, [70] = 8 }

local function clamp(i) return math.max(1, math.min(6, i)) end

-- one boot, x = clog centre of the rig; returns the set of keys it covers
local function boot(px, x, dy, far, mud)
  local x0 = math.floor(x) - 4
  local d = far and -1 or 0
  local m = {}
  for v = 60, 70 do
    for u = 0, LAST[v] do
      local t
      if u <= 6 then t = COL[u + 1] else t = 3 end
      if v == 60 and u <= 5 then t = t + 1 end                       -- lipped rim
      if v == 61 then t = t - 1 end                                  -- shadow under the lip
      -- foot: instep slopes down to the toe, the top of the foot faces up into the light
      if v == 66 and u == 7 then t = 4 end
      if v == 67 and u >= 6 then t = (u == 8) and 4 or 3 end         -- instep crease where the shin meets the foot
      if v == 67 and u == 7 then t = 5 end
      if v == 68 and u >= 7 then t = (u == 8) and 6 or 5 end         -- toe cap, specular on top
      if v == 69 and u >= 7 then t = (u == 9) and 2 or 3 end
      if v == 69 and u <= 6 then t = t - 1 end                       -- foot side in shadow low down
      if v == 68 and u >= 3 and u <= 6 then t = t - 1 end
      local c = G[clamp(t + d)]
      if v == 70 then c = ((u % 3) == 2) and SOLE[1] or SOLE[2] end   -- tread sole
      if v == 70 and (u == 0 or u == 1) then c = SOLE[3] end         -- heel, lit back edge
      if v == 70 and u == 4 then c = SOLE[1] end                     -- waist of the sole between heel and tread
      local k = (v + dy) * W + x0 + u
      px[k] = c
      m[k] = true
    end
  end
  for u = 0, 6 do local k = (59 + dy) * W + x0 + u px[k] = O.INK m[k] = true end   -- mouth of the boot: ink over the rim, against the tunic
  if mud then
    local M = { "#51342f", "#6a4537", "#864c33" }
    local function at(u, v, c) local k = (v + dy) * W + x0 + u if m[k] then px[k] = c end end
    at(8, 69, M[2]) at(9, 69, M[1]) at(9, 68, M[3])
  end
  return m
end

local frames = {}
for f = 0, 7 do
  local p = SD[f + 1]
  local px, near = {}, {}
  local farm = boot(px, 31 + (p.fx or -2), p.fl or 0, true, false)
  local nm = boot(near, 33 + (p.nx or 2), p.nl or 0, false, true)
  -- near boot over the far boot: a deep seam on the near boot where it meets far-only pixels
  for k, c in pairs(near) do
    local x, y = k % W, k // W
    for _, dd in ipairs{ { 1, 0 }, { -1, 0 }, { 0, -1 } } do
      local nk = (y + dd[2]) * W + x + dd[1]
      if farm[nk] and not nm[nk] then
        if c ~= SOLE[1] and c ~= SOLE[2] and c ~= SOLE[3] then near[k] = G[1] end
      end
    end
  end
  for k, c in pairs(near) do px[k] = c end
  local mine = {}
  for k in pairs(px) do mine[k] = true end
  local old = O.mask("side", { "boots" }, f)
  local body = O.mask("side", O.BODY, f)
  local over = {}
  for k in pairs(old) do if not mine[k] then over[k] = true end end
  frames[#frames + 1] = O.finish(px, body, over)
end
O.saveStrip("side-wboots", frames)
