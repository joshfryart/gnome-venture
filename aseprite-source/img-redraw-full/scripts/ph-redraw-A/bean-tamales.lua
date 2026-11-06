-- ph/bean-tamales, redraw A (2.2.1 leftovers, Opus medium): two fat husk parcels lying side by side on a
-- diagonal, pinched at string ties with fanned husk tips; the front one is cut open at the left: yellow masa ring,
-- dark bean core.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "bean-tamales", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local husk = GV.ramp("#ead489", { gloss = "#fff3c8", dot = "#fbf6e8", rim = "#f6e6a8", pale = false })
local masa = GV.ramp("#f2c23a", { rim = "#ffe07a" })
-- mask of points whose distance to segment (ax,ay)-(bx,by) along t in [t0,t1] has |s| <= w(t)
local function band(ax, ay, bx, by, wf)
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x - ax, y - ay
    local t = (px * dx + py * dy) / L
    local s = (px * -dy + py * dx) / L
    if t >= 0 and t <= L then local w = wf(t, L) if w and math.abs(s) <= w then m:set(x, y) end end
  end end
  return m, L
end
local function parcel(ax, ay, bx, by, open)
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy, nx, ny = dx / L, dy / L, -dy / L, dx / L
  local function at(t, s) return { math.floor(ax + ux * t + nx * s + 0.5), math.floor(ay + uy * t + ny * s + 0.5) } end
  -- fanned tips past the ties (frayed: width steps)
  local tips = band(ax, ay, bx, by, function(t, L)
    if t > L - 7 then return 2 + (t - (L - 7)) * 0.6 end
    if not open and t < 7 then return 2 + (7 - t) * 0.6 end
  end)
  c:part(tips, husk, { flat = true, contact = false })
  local body = band(ax, ay, bx, by, function(t, L)
    local a, b = open and 3 or 7, L - 7
    if t < a or t > b then return nil end
    local e = math.min(t - a, b - t)
    return math.min(7, 4 + e * 0.6)
  end)
  c:part(body, husk, { gloss = false, cres = 3 })
  for _, s in ipairs({ -3, 0, 3 }) do c:fill(c:line({ at(open and 7 or 11, s), at(L - 11, s) }, 1):clip(body:shrink(1)), "#c9b060") end
  for _, t in ipairs(open and { L - 7 } or { 7, L - 7 }) do c:fill(c:line({ at(t, -4), at(t, 4) }, 2), "#7a4a1f") end
  if open then
    local e = at(5, 0)
    c:part(c:ellipse(e[1], e[2], 6, 6), masa, { flat = true, contact = false, contour = "#b8661a" })
    c:part(c:ellipse(e[1], e[2], 2.5, 2.5), GV.ramp("#4a2030", { rim = "#6a3a4a" }), { flat = true, contact = false, contour = false })
  end
end
parcel(25, 13, 51, 36, false)
parcel(12, 25, 43, 51, true)
c:ground(32, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
