-- ph/bean-tamales (Gourmand P2 dish): two corn-husk tamale parcels, husk ends gathered and tied with string;
-- the front one is open-ended, showing a round yellow masa end with dark beans
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "bean-tamales"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local floor, abs, rad = math.floor, math.abs, math.rad
-- mask from a predicate in local coords: u along the parcel (right end +), v across (down +)
local function lmask(cx, cy, deg, f)
  local m, a = c:mask(), rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if f(u, v) then m:set(x, y) end
  end end
  return m
end
-- one tamale. hl = half length of the filled log, hw = half width. ends: "tie" (gathered husk tail) or "open"
local function tamale(cx, cy, deg, hl, hw, hex, left, right)
  local function tail(t) -- t = distance beyond the log end (>0); husk pinched at the string then fans out
    if t <= 2 then return hw - t * 1.6 end                  -- shoulder rounding into the neck
    if t <= 4 then return hw * 0.38 end                      -- neck under the string
    return hw * 0.38 + (t - 4) * 0.75                        -- fan
  end
  local function inside(u, v, cut)
    local au, av = abs(u), abs(v)
    local endk = u < 0 and left or right
    if au <= hl - 2 then return av <= hw end
    if au <= hl then return av <= hw - (au - hl + 2) * 0.5 end
    local t = au - hl
    if endk == "open" then return t <= 2 and av <= hw end   -- collar of husk round the masa end
    local tipu = 10 - ((floor(v + 0.5) % 3 == 0) and 0 or 2)  -- frayed husk tips
    return t <= tipu and av <= tail(t)
  end
  -- gathered husk tails first (thin, so a shallow crescent), then the filled log over them
  c:part(lmask(cx, cy, deg, function(u, v) return abs(u) > hl - 1 and inside(u, v) end), hex, { cres = 1, deep = 0, gloss = false, contact = false })
  local body = lmask(cx, cy, deg, function(u, v) return abs(u) <= hl + 2.2 and inside(u, v) end)
  c:part(body, hex, { cres = 3, gloss = { cx - 6, cy - 5 } })
  -- husk grain: long ridges along the parcel, and the overlap edge of the outer leaf
  c:fill(lmask(cx, cy, deg, function(u, v) return abs(u) < hl - 1 and abs(v - hw * 0.5) < 0.5 end), "#b89a58")
  c:fill(lmask(cx, cy, deg, function(u, v) return abs(u) < hl - 3 and abs(v + hw * 0.55) < 0.5 end), "#c4a462")
  c:fill(lmask(cx, cy, deg, function(u, v) return abs(u) < hl - 1 and abs(v + hw * 0.1) < 0.5 end), "#fff0b8")
  c:fill(lmask(cx, cy, deg, function(u, v) return abs(u) < hl - 1 and abs(v + hw * 0.1 - 1) < 0.5 end), "#a8884a")
  -- tail grain: the gathered husk fans into ribs
  c:fill(lmask(cx, cy, deg, function(u, v)
    local t = abs(u) - hl
    return t > 5 and t < 9 and (abs(v) < 0.5 or abs(abs(v) - (t - 3) * 0.6) < 0.5) and inside(u, v)
  end), "#a8884a")
  -- string ties round each gathered neck
  for _, s in ipairs({ { left, -1 }, { right, 1 } }) do
    if s[1] == "tie" then
      c:fill(lmask(cx, cy, deg, function(u, v) local t = u * s[2] - hl return t > 2.2 and t <= 4.2 and abs(v) <= hw * 0.38 + 1.2 end), "#7a4a1f")
      c:fill(lmask(cx, cy, deg, function(u, v) local t = u * s[2] - hl return t > 2.2 and t <= 3.2 and abs(v) <= hw * 0.38 + 1.2 and v < 0 end), "#c98a4a")
    end
  end
  if left == "open" then -- husk peeled back: a band of yellow masa, then the round cut end with the bean filling
    local band = lmask(cx, cy, deg, function(u, v) return u < -hl + 5 + ((floor(v + 0.5) % 2 == 0) and 1 or 0) and abs(v) <= hw - 1 and u > -hl - 1 end)
    c:part(band, "#f0c040", { contour = "#8a5a2f", cres = 1, deep = 0, gloss = false, contact = false })
    local cap = lmask(cx, cy, deg, function(u, v) local du = u + hl + 0.5 return (du * du) / 10 + (v * v) / ((hw - 0.6) ^ 2) <= 1 end)
    c:part(cap, "#fadc6a", { contour = "#8a5a2f", cres = 1, deep = 0, rim = false, gloss = false, contact = false })
    local core = lmask(cx, cy, deg, function(u, v) local du = u + hl + 0.5 return (du * du) / 2.5 + (v * v) / ((hw - 3.6) ^ 2) <= 1 end)
    c:fill(core, "#4a2420")
    local a = rad(deg)
    for _, d in ipairs({ { -1, -2 }, { 0, 1 } }) do
      local u, v = -hl + d[1], d[2]
      c:px(floor(cx + u * math.cos(a) - v * math.sin(a) + 0.5), floor(cy + u * math.sin(a) + v * math.cos(a) + 0.5), "#8a3a30")
    end
  end
end
tamale(31, 25, -12, 11, 6, "#cdb478", "tie", "tie")      -- back parcel, tied both ends
tamale(33, 39, 16, 12, 7, "#e2cc8e", "open", "tie")     -- front parcel, open upper-left end
c:ground(31.5, 54, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
