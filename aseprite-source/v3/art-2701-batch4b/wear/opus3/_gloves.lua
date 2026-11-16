-- shared richness for both work-gloves-b ranks
local O = ...
return function(img)
  local L = O.ramp({ "#f0c98a", "#dca566", "#cf9858", "#c4864c", "#b87a44", "#a5673a", "#9a5e36", "#80492c" })
  local function safe(x, y) return not (x >= 16 and x <= 32 and y >= 31 and y <= 44) end   -- ticking patch + thread
  -- leather grain: short diagonal creases (one tone darker) and pale pore flecks, repeatable hash
  O.texture(img, L, 4, 6, 56, 54, function(x, y, i)
    local h = (x * 31 + y * 17) % 23
    if h == 0 and i < #L.list then return 1 elseif h == 11 and i > 2 and i < 7 then return -1 end
  end, safe)
end
