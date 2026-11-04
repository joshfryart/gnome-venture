-- ico-star-empty (Opus artist pass): the unearned star, an empty pewter star setting waiting for its gem.
-- Same tipped five-point silhouette as ico-star so the pair swaps cleanly, but built as a frame: a 4 px rounded
-- pewter rim (per-pixel tube light, 6 tones, bright bevel on the upper-left, cool reflected light lower-right)
-- around a sunken violet socket. The socket is lit as a concave dish: its upper-left walls fall into the rim's
-- shadow, its lower-right walls catch light, with a dark ambient row under the rim lip all round.
-- quirk: one tiny flake of gold is still stuck in the bottom of the socket.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, pi = math.floor, math.max, math.min, math.sqrt, math.pi
local c = D.new("ico-star-empty")
local PEW, SOCK = D.PEW, D.SOCK
local rtok, stok = { r = { name = "pewter" } }, { r = { name = "socket" } }

local CX, CY = 32, 33
local ROT = -pi / 2 + 0.07
local outer = D.star(CX, CY, 24, 12.2, ROT)
local inner = D.star(CX, CY + 0.6, 16.2, 7.6, ROT)
inner:clip(outer:shrink(3))
local rim = outer:copy():cut(inner)

-- rim: rounded tube across its width
local rn = X.pillow(rim, 2.4, 1.0)
local ridx = D.tone(c, rim, rn, PEW, { amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = rtok })
local rr = X.rim(rn)
rim:each(function(x, y) local k = K(x, y)
  if not outer:has(x + 1, y) or not outer:has(x, y + 1) then
    if rr[k] > 0.45 and ridx[k] <= 3 then c:put(x, y, "#8aa0c0", rtok) end
  end
end)

-- socket: concave dish (normals flipped), darker under the upper-left lip
local sn0, sd = X.pillow(inner, 3.2, 1.0)
local sn = {}
for k, nn in pairs(sn0) do sn[k] = { -nn[1], -nn[2], nn[3] } end
local bias = {}
inner:each(function(x, y) local k = K(x, y)
  if rim:has(x - 1, y) or rim:has(x, y - 1) or rim:has(x - 1, y - 1) then bias[k] = -2
  elseif rim:has(x - 2, y) or rim:has(x, y - 2) then bias[k] = -1 end
end)
local sv = X.light(sn, { amb = 0.1, wrap = 0.1 })
X.tone(c, inner, sv, SOCK, { cuts = { 0.25, 0.45, 0.62, 0.8 }, bias = bias, tok = stok })

-- rim specular: brightest rim pixel gets cream, a short hi streak along the upper-left arm
local sp = X.spec(rn, 24)
local best, bx, by
rim:each(function(x, y) local s = sp[K(x, y)] if s and (not best or s > best or (s == best and x + y < bx + by)) then best, bx, by = s, x, y end end)
c:put(bx, by, D.CREAM, rtok)
for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 } } do if rim:has(bx + d[1], by + d[2]) then c:put(bx + d[1], by + d[2], PEW[6], rtok) end end

-- quirk: a gold flake left in the bottom of the socket
local fx, fy = CX + 3, CY + 7
c:put(fx, fy, "#ffd44e", stok) c:put(fx + 1, fy, "#f7ae26", stok) c:put(fx + 2, fy + 1, "#e07f1c", stok)
c:put(fx + 1, fy + 1, "#f7ae26", stok) c:put(fx, fy - 1, "#fff09a", stok)
D.save(c, "ico-star-empty")
