-- ph/feast-egg-pie (REDO): deep lattice pie in fluted tin, wedge cut out showing custard + halved egg, fork beside.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tinR   = GV.ramp("#a9aeb6")          -- stone family, lightened (pie tin)
local crustR = GV.ramp("#dc9a42")          -- gold family, baked crust
local custR  = GV.ramp("#f5d060")          -- gold family, egg custard
local forkR  = GV.ramp("#9aa0aa")          -- stone family (fork)

-- tin: top ellipse + bottom ellipse + sides, with fluted scallops round the rim
local cx = 31.5
local top = c:ellipse(cx, 26, 19, 8)
local tin = top:copy()
tin:add(c:ellipse(cx, 36, 16, 6))
tin:add(c:poly({ {12.5, 26}, {51, 26}, {48, 37}, {15.5, 37} }))
for a = 0, 359, 20 do
  local r = math.rad(a)
  tin:add(c:ellipse(cx + 19 * math.cos(r), 26 + 8 * math.sin(r), 1.5, 1.5))
end

-- crust top
local crust = c:ellipse(cx, 25.5, 16, 6)

-- wedge cut out (front-right), stops at the inner tin rim
local C = { cx, 25.5 }
local pts = { { C[1], C[2] } }
for a = -4, 84, 4 do
  local r = math.rad(a)
  pts[#pts + 1] = { cx + 18 * math.cos(r), 25.5 + 7.5 * math.sin(r) }
end
local hole = c:poly(pts):clip(c:ellipse(cx, 26, 16.5, 6.6))
crust:cut(hole)

-- cut face (custard) = upper part of the hole; floor below
local function faceTop(x) return C[2] + (x - C[1]) * (1.0 / 15.8) end
local face, floor = c:mask(), c:mask()
hole:each(function(x, y)
  if y - faceTop(x) <= 7.5 then face:set(x, y) else floor:set(x, y) end
end)

-- fork lying in front, tines toward the wedge
local fork = c:line({ { 13, 50 }, { 29, 47 } }, 3)
fork:add(c:rrect(29, 44, 38, 48, 1))

local p = c:build{
  { "tin",   tin,   tinR,  { cres = 4 } },
  { "crust", crust, crustR, { gloss = false } },
  { "face",  face,  custR, { gloss = false, rim = false } },
  { "fork",  fork,  forkR, { gloss = { 17, 48 } } },
}

-- floor of the cut: dark tin interior
c:fill(floor, tinR.deep)

-- tin side flutes (vertical grooves on the side band)
tin:each(function(x, y)
  if not top:has(x, y) and y < 43 and (x % 3 == 0) and not fork:has(x, y) then
    c:px(x, y, tinR.shade)
  end
end)

-- lattice: diamond gaps of custard inside the crust
local inner = crust:shrink(2)
inner:each(function(x, y)
  local u = (x + 2 * y) % 8
  local v = (x - 2 * y) % 8
  if u >= 3 and v >= 3 then
    c:px(x, y, custR.shade)
    if u == 3 or v == 3 then c:px(x, y, crustR.deep) end
  end
end)
c:gloss(crust, crustR, { 20, 22 })

-- cut face layers: crust band at top, crust base at bottom
face:each(function(x, y)
  local d = y - faceTop(x)
  if d < 1.5 then c:px(x, y, crustR.base)
  elseif d < 2.5 then c:px(x, y, crustR.shade)
  elseif d > 6.5 then c:px(x, y, crustR.shade) end
end)

-- halved boiled egg in the custard face
c:paint({
  ".wwww.",
  "wwyyww",
  "wwyyyw",
  ".wwww.",
}, 38, 28, { w = "#f1ece0", y = "#e8a317" })
c:px(39, 28, "#fff3c8")

-- fork tine gaps
c:paint({ "hhhh", "....", "hhhh" }, 35, 45, { h = forkR.deep })

local t = c:save("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/aseprite/ph/feast-egg-pie.aseprite",
                 "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/png/ph/feast-egg-pie.png")
print(GV.report(t))
