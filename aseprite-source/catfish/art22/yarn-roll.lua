-- yarn-roll.lua : art22 redraw of the rolling yarn frames cf-yarn-1..4.png (16 x 16, 1x, like the cats).
-- Replaces the S4 frames from cf_room.lua (b). Same names, size and registration: draw at room-layout.json
-- yarn.sprite (58, 178) after cf-room-yarnpatch.png, the CSS rolls it 8 px right and back (frames 1 2 3 4 4 3 2 1).
-- Fixes: the base ball's trailing thread and its contact shadow were missing.
--   ball    blue wainscot felt (the room's WAIN ramp), 11 px across, centred at (8, 8) so the sprite sits on the
--           old ball; 3-tone umber outline lit per side, 1 px #000000 border round the ball only.
--   strands wound grooves (shade, deep on the dark side) with a lit ridge; they turn a quarter turn clockwise per
--           frame (exact pixel rotation about the integer centre), the light stays upper left.
--   thread  the loose end unwinds from the floor contact and trails BEHIND the roll (to the left), 2 px felt strand
--           (lit top, shade under) like the base ball's floor thread, no outline (floor bits in the room have none).
--   shadow  1 px contact shadow on the planks under the ball (offset lower right), two floor steps at the core, one floor step down (as DOWN[]).
-- Run: AppRun -b --script yarn-roll.lua      Writes art22/out/cf-yarn-1..4.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

local WAIN  = { rim = "#b9cfd9", base = "#8eaabf", shade = "#6f8aa8", deep = "#56708f" }   -- cf_room.lua WAIN + DEEPB
local FLOOR = { b = "#d9a660", m = "#c78d52", d = "#b07a45" }                               -- cf_room.lua FLOOR
local SHADOW = FLOOR.m                                                                       -- DOWN[FLOOR.b]
local BLACK = "#000000"

local CX, CY, R = 8, 8, 5.5
local function nrm(v) local l = math.sqrt(v[1] ^ 2 + v[2] ^ 2 + v[3] ^ 2) return { v[1] / l, v[2] / l, v[3] / l } end
local LIGHT = nrm({ -1, -1.1, 1.3 })

local function inBall(dx, dy) return dx * dx + dy * dy <= R * R end
-- strand pattern in frame-1 coordinates (offsets from the centre): wraps running lower left to upper right
-- (arcs about a far upper-right centre) and one crossing wrap on top (arc about a far lower-left centre).
local function strandAt(dx, dy)
  local function ring(ax, ay, r) local d = math.sqrt((dx - ax) ^ 2 + (dy - ay) ^ 2) return d >= r - 0.5 and d < r + 0.5 end
  if ring(-10, 10, 11) then return "s" end                         -- crossing wrap
  if ring(9, -9, 9.5) or ring(9, -9, 13) then return "s" end       -- two long wraps
  return nil
end
-- quarter turns clockwise on screen: (dx, dy) -> (-dy, dx); to sample frame k, turn back k times
local function back(dx, dy, k) for _ = 1, k do dx, dy = dy, -dx end return dx, dy end

local function frame(k)
  local c = GV.canvas{ w = 16, h = 16, mode = "scene" }              -- scene: no auto border, painted by hand
  local ball = {}
  for y = 0, 15 do for x = 0, 15 do
    local dx, dy = x - CX, y - CY
    if inBall(dx, dy) then
      ball[y * 16 + x] = true
      local z = math.sqrt(math.max(0, R * R - dx * dx - dy * dy))
      local lam = (dx * LIGHT[1] + dy * LIGHT[2] + z * LIGHT[3]) / R
      local t = lam > 0.8 and 1 or (lam > 0.2 and 2 or 3)
      local sx, sy = back(dx, dy, k)
      local s = strandAt(sx, sy)
      local col = ({ WAIN.rim, WAIN.base, WAIN.shade })[t]
      if s and dx * dx + dy * dy <= (R - 0.9) ^ 2 then col = t <= 2 and WAIN.shade or WAIN.deep end
      c:px(x, y, col)
    end
  end end
  -- lit ridge on the upper-left side of each groove (base pixels only)
  for y = 0, 15 do for x = 0, 15 do
    if ball[y * 16 + x] and c:get(x, y) == WAIN.base and (c:get(x + 1, y + 1) == WAIN.shade) and
       ball[(y + 1) * 16 + x + 1] and (x - CX) + (y - CY) < 0 then
      c:px(x, y, WAIN.rim)
    end
  end end
  -- gloss comma, upper left (fixed: the light does not roll)
  c:paint({ ".gg", "g.." }, CX - 3, CY - 4, { g = WAIN.rim })
  -- 3-tone umber outline, lit per side
  local ol = {}
  for y = 0, 15 do for x = 0, 15 do
    local dx, dy = x - CX, y - CY
    if not ball[y * 16 + x] and dx * dx + dy * dy <= (R + 1.2) ^ 2 then
      ol[y * 16 + x] = true
      local s = dx + dy
      c:px(x, y, s < -3 and C.ol1 or (s < 2 and C.ol2 or C.ol3))
    end
  end end
  -- contact shadow on the planks: under the ball (2 rows, offset to the lower right) and under the thread
  local shadow = {}
  local function sh(x, y) if not c:get(x, y) then c:px(x, y, SHADOW) shadow[y * 16 + x] = true end end
  -- loose thread: leaves the floor contact under the ball and trails left (behind the roll), lying on the floor:
  -- lit top row, shade under-edge, thinning to a 1 px frayed tip at the left edge
  for x = 2, 6 do c:px(x, 14, WAIN.base) end
  for x = 0, 6 do c:px(x, 15, WAIN.shade) end
  c:px(1, 14, WAIN.shade)
  for x = 7, 14 do sh(x, 15) end
  for x = 9, 11 do if shadow[15 * 16 + x] then c:px(x, 15, FLOOR.d) end end   -- darker core right under the contact
  -- 1 px #000000 border round the ball only (not over the floor shadow or the thread)
  local add = {}
  for y = 0, 15 do for x = 0, 15 do
    if not c:get(x, y) and y <= 14 then
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 0 and nx <= 15 and ny >= 0 and ny <= 15 and ol[ny * 16 + nx] then add[#add + 1] = { x, y } break end
      end
    end
  end end
  for _, p in ipairs(add) do c:px(p[1], p[2], BLACK) end
  return c
end

for k = 0, 3 do
  local c = frame(k)
  local n = "cf-yarn-" .. (k + 1)
  print(n .. ": " .. GV.report(c:save(OUT .. n .. ".aseprite", OUT .. n .. ".png")))
end
