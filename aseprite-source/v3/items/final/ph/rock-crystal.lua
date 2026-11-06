-- rock-crystal (final, Sonnet high). Slim cluster of five hexagonal quartz prisms fanning from a lumpy dusky-violet
-- matrix rock: each prism has three facets (bright left, pale ice centre, deep cool-blue right), a bright rim and
-- facet edges, faint growth striations, a pointed termination with its own bevel line, and a lilac bounce from the
-- rock on the shaded side. Two tiny druzy crystals sit on the rock, front lumps cover the prism bases.
-- quirk: a tiny rainbow flare is trapped inside the tallest crystal.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_5.lua")
local HP, X, K, B = D.HP, D.X, D.K, D.B
local floor, ceil, abs, sin, cos, pi, max, min, sqrt = math.floor, math.ceil, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-crystal")
local QZ = { "#2f3f78", "#4a68b0", "#6fa0d8", "#9ccaee", "#cde8fa", "#f4fbff" }
local DUSK = { "#231a45", "#35295f", "#5a459e", "#7a62bc", "#a88ae0", "#d2bff4" }
D.shadow(c, 32, 56, 24, 1.6)

-- matrix rock (back part)
local rock = c:poly{ {7,56},{8,51},{12,47},{17,49},{22,46},{28,48},{34,46},{40,48},{46,45},{52,48},{56,52},{57,56} }
rock:add(c:rect(8, 53, 56, 56))
local function rockTone(m, R)
  D.litB(c, m, DUSK, R, { wrap = 0.3 }, function(x, y)
    local h = D.hash(x, y, 5)
    if h > 0.9 then return 1 elseif h < 0.08 then return -1 end
    return 0
  end)
end
rockTone(rock, 4)

local drawn = HP.mask()
local function crystal(bx, by, tx, ty, w, capL, o)
  o = o or {}
  local dx, dy = tx - bx, ty - by
  local L = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local px, py = -uy, ux
  if px < 0 or (px == 0 and py < 0) then px, py = -px, -py end
  local m, info = HP.mask(), {}
  for y = floor(min(by, ty)) - ceil(w) - 2, ceil(max(by, ty)) + ceil(w) + 2 do
    for x = floor(min(bx, tx)) - ceil(w) - 2, ceil(max(bx, tx)) + ceil(w) + 2 do
      local rx, ry = x - bx, y - by
      local a, v = rx * ux + ry * uy, rx * px + ry * py
      if a >= -0.5 and a <= L + 0.4 then
        local hw = (a > L - capL) and w * (L - a) / capL or w
        if abs(v) <= hw + 0.4 then m:set(x, y) info[K(x, y)] = { a, v, hw } end
      end
    end
  end
  m:each(function(x, y)
    local a, v, hw = table.unpack(info[K(x, y)])
    local r = v / max(hw, 0.6)
    local cap = a > L - capL
    local f = (r < -0.34) and 1 or ((r < 0.42) and 2 or 3)
    local i
    if cap then i = ({ 6, 5, 3 })[f] else i = ({ 5, 4, 2 })[f] end
    -- facet edges
    local eL, eR = abs(v + 0.34 * hw), abs(v - 0.42 * hw)
    if eL < 0.55 and hw > 2 then i = cap and 3 or 6 end
    if eR < 0.5 and hw > 2.2 then i = cap and 2 or 3 end
    if r < -0.8 and not cap then i = 6 end             -- bright left rim
    if r > 0.78 and f == 3 then i = cap and 2 or 2 end
    if abs(a - (L - capL)) < 0.55 and hw > 1 then i = (f == 3) and 3 or 6 end -- termination bevel
    -- base ambient occlusion
    if a < 3 then i = i - 1 end
    if a < 1.2 then i = i - 1 end
    -- striations on the prism faces
    if not cap and f ~= 1 and a > 5 and floor(a + 0.5) % 6 == 2 and D.hash(x, y, 3) > 0.3 then i = i - 1 end
    -- soft vertical gradient: a little darker low on the lit face
    if not cap and f == 1 and a < L * 0.3 and D.hash(x, y, 8) > 0.5 then i = i - 1 end
    -- lilac bounce from the rock on the shaded edge
    if r > 0.62 and f == 3 and a < L * 0.42 and a > 2 and D.hash(x, y, 2) > 0.3 then c:px(x, y, "#8e78cc") return end
    c:px(x, y, QZ[max(1, min(6, i))])
  end)
  -- dark seam where this prism passes in front of earlier ones
  D.touching(m, drawn):each(function(x, y) c:px(x, y, QZ[1]) end)
  drawn:add(m)
  return m, info, { L = L, ux = ux, uy = uy, px = px, py = py }
end
-- back to front
crystal(23, 51, 10, 23, 4.6, 7)
crystal(40, 51, 54, 26, 4.6, 7)
local mC = crystal(31, 52, 33, 8, 5.6, 10)
crystal(27, 55, 19, 36, 3.3, 5)
crystal(37, 55, 45, 38, 3.4, 5)

-- front rock lumps cover the prism bases
local f1 = c:ellipse(17, 53, 7, 3.6)
local f2 = c:ellipse(46, 53, 8, 3.6)
local f3 = c:ellipse(32, 55, 10, 2.6)
for _, fm in ipairs{ f1, f2, f3 } do
  fm:clip(c:rect(5, 47, 58, 56))
  rockTone(fm, 3)
  D.touching(fm, drawn):each(function(x, y) c:px(x, y, DUSK[1]) end)
end
-- rock bottom row deep
for x = 8, 56 do if rock:has(x, 56) then c:px(x, 56, DUSK[1]) end end
-- tiny druzy crystals on the rock
crystal(12, 52, 10, 46, 1.9, 3)
crystal(52, 52, 55, 45, 1.9, 3)
-- mica flecks
for _, q in ipairs{ {24,54},{40,55},{9,55} } do c:px(q[1], q[2], DUSK[6]) end

-- quirk: rainbow flare trapped in the tall crystal (left face), plus glints
local RB = { "#ff8aa8", "#ffd060", "#a8f0b0", "#7ad8ff" }
for i, col in ipairs(RB) do c:px(26 + i - 1, 34 - (i - 1), col) end
c:px(30, 28, "#fff4d6") c:px(30, 29, "#fff4d6")
c:px(31, 17, "#fff4d6") c:px(31, 16, "#fff4d6")
c:px(16, 29, "#fff4d6") c:px(15, 30, "#fff4d6")
c:px(49, 33, "#fff4d6")
D.fin()
