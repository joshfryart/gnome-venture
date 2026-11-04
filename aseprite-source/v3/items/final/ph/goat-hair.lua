-- goat-hair (final, Opus aB35 single pass). A slim hank of long goat hair standing upright, cinched at the waist by a
-- wrapped red yarn tie: eleven separate wavy locks (cream and warm grey), each a lit tube with a twisting highlight
-- band and a dark parting line where locks overlap; tufted tapering ends top and bottom; AO under the tie.
-- quirk: a little green burr is caught in the lower locks.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_0.lua")
local HP, X, K, norm = A.HP, A.X, A.K, A.norm
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("goat-hair")
local CREAM = { "#6a5248", "#9a806c", "#c8ae8e", "#e6d4b2", "#f6ead0", "#fffaec" }
local GREY  = { "#3e3438", "#655660", "#8e7f84", "#b3a6a2", "#d2c8c0", "#ece6dc" }
local YARN  = { "#5e1830", "#952438", "#c8343c", "#e8553e", "#ff8a5c", "#ffc09a" }
local BURR  = { "#24442e", "#3f6a36", "#6a9a42", "#a8c860" }
local WX, WY = 32, 31   -- waist (tie centre)

local all = HP.mask()
local locks = {}
local N = 11
for i = 1, N do
  local o = (i - (N + 1) / 2) / ((N - 1) / 2)        -- -1 .. 1
  local w = sin(i * 2.3) * 2.6
  locks[#locks + 1] = { o = o, ramp = (i % 4 == 2) and GREY or CREAM,
    top = { { WX + o * 9 + w, 8 + abs(o) * 4 + (i % 2) * 2 }, { WX + o * 7 - w, 15 }, { WX + o * 2 + w * 0.5, 23 }, { WX + o * 2.2, WY } },
    bot = { { WX + o * 2.4, WY }, { WX + o * 3 - w * 0.6, 40 }, { WX + o * 9 + w, 47 }, { WX + o * 11 - w * 0.5, 56 - abs(o) * 4 - (i % 2) * 2 } } }
end
-- draw outer locks first, centre locks on top
table.sort(locks, function(a, b) return abs(a.o) > abs(b.o) end)
local drawn = {}
for li, L in ipairs(locks) do
  local tok = { r = { name = "lock" .. li } }
  for half = 1, 2 do
    local p = half == 1 and L.top or L.bot
    local m, n, T, S, samp = A.tube(p, function(t)
      local u = half == 1 and t or (1 - t)          -- u: 0 at tip, 1 at waist
      return 0.35 + 1.35 * u ^ 0.55
    end)
    local len = 0
    for j = 2, #samp do len = len + sqrt((samp[j].x - samp[j-1].x)^2 + (samp[j].y - samp[j-1].y)^2) end
    local bias = {}
    -- parting line: darker where this lock lies on an earlier one
    m:each(function(x, y) local k = K(x, y)
      for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
        if not m:has(x + d[1], y + d[2]) and all:has(x + d[1], y + d[2]) then bias[k] = -2 break end
      end
      -- twist: diagonal light bands along the lock
      if ((T[k] * len + S[k] * 2.2 + li) % 5) < 1 then bias[k] = (bias[k] or 0) + 1 end
    end)
    A.shade(c, m, n, L.ramp, { bias = bias, tok = tok, amb = 0.12, wrap = 0.3 })
    all:add(m)
  end
end
-- yarn tie: curved band 5 px tall wrapped round the waist
local tie = HP.mask()
for y = WY - 3, WY + 2 do for x = WX - 5, WX + 5 do
  local dx = (x - WX) / 5.5
  local yo = floor(dx * dx * -1.2 + 0.5)
  if all:has(x, y - yo) or abs(x - WX) <= 4 then tie:set(x, y - yo) end
end end
local tn = {}
tie:each(function(x, y) local dx = (x - WX) / 6 tn[K(x, y)] = { norm(dx, -0.1, sqrt(max(0.05, 1 - dx * dx))) } end)
local ttok = { r = { name = "yarn" } }
local tidx = A.shade(c, tie, tn, YARN, { tok = ttok, amb = 0.1 })
-- wraps: diagonal plied lines
tie:each(function(x, y) if (x + y * 2) % 4 == 0 then A.step(c, tidx, YARN, x, y, -2, ttok) end end)
-- AO on the hair just below and above the tie
all:each(function(x, y)
  if not tie:has(x, y) and (tie:has(x, y - 1) or tie:has(x, y + 1)) then
    local h = c:get(x, y) if h then c:put(x, y, "#4a3a3a") end
  end
end)
-- knot + two short tails, right side
local kt = HP.ellipse(WX + 6, WY, 1.5, 1.5)
A.shade(c, kt, X.sphere(WX + 6, WY, 1.5, kt), YARN, { tok = ttok, amb = 0.15 })
local t1 = HP.line({ { WX + 7, WY + 1 }, { WX + 9, WY + 4 }, { WX + 9, WY + 6 } }, 1)
local t2 = HP.line({ { WX + 8, WY }, { WX + 11, WY + 2 }, { WX + 12, WY + 4 } }, 1)
t1:each(function(x, y) c:put(x, y, (y % 2 == 0) and YARN[3] or YARN[4], ttok) end)
t2:each(function(x, y) c:put(x, y, (x % 2 == 0) and YARN[2] or YARN[3], ttok) end)
-- quirk: a green burr caught in the lower-left locks
local bx, by = 25, 45
local bm = HP.ellipse(bx, by, 2, 2)
local btok = { r = { name = "burr" } }
A.shade(c, bm, X.sphere(bx, by, 2, bm), BURR, { tok = btok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })
for _, s in ipairs{ { bx - 3, by }, { bx, by - 3 }, { bx - 2, by - 2 }, { bx + 2, by - 2 }, { bx - 2, by + 2 } } do c:put(s[1], s[2], BURR[2], btok) end
c:put(bx - 1, by - 1, BURR[4], btok)
A.save(c, "goat-hair")
