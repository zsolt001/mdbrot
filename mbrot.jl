using Plots

function mandelbrot(limit)
    w, h = 800, 800  # width and height of the image
    img = zeros(h, w)

    xmin = -1.5
    xmax = 1.5
    ymin = -1
    ymax = 1

    xstep = abs(xmax - xmin) / w
    ystep = abs(ymax - ymin) / h


    for zx = xmin+xstep:xstep:xmax
        for zy = ymin+ystep:ystep:ymax
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
            img[y, x] = i == limit + 1 ? 0 : i
        end
    end

    return img
end

image = mandelbrot(100)
heatmap(image, color=:inferno, axis=false)
