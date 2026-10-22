-- gnome-composite.lua : stacks the 7 layers (hat Moss green, beard Wheat via multiply, tier III)
-- -> gnome-parts/preview-composite.png at native 80x100.
-- Optional: --script-param hat=#rrggbb --script-param beard=#rrggbb --script-param tier=1..3 --script-param out=<png>
local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local P = app.params or {}
local function rgb(h) h = h:gsub("#", "") return tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16) end
local hat, beard = P.hat or "#2e7d4f", P.beard or "#d8c9a8"
local tier = tonumber(P.tier or "3")
local layers = { { "gnome-shadow" }, { "gnome-body" }, { "gnome-face" }, { "gnome-beard", beard }, { "gnome-hat", hat } }
if tier >= 2 then layers[#layers+1] = { "gnome-band" } end
if tier >= 3 then layers[#layers+1] = { "gnome-star" } end
local pc = app.pixelColor
local out = Image(80, 100, ColorMode.RGB)
out:clear(pc.rgba(0, 0, 0, 0))
for _, L in ipairs(layers) do
  local img = Image{ fromFile = G.OUT .. "png/" .. L[1] .. ".png" }
  assert(img.width == 80 and img.height == 100, L[1] .. " is not 80x100")
  local tr, tg, tb = 255, 255, 255
  if L[2] then tr, tg, tb = rgb(L[2]) end
  for it in img:pixels() do
    local v = it()
    if pc.rgbaA(v) == 255 then -- layers are hard-edged: opaque pixels replace what is below
      out:putPixel(it.x, it.y, pc.rgba(pc.rgbaR(v)*tr//255, pc.rgbaG(v)*tg//255, pc.rgbaB(v)*tb//255, 255))
    end
  end
end
local path = P.out or (G.OUT .. "preview-composite.png")
local spr = Sprite(80, 100, ColorMode.RGB)
spr.cels[1].image = out
spr:saveCopyAs(path)
spr:close()
print("composite -> " .. path .. "  " .. G.GV.report(G.GV.check(out)))
