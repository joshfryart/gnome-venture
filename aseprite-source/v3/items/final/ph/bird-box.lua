-- bird-box (final pass, Opus). A slim hanging nest box: tall front of three vertical planks (pillow bevel, seams,
-- wavy grain), a red shingled gable roof with a deep overhang (bright ridge edge, shingle courses, dark fascia,
-- ambient shadow under the eaves), a drilled entrance hole with a lit inner wall, a dowel perch with a contact
-- shadow, a wider base board, and a twisted twine loop on a metal screw-eye. quirk: a wisp of nesting straw pokes
-- out of the entrance hole.
local NAME = "bird-box"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local c = A.new(NAME)
local WOOD = { "#4a2a26", "#6e3f2e", "#94593a", "#b97a4a", "#d49a62", "#ecc189" }
local ROOF = { "#3e1f3a", "#6a2a44", "#9c3646", "#cc4a42", "#ec6e4c", "#ff9c6a" }
local TW = { "#5e4222", "#93702e", "#c89e4a", "#ecd088" }
local MET = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }

-- front face (gable reaches up under the roof)
local front = c:poly{ { 22, 26 }, { 32, 16 }, { 42, 26 }, { 42, 50 }, { 22, 50 } }
local roofL = c:poly{ { 32, 10 }, { 13, 29 }, { 13, 33 }, { 15, 33 }, { 32, 16 } }
local roofR = c:poly{ { 32, 10 }, { 51, 29 }, { 51, 33 }, { 49, 33 }, { 32, 16 } }
local roof = roofL:copy():add(roofR)
local hole = c:ellipse(32, 35, 3, 3)

local fbias = {}
X.ao(fbias, front, roof, 2, -1)
A.cast(fbias, front, roof, 1, 2, -1)
local ftok = { r = { name = "front" } }
local fidx = A.shade(c, front, X.pillow(front, 2.2, 0.7), WOOD, { tok = ftok, bias = fbias, amb = 0.15, wrap = 0.35 })
-- plank seams + grain
front:each(function(x, y) local k = K(x, y)
  if fbias[k] then return end
  if x == 28 or x == 36 then A.step(c, fidx, WOOD, x, y, -2, ftok)
  elseif x == 29 or x == 37 then A.step(c, fidx, WOOD, x, y, 1, ftok)
  else
    local pl = x < 28 and 0 or (x < 36 and 1 or 2)
    local gx = ({ 25, 32, 39 })[pl + 1] + floor(sin(y * 0.33 + pl * 2.1) * 1.4 + 0.5)
    if x == gx and (y + pl) % 5 ~= 0 then A.step(c, fidx, WOOD, x, y, -1, ftok) end
  end
end)

-- entrance hole: dark cavity, lit inner wall lower-right, shaded rim upper-left
local htok = { r = { name = "hole" } }
hole:each(function(x, y)
  local dx, dy = x - 32, y - 35
  local col = "#25161e"
  if dx + dy >= 3 and dx * dx + dy * dy >= 4 then col = WOOD[3] end
  if dx + dy >= 4 and dx * dx + dy * dy >= 7 then col = WOOD[5] end
  c:put(x, y, col, htok)
end)
hole:grow(1):cut(hole):each(function(x, y)
  local dx, dy = x - 32, y - 35
  if dx + dy < -1 then A.step(c, fidx, WOOD, x, y, -2, ftok) elseif dx + dy > 2 then A.step(c, fidx, WOOD, x, y, 1, ftok) end
end)

-- quirk: straw wisp out of the hole (pale strand + a darker one, contact shadow under)
local straw = { { 34, 36, 1 }, { 35, 36, 1 }, { 36, 35, 1 }, { 37, 35, 1 }, { 38, 34, 2 }, { 34, 37, 3 }, { 35, 38, 3 }, { 36, 38, 3 }, { 37, 39, 2 } }
for _, s in ipairs(straw) do c:put(s[1], s[2], ({ "#f6d878", "#d9aa46", "#b8862e" })[s[3]], htok) end
for _, s in ipairs{ { 36, 36 }, { 37, 36 }, { 38, 35 }, { 38, 40 } } do A.step(c, fidx, WOOD, s[1], s[2], -2, ftok) end

-- dowel perch (end-on), contact shadow down-right
c:paint({
  ".ab.",
  "abcb",
  ".bb.",
}, 30, 41, { a = WOOD[6], b = WOOD[4], c = WOOD[5] })
c:put(31, 43, WOOD[3]) c:put(32, 43, WOOD[2])
for _, s in ipairs{ { 33, 44 }, { 32, 44 }, { 34, 43 }, { 34, 44 }, { 31, 44 } } do A.step(c, fidx, WOOD, s[1], s[2], -2, ftok) end

-- base board, a little wider
local base = c:rect(20, 50, 44, 52)
local btok = { r = { name = "base" } }
base:each(function(x, y)
  local i = (y == 50) and 6 or (y == 51 and 4 or 2)
  if x >= 42 and y > 50 then i = i - 1 end
  if x == 20 and y == 51 then i = 5 end
  c:put(x, y, WOOD[i], btok)
end)
for x = 22, 42 do A.step(c, fidx, WOOD, x, 49, -1, ftok) end

-- roof: lit left slab, shaded right slab, fascia, shingle courses, bright ridge
local rtok = { r = { name = "roof" } }
local function slab(m, left)
  m:each(function(x, y)
    local d = left and (y - (42 - x)) or (y - (x - 22))   -- distance below the top edge (y = 42-x / x-22 at ridge x=32,y=10)
    local i = left and 5 or 4
    if d >= 4 then i = left and 2 or 1 end           -- fascia under-edge
    if d == 0 then i = left and 6 or 5 end           -- bright top edge
    local along = left and (32 - x) or (x - 32)
    if d >= 1 and d <= 3 and along % 4 == 3 then i = i - 1 end   -- shingle joints
    if d == 3 and along % 4 ~= 3 then i = i - 1 end              -- shingle butt line
    c:put(x, y, ROOF[max(1, min(6, i))], rtok)
  end)
end
slab(roofL, true) slab(roofR, false)
c:put(32, 10, ROOF[6], rtok) c:put(31, 11, ROOF[6], rtok)

-- twine loop on a screw-eye at the ridge (twisted: diagonal tone steps)
local lm, ln, LT, LS = A.tube({ { 30, 9 }, { 25, 0 }, { 39, 0 }, { 34, 9 } }, function() return 0.8 end)
local ttok = { r = { name = "twine" } }
lm:each(function(x, y) local k = K(x, y)
  if roof:has(x, y) then return end
  local i = ((x + y) % 3 == 0) and 4 or (((x + y) % 3 == 1) and 3 or 2)
  if LS[k] > 0.2 then i = i - 1 end
  c:put(x, y, TW[max(1, i)], ttok)
end)
c:paint({
  ".bc.",
  "bdab",
  ".bb.",
}, 30, 7, { a = MET[1], b = MET[2], c = MET[4], d = MET[3] })

A.save(c, NAME)
