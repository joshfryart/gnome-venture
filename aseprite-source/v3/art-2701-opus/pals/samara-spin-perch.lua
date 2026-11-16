-- Samara Spin (mw-samara-spin), perch sprite 36x36. Opus pass, drawn at this size by hand:
-- round nutlet with pill eyes and a brave brow, curved red-amber wing with a dark upper vein,
-- hovering (small, detached shadow, two spin arcs, one rare glint).
-- quirk: three thorn hooks on the wing's lower edge.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("samara-spin-perch", 36)

local WING = { "#5e1e2a", "#8e2c30", "#c0443a", "#e0683e", "#f29a5a", "#fcc888" }
local NUT  = { "#4a2426", "#7a3a2e", "#a65a36", "#c97c44", "#e2a35e", "#f4ca88" }
local THORN= { "#3e1a24", "#6e2038" }

local WP = { { 14, 20 }, { 16, 12 }, { 24, 7 }, { 33, 8 } }
local wfn = function(t)
  if t > .78 then return 4.6 * math.sqrt(math.max(0, 1 - ((t - .78) / .24) ^ 2)) + .3 end
  return 1.2 + 3.4 * (t / .78) ^ .8 end
local wm, wn, wT, wS = O.tube(WP, wfn)
local wtok = { r = { name = "wing" } }
wm:each(function(x, y)
  local k = K(x, y)
  local sv, t = wS[k] or 0, wT[k] or 0
  local col
  if sv < -.6 and t < .9 then col = WING[2]
  elseif sv < -.1 then col = WING[5]
  elseif sv < .5 then col = WING[4]
  else col = WING[3] end
  c:put(x, y, col, wtok)
end)
-- two veins
O.mark(c, { {19,11},{20,12},{21,13} }, WING[3]) O.mark(c, { {24,8},{25,9},{26,10} }, WING[3])
O.mark(c, { {22,8},{23,7} }, WING[6])
-- quirk: thorn hooks on the lower edge
local teeth = HP.mask()
for _, t in ipairs({ .42, .6, .78 }) do
  local x, y = O.bez(WP, t)
  local x2, y2 = O.bez(WP, t + .01)
  local tx, ty = x2 - x, y2 - y
  local l = math.sqrt(tx * tx + ty * ty)
  local ux, uy = tx / l, ty / l
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local w = 0
  while wm:has(math.floor(x + px * (w + 1) + .5), math.floor(y + py * (w + 1) + .5)) do w = w + 1 end
  for d = 1, 2 do teeth:set(math.floor(x + px * (w + d) + ux * (d - 1) * .8 + .5), math.floor(y + py * (w + d) + uy * (d - 1) * .8 + .5)) end
end
teeth:cut(wm)
teeth:each(function(x, y) c:put(x, y, THORN[2], wtok) end)

-- nutlet
local nut = c:ellipse(12, 24, 6.5, 6)
O.shade(c, nut, NUT, { sphere = { 11, 22, 7.5 }, amb = .15, wrap = .3, sep = NUT[2] })
O.mark(c, { {14,28},{16,27},{12,29} }, NUT[2])
O.dots(c, { {6,29},{5,30} }, NUT[2])
c:eyeSmall(8, 22)
c:eyeSmall(14, 22)
O.dots(c, { {8,20},{9,20} }, NUT[1]) O.dots(c, { {15,20},{16,20} }, NUT[1])
O.dot(c, 7, 26, "#f5809f") O.dot(c, 17, 26, "#f5809f")
O.dots(c, { {11,27},{12,27},{13,26} }, NUT[1])

O.shift(c, -2, -1)
c:groundShadow(11, 33, 5, 1) -- hovering: shadow drawn apart from the body
O.done(c, "samara-spin-perch", function(c)
  for _, a in ipairs({ { 150, 210 }, { 340, 385 } }) do
    local n = 0
    for d = a[1], a[2], 3 do
      local r = math.rad(d)
      local x, y = math.floor(10 + math.cos(r) * 9.5 + .5), math.floor(22 + math.sin(r) * 8.5 + .5)
      n = n + 1
      if not c:get(x, y) and n % 5 ~= 0 then c:put(x, y, "#fff4d6") end
    end
  end
  c:put(4, 11, "#fff4d6") c:put(3, 11, "#ffe38a") c:put(5, 11, "#ffe38a") c:put(4, 10, "#ffe38a") c:put(4, 12, "#ffe38a")
end)
