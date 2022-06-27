local animation = {}
flipState = require("flipState")

local completeFlipTime = 0.2

--- Starts a flip maneuver
function animation.startFlip(plane)
    plane.flipAnimationTimer = 0

    if plane.flipState == flipState.NONE then
        plane.flipState = flipState.FLIPPING
    elseif plane.flipState == flipState.FLIPPED then
        plane.flipState = flipState.FLIPPING_BACK
    end
end

--- Updates the flip maneuver
function animation.updateFlip(plane)
    if plane.flipState == flipState.NONE or plane.flipState == flipState.FLIPPED then
        return
    end

    if plane.flipAnimationTimer >= completeFlipTime then
        if plane.flipState == flipState.FLIPPING then
            plane.flipState = flipState.FLIPPED
        else
            plane.flipState = flipState.NONE
        end
    end
end

return animation
