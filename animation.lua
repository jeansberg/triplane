local animation = {}

function animation.startFlip(plane)
    plane.flipAnimationTimer = 0

    if plane.flipState == 'none' then
        plane.flipState = 'flipping'
    elseif plane.flipState == 'flipped' then
        plane.flipState = 'flippingBack'
    end
end

function animation.updateFlip(plane)
    if plane.flipState == 'none' or plane.flipState == 'flipped' then
        return
    end

    if plane.flipAnimationTimer >= 0.2 then
        if plane.flipState == 'flipping' then
            plane.flipState = 'flipped'
        else
            plane.flipState = 'none'
        end
    end
end

return animation
