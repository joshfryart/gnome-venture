-- ico-plus (Opus single pass, aA8_2). A plus sign built from two short planed oak boards, the horizontal one laid
-- over the vertical one, lashed at the crossing with a twisted jute cord in an X.
-- Material: each board pillow-lit with a 2 px bevel (6-tone oak, cool-violet deep), wavy grain lines and a knot,
-- paler end grain caps with growth-ring arcs at all four ends; cast shadow + AO on the back board where the front
-- board lies over it; cord in twisted 2-tone segments with a dark core, its own contact shadow on the boards.
-- quirk: a tiny red toadstool has sprouted from the top edge of the right arm.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin
local c = A.new("ico-plus")

local OAK  = { "#4a2a2e", "#74412f", "#9c5f3a", "#c08148", "#dca462", "#f0c78a" }
local END  = { "#8a5a3a", "#c89a68", "#e8c493", "#f6dcae" }
local JUTE = { "#5e3d24", "#9a6c34", "#cf9f4e", "#f2d17e" }

local function grain(m, horiz, seed, ramp, x0, y0, len)
  m:each(function(x, y)
    local u, w = horiz and x or y, horiz and (y - y0) or (x - x0)
    local g = w + 0.8 * sin(u * 0.32 + seed) + 0.4 * sin(u * 0.9 + seed * 2)
    if abs(g - 3) < 0.45 or abs(g - 6.6) < 0.45 then
      local h = A.at(x, y) for i, col in ipairs(ramp) do if col:lower() == h then A.px(x, y, ramp[max(1, i - 1)]) end end
    end
  end)
end
local function endcap(m, horiz, at, dir, lo, hi)
  -- pale end-grain face (3 px) at a board end: growth-ring arcs around an off-centre pith, deep line where it
  -- meets the planed face, lit on the upper-left half
  local mid = (lo + hi) / 2 + 1.5
  m:each(function(x, y)
    local u = horiz and x or y
    local w = horiz and y or x
    local dd = (u - at) * dir
    if dd >= 0 and dd < 3 then
      local r = sqrt((w - mid)^2 + (dd * 2.2)^2)
      local t = (w < mid - 1) and 3 or 2
      if dd == 0 then t = t + 1 end
      if floor(r) % 3 == 0 then t = t - 1 end
      if w == lo or w == hi then t = 1 end
      A.px(x, y, END[max(1, min(4, t))])
    elseif dd == 3 then
      local h = A.at(x, y) for i, col in ipairs(OAK) do if col:lower() == h then A.px(x, y, OAK[max(1, i - 2)]) end end
    end
  end)
end

-- back board (vertical)
local V = c:rrect(27, 7, 36, 56, 1)
local vb = {}
local H = c:rrect(7, 27, 56, 36, 1)
A.cast(vb, V, H, 2, 2, -2)
A.ao(vb, V, H, 1, -1)
local vtok = { r = { name = "oakV" } }
A.pil(V, 3, OAK, { amb = 0.1, wrap = 0.3, bias = vb, tok = vtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
grain(V, false, 1.3, OAK, 27, 7)
endcap(V, false, 7, 1, 27, 36) endcap(V, false, 56, -1, 27, 36)
for y = 11, 52 do if A.at(28, y) and not H:has(28, y) then A.px(28, y, OAK[6], vtok) end end
-- knot on the lower arm
A.bmp({ ".ab.", "abca", ".ab." }, 30, 45, { a = OAK[2], b = OAK[3], c = OAK[1] }, vtok)

-- front board (horizontal)
local hb = {}
local htok = { r = { name = "oakH" } }
A.pil(H, 3, OAK, { amb = 0.1, wrap = 0.3, bias = hb, tok = htok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
grain(H, true, 0.4, OAK, 7, 27)
endcap(H, true, 7, 1, 27, 36) endcap(H, true, 56, -1, 27, 36)
for x = 11, 52 do A.px(x, 28, OAK[6], htok) end
-- inner separation line where the front board's edge lies on the back board (top and bottom edges over V)
for x = 27, 36 do A.px(x, 27, OAK[2]) end

-- jute lashing: two diagonal twisted bands across the crossing
local cord = HP.mask()
local bands = {
  { { 25, 25 }, { 38, 38 } },
  { { 38, 25 }, { 25, 38 } },
}
local cm = {}
for bi, b in ipairs(bands) do
  local m = A.capsule(b[1][1], b[1][2], b[2][1], b[2][2], 1.6)
  cm[bi] = m cord:add(m)
end
-- contact shadow of the cord on the boards
cord:shift(1, 1):each(function(x, y) if not cord:has(x, y) and (H:has(x, y) or V:has(x, y)) then
  local h = A.at(x, y) for i, col in ipairs(OAK) do if col:lower() == h then A.px(x, y, OAK[max(1, i - 2)]) end end end end)
local ctok = { r = { name = "jute" } }
for bi, m in ipairs(cm) do
  local b = bands[bi]
  local vx, vy = b[2][1] - b[1][1], b[2][2] - b[1][2]
  local L = sqrt(vx*vx + vy*vy)
  m:each(function(x, y)
    local t = ((x - b[1][1]) * vx + (y - b[1][2]) * vy) / L
    local s = ((x - b[1][1]) * vy - (y - b[1][2]) * vx) / L      -- across
    local tw = (t + s * 0.8) % 2.6                                -- slanted twist stripes
    local tone = tw < 0.9 and 4 or (tw < 1.8 and 3 or 2)
    if s < -0.9 and tone < 4 then tone = tone + 0 end
    if s > 0.9 then tone = max(1, tone - 1) end
    if bi == 1 and abs(t - L / 2) < 2.2 then tone = max(1, tone - 1) end -- under-crossing: band 1 passes under band 2
    A.px(x, y, JUTE[tone], ctok)
  end)
end
-- frayed cord ends
A.pts({ { 24, 24 }, { 39, 24 } }, JUTE[3], ctok)
A.pts({ { 39, 39 } }, JUTE[2], ctok)

-- quirk: tiny toadstool on the right arm's top edge
A.bmp({
  ".hrr.",
  "hrcrr",
  "rrrrd",
  "..sk.",
  "..sk.",
}, 47, 22, { h = "#ff8a5c", r = "#e8493b", d = "#b52e3f", c = "#fff4d6", s = "#f5ecd8", k = "#c2b6bd" }, { r = { name = "shroom" } })
A.done()
