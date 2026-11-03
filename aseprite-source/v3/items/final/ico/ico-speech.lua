-- ico-speech (final, Opus). Glossy enamel speech bubble: a fat rounded slab with a 6-tone bevel lit from the upper
-- left, a curved window gloss and a specular glint on the top-left shoulder, a cool reflected light along the lower
-- rim, and a hooked tail lower-left with a crease (AO) where it leaves the bubble. Three raised cream dots, each
-- with a lit cap and a contact shadow on the enamel.
-- quirk: the last dot has turned into a little heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-speech")
local SE = { "#1f2f66", "#28509a", "#3478c4", "#4c9ee0", "#78c4f0", "#b8e8ff" }
local CR = { "#b89a7e", "#e2cba6", "#fff4d6", "#fffbee" }
local PK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local BOUNCE = "#5fc4d8"
local btok, dtok = { r = { name = "bubble" } }, { r = { name = "dot" } }

local body = c:rrect(8, 10, 55, 43, 11)
local tail = c:poly{ { 15, 38 }, { 28, 38 }, { 25, 45 }, { 20, 50.5 }, { 13, 55.5 }, { 10.5, 55.5 }, { 13, 50 }, { 15, 45 } }
local m = body:copy():add(tail)
local n = X.pillow(m, 4.5)
local bias = {}
-- crease where the tail leaves the body (just below the body's lower edge)
m:each(function(x, y) if not body:has(x, y) and y <= 46 and (body:has(x, y - 1) or body:has(x, y - 2)) then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, m, n, SE, { amb = 0.08, wrap = 0.25, bias = bias, tok = btok })
-- cool bounce along the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > 30 and x > 20 then c:put(x, y, BOUNCE, btok) end end)
-- window gloss: a curved streak inside the top-left shoulder + glint
A.pline(c, { { 14, 15 }, { 16, 14 } }, SE[6], btok)
A.pline(c, { { 18, 13 }, { 30, 13 } }, SE[6], btok)
A.pline(c, { { 12, 18 }, { 12, 24 } }, SE[6], btok)
c:put(13, 16, A.CREAM, btok) c:put(14, 16, SE[6], btok) c:put(13, 17, SE[6], btok)

-- dots
local function dot(cx, cy, heart)
  local dm
  if heart then
    dm = HP.mask()
    local rows = { ".##.##.", "#######", "#######", ".#####.", "..###..", "...#..." }
    for j, r in ipairs(rows) do for i = 1, #r do if r:sub(i, i) == "#" then dm:set(cx - 4 + i, cy - 3 + j) end end end
  else
    dm = c:ellipse(cx, cy, 3, 3)
  end
  -- contact shadow on the enamel, down-right
  dm:each(function(x, y) for _, d in ipairs{ { 1, 1 }, { 0, 1 }, { 1, 0 } } do
    local qx, qy = x + d[1], y + d[2]
    if not dm:has(qx, qy) and m:has(qx, qy) then c:put(qx, qy, SE[2], btok) end end end)
  -- 1px deep line on the enamel where it meets the dot (up-left), so the cap reads raised
  local ramp = heart and PK or CR
  local dn = X.pillow(dm, 2.2)
  A.shade(c, dm, dn, ramp, { amb = 0.15, wrap = 0.3, tok = dtok, cuts = { 0.3, 0.55, 0.8 } })
  local gx, gy = dm:bbox()
  if heart then c:put(cx - 2, cy - 1, PK[4], dtok) c:put(cx - 1, cy - 1, "#fff0f4", dtok)
  else c:put(cx - 1, cy - 2, CR[4], dtok) c:put(cx - 2, cy - 1, CR[4], dtok) end
end
dot(20, 27) dot(31, 27) dot(42, 27, true)
A.save(c, "ico-speech")
