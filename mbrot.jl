using GLMakie
GLMakie.activate!()


# check this for custom zoom/selection: https://discourse.julialang.org/t/makie-jl-mouse-interaction-question-discussion/14396/3
# this is deprecated but we need something similar

mutable struct Rectangle
    x::Float64      # x-coordinate of the top-left corner
    y::Float64      # y-coordinate of the top-left corner
    width::Float64  # width of the rectangle
    height::Float64 # height of the rectangle
end

struct Coord
    x::Float64
    y::Float64
end

function mandelbrot(limit::Int, area::Rectangle, pixel_width::Int, pixel_height::Int)
    xmin = area.x
    xmax = area.x + area.width
    ymin = area.y - area.height
    ymax = area.y

    img = zeros(pixel_width, pixel_height)

    xstep = abs(xmax - xmin) / pixel_width
    ystep = abs(ymax - ymin) / pixel_height


    for zx = xmin+xstep:xstep:xmax-xstep
        for zy = ymin+ystep:ystep:ymax-ystep
            c = zx + zy * im
            z = c
            i = 1
            while i <= limit
                if abs2(z) > 4.0
                    break  # escape
                end
                z = z^2 + c
                i += 1
            end

            # Convert iteration number into color
            color = i == limit + 1 ? 0 : i
            y = Int(round((zy - ymin) / ystep))
            x = Int(round((zx - xmin) / xstep))
            img[x, y] = color
        end
    end

    return img
end

fig = Figure()

area = Observable(Rectangle(-1.5, 1.0, 3.0, 2.0))

sl_grid = SliderGrid(fig[2, 1],
    (label="limit", range=0:50:1000, startvalue=100, snap=false),
    (label="image width", range=200:1000, startvalue=400)
)

limit = sl_grid.sliders[1].value
image_width = sl_grid.sliders[2].value
image_height = lift(image_width, area) do iw, ar
    Int(round(iw * (ar.width / ar.height)))
end

image = lift((l, w, h) -> mandelbrot(l[], area[], w[], h[]), limit, image_width, image_height)
ax, hm = heatmap(fig[1, 1], image, colormap=:inferno)


function mapScreenCoordToPlane(screenArea::Rectangle, planeArea::Rectangle, screenPoint::Coord)
    xProportion = screenPoint.x / screenArea.width
    yProportion = screenPoint.y / screenArea.height
    planePoint = Coord(planeArea.x + xProportion * planeArea.width, planeArea.y - yProportion * planeArea.height)
    return planePoint
end



function on_rzoom(rect)
    screen = Rectangle(0.0, 0.0, image_width[], image_height[])
    selectionTopLeft = Coord(rect.origin[1], rect.origin[2])
    selectionBottomRight = Coord(rect.origin[1] + rect.widths[1], rect.origin[2] + rect.widths[2])

    areaTopLeft::Coord = mapScreenCoordToPlane(screen, area[], selectionTopLeft)
    areaBottomRight::Coord = mapScreenCoordToPlane(screen, area[], selectionBottomRight)

    # area[].x = areaTopLeft.x
    # area[].y = areaTopLeft.y
    # area[].width = abs(areaBottomRight.x - areaTopLeft.x)
    # area[].height = abs(areaBottomRight.y - areaTopLeft.y)

    area[] = Rectangle(areaTopLeft.x, areaTopLeft.y, abs(areaBottomRight.x - areaTopLeft.x), abs(areaBottomRight.y - areaTopLeft.y))

    @show selectionTopLeft
    @show selectionBottomRight

    @show areaTopLeft
    @show areaBottomRight
end
ax.interactions[:rectanglezoom][2].callback = on_rzoom


fig
