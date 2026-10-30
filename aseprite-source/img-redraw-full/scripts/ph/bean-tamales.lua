-- ph/bean-tamales (Gourmand P2 dish): three twine-tied corn-husk tamales in a fan, the front one open on yellow masa with dark beans
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "bean-tamales"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rad = math.rad
-- rotated capsule; f(u, v) filter in local coords (u across, v along, v<0 is the top end)
local function pill(cx, cy, w, h, deg, f)
  local m, a = c:mask(), rad(deg)
  local ca, sa, r, hl = math.cos(a), math.sin(a), w / 2, h / 2 - w / 2
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local vv = math.max(math.abs(v) - hl, 0)
    if u * u + vv * vv <= r * r and (not f or f(u, v)) then m:set(x, y) end
  end end
  return m
end
local function husk(cx, cy, w, deg, hex, open)
  local h = 34
  c:part(pill(cx, cy, w, h, deg), hex, { cres = 3 })
  -- lengthwise husk ridges
  c:fill(pill(cx, cy, w, h - 4, deg, function(u) return math.abs(math.abs(u) - w * 0.28) < 0.5 end), "#bfa468")
  -- twine bands
  for _, vt in ipairs(open and { 7 } or { -6, 7 }) do
    c:fill(pill(cx, cy, w + 1, h, deg, function(_, v) return math.abs(v - vt) < 1 end), "#8a5a2f")
    c:fill(pill(cx, cy, w + 1, h, deg, function(u, v) return math.abs(v - vt + 0.5) < 0.5 and u < 0 end), "#b07a45")
  end
  if open then -- top end folded open on yellow masa
    -- husk peeled back: flaps flare out at the top, masa fills the opening
    local a = rad(deg)
    local function at(u, v) return cx + u * math.cos(a) - v * math.sin(a), cy + u * math.sin(a) + v * math.cos(a) end
    for _, sgn in ipairs({ -1, 1 }) do
      local x1, y1 = at(sgn * 5, -9); local x2, y2 = at(sgn * 8, -16); local x3, y3 = at(sgn * 3, -14)
      c:part(c:poly({ { x1, y1 }, { x2, y2 }, { x3, y3 } }):grow(1), "#e6d6a0", { cres = 2, gloss = false, contact = false })
    end
    local masa = pill(cx, cy, w - 2, h - 2, deg, function(_, v) return v < -4 end)
    c:part(masa, "#e8b83a", { contour = "#8a5a2f", cres = 3, gloss = false, contact = false })
    c:fill(pill(cx, cy, w - 2, h - 2, deg, function(_, v) return v >= -5 and v < -3 end), "#a8742f")
    for _, d in ipairs({ { -2, -14 }, { 2, -12 }, { 1, -9 }, { -2, -8 }, { 0, -11 } }) do
      local a = rad(deg)
      local x = cx + d[1] * math.cos(a) - d[2] * math.sin(a)
      local y = cy + d[1] * math.sin(a) + d[2] * math.cos(a)
      c:px(math.floor(x + 0.5), math.floor(y + 0.5), "#3b2f2a")
    end
  end
end
husk(20, 31, 11, -22, "#d8c48a")    -- back, leaning left
husk(31, 28, 11, 0, "#e0cd94")      -- middle, upright
husk(41, 32, 12, 22, "#d8c48a", true) -- front, leaning right, open
c:ground(30.5, 54, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
