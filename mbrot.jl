using GLMakie
GLMakie.activate!()


function mandelbrot(limit, width, height)
    w = width[]
    h = height[]
    lim = limit[]

    img = zeros(w, h)

    xmin = -2
    xmax = 1
    ymin = -1
    ymax = 1

    xstep = abs(xmax - xmin) / w
    ystep = abs(ymax - ymin) / h


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
            color = i == lim + 1 ? 0 : i
            y = Int(round((zy - ymin) / ystep))
            x = Int(round((zx - xmin) / xstep))
            img[x, y] = color
        end
    end

    return img
end

fig = Figure()

sl_grid = SliderGrid(fig[2, 1],
    (label="limit", range=0:50:1000, startvalue=100, snap=false),
    (label="resolution", range=200:1000, startvalue=200)
)

w = Observable(1)
connect!(w, sl_grid.sliders[2].value)
h = @lift(Int(round($w .* 0.8)))
limit = sl_grid.sliders[1].value

# image = mandelbrot(100, w, h)
image = lift((l, w, h) -> mandelbrot(l, w, h), limit, w, h)

hm = heatmap!(fig[1, 1], image, colormap=:inferno)

# Display the figure
fig
