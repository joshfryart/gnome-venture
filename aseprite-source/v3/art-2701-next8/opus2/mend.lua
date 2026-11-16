-- mend (Opus second pass). Tag "mend" (Mending: guard and a little health). Replaces Haiku's sticking plaster (it
-- duplicated the plaster quirk on Opus "bash" and read as a plank). A plump felt heart (health) with a jagged tear
-- across it that is being sewn shut: the open end of the tear still gapes, the closed part is pulled together with
-- cream cross-stitches, and a steel darning needle is mid-stitch, half through the felt, its thread running back to
-- the last stitch. Material: 6-tone felt with a soft fibre speckle, bevelled needle with a bright edge and an eye.
-- quirk: the spare thread trailing from the needle's eye curls into a tiny heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos
local c = O.new("mend")

local FELT = { "#5a1832", "#8a2440", "#c0344a", "#e4504e", "#ff7a66", "#ffb49a" }
local STL  = { "#2e3048", "#4a4d68", "#6e7290", "#9a9eb8", "#c8cce0", "#eef0f8" }
local THR  = { "#c9ab8c", "#f2e2c0", "#fff4d6" }
local INK  = "#2b1c26"

-- heart
local heart = O.oval(23, 26, 9.5, 9.2):add(O.oval(38, 26, 9.5, 9.2)):add(c:poly{ { 14, 29 }, { 47, 29 }, { 30.5, 51 } })
local idx
do
  local tok = O.tok("felt")
  local n = X.pillow(heart, 9)
  idx = O.shade(c, heart, n, FELT, { tok = tok, amb = 0.1, wrap = 0.3 })
  -- felt speckle
  heart:each(function(x, y) local h = O.hash(x, y, 7)
    if h > 0.95 then O.step(c, idx, FELT, x, y, 1, tok) elseif h < 0.04 then O.step(c, idx, FELT, x, y, -1, tok) end end)
  -- cleft shadow between the lobes
  for y = 18, 22 do O.step(c, idx, FELT, 30, y, -1, tok) O.step(c, idx, FELT, 31, y, -1, tok) end
  -- sheen on the upper-left lobe
  for _, p in ipairs{ { 19, 21 }, { 20, 21 }, { 19, 22 } } do O.set(c, idx, FELT, p[1], p[2], 6, tok) end
end

-- the tear: a zigzag from the lower left up toward the needle. Left part is still open (dark gap),
-- right part has been closed with cross-stitches.
local tear = { { 19, 35 }, { 21, 33 }, { 24, 37 }, { 28, 33 }, { 31, 37 }, { 35, 32 }, { 38, 34 } }
do
  local tok = O.tok("tear")
  local function seg(a, b, f)
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for i = 0, n do f(floor(a[1] + (b[1] - a[1]) * i / n + .5), floor(a[2] + (b[2] - a[2]) * i / n + .5)) end
  end
  for i = 1, #tear - 1 do
    local open = i <= 2
    seg(tear[i], tear[i + 1], function(x, y)
      if open then
        c:put(x, y, FELT[1], tok) c:put(x, y + 1, INK, tok) c:put(x + 1, y + 1, FELT[2], tok)
        -- frayed lip catches light above the gap
        if heart:has(x, y - 1) then c:put(x, y - 1, FELT[5], tok) end
      else
        c:put(x, y, FELT[2], tok)
      end
    end)
  end
  -- cross-stitches over the closed part (from x 24 on): short ticks across the seam
  for _, s in ipairs{ { 25, 35 }, { 29, 35 }, { 33, 34 }, { 37, 33 } } do
    local x, y = s[1], s[2]
    c:put(x, y - 2, THR[3], tok) c:put(x, y - 1, THR[3], tok) c:put(x, y, THR[2], tok) c:put(x, y + 1, THR[2], tok) c:put(x, y + 2, THR[1], tok)
    -- the stitch pulls the felt: tiny dimples at both ends
    c:put(x + 1, y - 2, FELT[2], tok) c:put(x + 1, y + 2, FELT[1], tok)
  end
end

-- thread from the last stitch to where the needle enters
do
  local tok = O.tok("thr")
  for _, p in ipairs{ { 38, 32 }, { 39, 31 }, { 40, 30 } } do c:put(p[1], p[2], THR[2], tok) end
end

-- needle: enters the felt at (41,29), rises to the upper right; eye at the top
do
  local tok = O.tok("needle")
  local m, n = O.tube({ { 41, 29 }, { 45, 23 }, { 49, 17 }, { 53, 11 } }, function(t) return 0.9 + t * 0.6 end)
  local nidx = O.shade(c, m, n, STL, { tok = tok, amb = 0.15 })
  -- bright edge on the lit side
  m:each(function(x, y) if not m:has(x - 1, y) and nidx[K(x, y)] then O.set(c, nidx, STL, x, y, 5, tok) end end)
  O.set(c, nidx, STL, 46, 21, 6, tok) O.set(c, nidx, STL, 47, 20, 6, tok)
  -- eye slot
  c:put(52, 12, INK, tok) c:put(51, 13, INK, tok)
  -- dimple in the felt where it goes in
  c:put(40, 30, FELT[1], tok) c:put(41, 30, FELT[2], tok)
end

-- quirk: the tail of thread from the eye loops round into a tiny heart, then trails off
do
  local tok = O.tok("tail")
  local pts = { { 53, 13 }, { 54, 14 }, { 55, 15 }, { 55, 16 }, { 56, 17 },
                -- tiny heart: two bumps then a point
                { 55, 18 }, { 54, 19 }, { 54, 20 }, { 55, 21 }, { 56, 21 }, { 57, 20 }, { 58, 21 }, { 59, 21 }, { 60, 20 },
                { 60, 19 }, { 59, 18 }, { 58, 17 }, { 57, 16 },
                -- trailing end
              }
  for i, p in ipairs(pts) do c:put(p[1], p[2], (i % 4 == 0) and THR[2] or THR[3], tok) end
end

O.save(c, "mend")
