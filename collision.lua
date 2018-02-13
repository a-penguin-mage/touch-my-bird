local collision = {}

function collision:inCircle(cx, cy, radius, x, y) --borrowed
  local dx = cx - x
  local dy = cy - y
  return dx * dx + dy * dy <= radius * radius
end

return collision