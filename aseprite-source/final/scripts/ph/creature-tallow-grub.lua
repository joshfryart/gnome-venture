-- ph/creature-tallow-grub : fat waxy cream grub, head on the right
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bodyR = GV.ramp("#efe3b8", { shade = "#d8bd84", deep = "#b98b55", bounce = "#e3c79a" }) -- pale tallow (soil cream family)
local headR = GV.ramp("#fff7da", { shade = "#efdcaa", deep = "#d8bd84", bounce = "#f2e2b4" }) -- lighter pale head
local feel  = GV.ramp("#6e7685")   -- stone-grey feelers

-- body: long sausage with round tail at left, hump in the middle
local body = c:ellipse(27, 43, 17, 8.5)
body:add(c:ellipse(26, 40, 10, 7))
body:add(c:ellipse(15, 45, 5, 6.5))
local head = c:ellipse(46.5, 38, 7, 7)
local bump = c:ellipse(24.5, 29.5, 2.5, 4)

local p = c:build{
  { "feelL", c:line({ {44, 33}, {43, 28}, {44, 25} }, 2), feel, { flat = true } },
  { "feelR", c:line({ {50, 33}, {53, 28}, {56, 26} }, 2), feel, { flat = true } },
  { "body",  body, bodyR, { stitch = false } },
  { "bump",  bump, "gold", { gloss = false, cres = 1, deep = 1 } },
  { "head",  head, headR },
}
-- feeler clubs
c:fill(c:rect(42, 23, 45, 25), feel.base); c:px(42, 23, feel.rim); c:px(43, 23, feel.rim)
c:fill(c:rect(55, 24, 58, 26), feel.base); c:px(55, 24, feel.rim); c:px(56, 24, feel.rim)

-- segment grooves (curved, 1 px), clipped to body and kept off the head
for _, x in ipairs({ 16, 23, 30, 37 }) do
  local g = c:line({ {x, 33}, {x - 1, 40}, {x - 1, 47}, {x, 53} }, 1)
  g:clip(p.body.m:shrink(1)); g:cut(head:grow(1))
  c:fill(g, bodyR.shade)
end
-- belly line
local bl = c:line({ {14, 49}, {24, 50}, {38, 49} }, 1); bl:clip(p.body.m:shrink(1))
c:fill(bl, "#8f7fc9")

-- gold bump gloss dot
c:px(23, 27, GV.R.gold.gloss); c:px(23, 28, GV.R.gold.gloss)

-- face: locked eye, sleepy little smile
c:eye(47, 35)
c:paint({ "u..u", ".uu." }, 47, 42, { u = "umber" })

c:ground(29, 52.5, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-tallow-grub.aseprite", O .. "png/ph/creature-tallow-grub.png")
print(GV.report(t))
if os.getenv("GVDUMP") then
  local im = Image{ fromFile = O .. "png/ph/creature-tallow-grub.png" }
  local map, n, keys = {}, 0, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN"
  for y = 16, 61 do
    local row = string.format("%2d ", y)
    for x = 0, 63 do
      local v = im:getPixel(x, y)
      if app.pixelColor.rgbaA(v) == 0 then row = row .. " " else
        local h = string.format("%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v))
        if not map[h] then n = n + 1; map[h] = keys:sub(n, n) end
        row = row .. map[h]
      end
    end
    print(row)
  end
  for h, k in pairs(map) do io.write(k, "=", h, " ") end print()
end
