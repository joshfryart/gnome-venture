-- front-wboots (Flood Boots avatar layer, front view) redo. 512x80 = 8 frames of 64x80, lined up with the gnome25 body.
-- Was: squat clogs with a wide tan collar that ended the boot at row 64. Now: the waxed green shaft runs straight on
-- up under the tunic hem (no cuff), so it reads as a TALL boot; a long lit stripe, side wall, ankle creases, a toe cap
-- and a brown rubber sole. Note: this layer sits under the tunic in the stack, so only rows 64-70 are visible.
-- quirk: red rubber repair patch on the left shaft.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/_strip.lua")
local W = S.W
local G = { spec="#d4f0b0", hi="#7fc07a", lt="#58a36a", base="#3c8458", sh="#2c6550", dp="#1f4440" }
local SOLE, SOLE_T = "#6a4537", "#51342f"

local function boot(px, xl, xr, dy, patch)
  local m = {}
  for v = 0, 6 do
    local y = 64 + dy + v
    local a, b = xl, xr
    if v == 6 then a, b = xl + 1, xr - 1 end
    for x = a, b do
      local u = x - xl
      local c = G.base
      if u == 0 then c = G.lt
      elseif u == 1 then c = (v <= 4) and G.hi or G.lt
      elseif u == 2 then c = G.lt
      elseif u >= 6 and u <= 7 then c = G.sh
      elseif u == 8 then c = G.dp end
      if v == 4 and (u == 3 or u == 4 or u == 5) then c = G.sh end         -- ankle crease
      if v == 5 then                                                        -- toe cap
        if u >= 1 and u <= 6 then c = (u <= 2) and G.hi or G.lt end
        if u >= 7 then c = G.dp end
      end
      if v == 6 then c = ((u % 3) == 0) and SOLE_T or SOLE end             -- brown sole with tread ticks
      px[y * W + x] = c
      m[y * W + x] = true
    end
  end
  px[(65 + dy) * W + xl + 1] = G.spec
  px[(66 + dy) * W + xl + 1] = G.spec
  if patch then   -- red rubber repair patch with a thread dot
    local px0, py0 = xl + 4, 66 + dy
    px[py0 * W + px0] = "#e8493b"; px[py0 * W + px0 + 1] = "#e8493b"
    px[(py0 + 1) * W + px0] = "#b52e3f"; px[(py0 + 1) * W + px0 + 1] = "#b52e3f"
  end
  return m
end

local frames = {}
for f = 0, 7 do
  local p = S.FRAMES[f + 1]
  local px = {}
  local ml = boot(px, 23, 31, p.ly or 0, true)
  local mr = boot(px, 34, 42, p.ry or 0, false)
  local mine = {}
  for k in pairs(ml) do mine[k] = true end
  for k in pairs(mr) do mine[k] = true end
  local old = S.mask("front", { "boots" }, f)
  local body = S.mask("front", S.BODY, f)
  local over = {}
  for k in pairs(old) do if not mine[k] then over[k] = true end end
  frames[#frames + 1] = S.finish(px, body, over)
end
S.save("front-wboots", frames)
