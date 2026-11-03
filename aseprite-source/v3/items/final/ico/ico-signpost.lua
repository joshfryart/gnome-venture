-- ico-signpost (final, Opus). A slim square oak post with two plank fingers nailed on: the upper one points
-- right, the lower one points left; a pale end-grain cap on the post top and a tuft of grass at its foot.
-- Material: bevelled planks (6-tone wood) with wavy grain lines and a knot, paler end grain with rings on the
-- cut tips, iron nail heads with a bright glint, AO on the post under each board, contact shadow on the ground.
-- quirk: a small snail is slowly crawling along the top of the upper board, the way the sign points.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-signpost")
local OAK   = { "#4a2826", "#6e3a2a", "#955430", "#bb7640", "#d89a5a", "#f0c488" }
local BOARD = { "#51302b", "#7e4a30", "#a86a3e", "#cc8c4e", "#e6ae6a", "#f8d498" }
local END   = { "#8a5636", "#b27a4c", "#d4a06a", "#ecc68e", "#fbe2b2" }
local IRON  = { "#29283a", "#5c5e7a", "#aab0c6", "#eef0f6" }
local GRASS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(32, 55, 13, 2)

-- post: square timber, lit left face, darker right face
local ptok = { r = { name = "post" } }
local post = c:rect(29, 10, 34, 54)
local pn = {}
post:each(function(x, y)
  local nx = (x <= 30) and -0.55 or (x >= 34 and 0.6 or 0.05)
  pn[K(x, y)] = { A.norm(nx, 0, 1) }
end)
local pb = {}
local B1, B2 = { y0 = 14, y1 = 23 }, { y0 = 29, y1 = 38 }
post:each(function(x, y) local k = K(x, y)
  if y == B1.y1 + 1 or y == B2.y1 + 1 or y == B1.y1 + 2 and x >= 32 or y == B2.y1 + 2 and x >= 32 then pb[k] = -1 end
  if y >= 52 then pb[k] = -1 end
end)
local pidx = A.shade(c, post, pn, OAK, { tok = ptok, bias = pb, amb = 0.08, wrap = 0.2 })
-- vertical grain on the post
post:each(function(x, y)
  local g = (x == 31 and (y % 9 < 5)) or (x == 33 and ((y + 4) % 11 < 6)) or (x == 30 and (y % 13 == 3 or y % 13 == 4))
  if g then A.step(c, pidx, OAK, x, y, -1, ptok) end
end)
-- end-grain cap on the post top (bevelled pale, with rings)
local etok = { r = { name = "end" } }
A.map(c, {
  "abbbbc",
  "bcddcd",
}, 29, 10, { a = END[5], b = END[4], c = END[3], d = END[2] }, etok)

-- boards
local btok = { r = { name = "board" } }
local function board(y0, y1, x0, x1, dir, seed)
  local mid = (y0 + y1) / 2
  local hh = (y1 - y0) / 2
  local m = A.fn(x0 - 8, y0, x1 + 8, y1, function(x, y)
    local tip = (dir > 0) and (x1 - x) or (x - x0)  -- distance from the tip end
    if tip < 0 then return false end
    local back = (dir > 0) and (x - x0) or (x1 - x)
    if back < 0 then return false end
    if tip < 7 then return abs(y - mid) <= hh * (tip + 1.0) / 7.5 end
    if back < 1 then return abs(y - mid) <= hh - 0.6 end   -- soft cut on the square end
    return true
  end)
  local n = X.pillow(m, 2)
  local bias = {}
  m:each(function(x, y) if y == y1 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, BOARD, { tok = btok, bias = bias })
  -- wavy grain lines
  m:each(function(x, y)
    for _, gy in ipairs{ mid - 2.2, mid + 0.4, mid + 2.6 } do
      local w = gy + 0.9 * sin((x + seed) * 0.33) + 0.5 * sin((x + seed * 3) * 0.71)
      if abs(y - w) < 0.5 and X.hash(x, floor(gy), seed) > 0.18 then A.step(c, idx, BOARD, x, y, -1, btok) end
    end
  end)
  -- knot
  local kx = (dir > 0) and (x0 + 7) or (x1 - 8)
  local ky = floor(mid + 0.5)
  if m:has(kx, ky) then
    c:put(kx, ky, BOARD[1], btok) c:put(kx + 1, ky, BOARD[2], btok)
    c:put(kx - 1, ky, BOARD[3], btok) c:put(kx + 2, ky, BOARD[3], btok)
    c:put(kx, ky - 1, BOARD[5], btok)
  end
  -- top bevel lip catches the light
  m:each(function(x, y) if not m:has(x, y - 1) and abs(x - (dir > 0 and x1 or x0)) > 2 then A.step(c, idx, BOARD, x, y, 1, btok) end end)
  -- pale end grain on the square back end
  local bx = (dir > 0) and x0 or x1
  for y = y0 + 1, y1 - 1 do if m:has(bx, y) then c:put(bx, y, (y < mid) and END[4] or END[3], btok) end end
  -- nails
  local ntok = { r = { name = "nail" } }
  for _, ny in ipairs{ y0 + 2, y1 - 3 } do
    local nx = 31
    c:put(nx, ny, IRON[3], ntok) c:put(nx + 1, ny, IRON[2], ntok)
    c:put(nx, ny + 1, IRON[2], ntok) c:put(nx + 1, ny + 1, IRON[1], ntok)
    c:put(nx, ny, IRON[4], ntok)
    -- rust stain trickling below one nail
    if ny == y1 - 3 then c:put(nx + 1, ny + 2, BOARD[2], btok) end
  end
  return m
end
board(B1.y0, B1.y1, 13, 53, 1, 3)
board(B2.y0, B2.y1, 10, 50, -1, 11)

-- grass tuft at the foot
local gtok = { r = { name = "grass" } }
A.map(c, {
  ".h......h..",
  ".b..h..hb..",
  "bb.hb.bbs.h",
  "sbbbsbbss.b",
  "dssddsdsddd",
}, 26, 50, { h = GRASS[4], b = GRASS[3], s = GRASS[2], d = GRASS[1] }, gtok)

-- quirk: a snail climbing the post (shell spiral, cream body, eye stalks)
local stok = { r = { name = "snail" } }
A.map(c, {
  ".......e",
  "......e.",
  "..PPP.b.",
  ".PhpPQbb",
  ".PpdpQb.",
  ".QPpPQb.",
  "sbQQQbbb",
}, 39, 7, { e = "#2b1c26", b = "#f6e2b6", s = "#d4b484", h = "#ffc4d8", P = "#e8709a", p = "#c94f84", Q = "#9a3a6a", d = "#7d2c5e" }, stok)

A.save(c, "ico-signpost")
