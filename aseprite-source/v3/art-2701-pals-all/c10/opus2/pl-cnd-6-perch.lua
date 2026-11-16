-- Grand Condor Plume (pl-cnd-6), perch sprite 36x36. Opus second pass (c10/opus2), hand-built at this size.
-- Slate-black condor flight feather lying diagonally on the air, white patch on its lower third, ivory shaft,
-- gold band on the quill, one notch in the trailing edge. Pill eyes on the broad dark vane, all inside the canvas.
-- quirk: it still floats, on a pale updraft swirl underneath.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-6-perch", 36)

local CND  = { "#1a1622", "#29243a", "#3a344e", "#524a68", "#71688c", "#9a92b4" }
local WHT  = { "#5a5874", "#8a88a4", "#bab9cc", "#dddde6", "#f2f0ee" }
local QUIL = { "#7a6e60", "#b0a48c", "#d8ceb2", "#f2ead0" }
local GOLD = { "#d98322", "#f5b82e" }
local WIND = { "#8bc4ea", "#b9e2f5" }

local SH = { { 6, 29 }, { 12, 21 }, { 21, 12 }, { 31, 3 } }
local vane, vn, VT, VS = O.tube(SH, function(t)
  if t < .07 then return 0 end
  return 7 * math.sin(math.pi * math.min(1, (t - .05) * 1.05)) ^ .5
end)
local lead = HP.mask()
vane:each(function(x, y) if (VS[K(x, y)] or 0) < -.38 then lead:set(x, y) end end)
vane:cut(lead)
vane:cut(c:poly{ { 30, 13 }, { 26, 14 }, { 30, 15 } })
local fI, fT = O.shade(c, vane, CND, { R = 3, amb = .25, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 3 })
for k, i in pairs(fI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == fT then
    local t = VT[K(x, y)] or 0
    if t < .36 then c.pix[p] = WHT[math.max(1, math.min(5, i))]:lower() else c.pix[p] = CND[i]:lower() end
  end
end
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 1)
  if s < .14 and not (t > .42 and t < .7) then O.mark(c, { { x, y } }, t < .36 and QUIL[2] or QUIL[3]) end
end)
local quill = O.tube({ { 3, 33 }, { 4, 31 }, { 6, 30 }, { 8, 27 } }, function(t) return .6 end)
quill:cut(vane)
O.shade(c, quill, QUIL, { R = 1, amb = .35, wrap = .5, cuts = { .3, .55, .8 } })
O.dots(c, { { 6, 29 }, { 7, 28 } }, GOLD[2])

c:eyeSmall(16, 14)
c:eyeSmall(21, 12)
O.dot(c, 15, 18, "#f5809f") O.dot(c, 25, 15, "#f5809f")
O.dots(c, { { 19, 18 }, { 20, 18 }, { 21, 17 } }, P.cream)

O.done(c, "pl-cnd-6-perch", function(c)
  for _, p in ipairs({ { 16, 31 }, { 17, 31 }, { 18, 31 }, { 19, 31 }, { 20, 30 }, { 21, 29 }, { 21, 28 }, { 20, 27 }, { 19, 28 } }) do c:put(p[1], p[2], WIND[2]) end
  for _, p in ipairs({ { 10, 33 }, { 11, 33 }, { 12, 33 }, { 13, 33 }, { 14, 32 }, { 24, 28 }, { 25, 28 }, { 26, 28 }, { 27, 27 } }) do c:put(p[1], p[2], WIND[1]) end
end)
