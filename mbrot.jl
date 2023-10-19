using GLMakie
GLMakie.activate!()


function mandelbrot(limit)
    w, h = 1800, 1800  # width and height of the image
    img = zeros(h, w)

    xmin = -2
    xmax = 1
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
            img[x, y] = color
        end
    end

    return img
end


fig = Figure()
image = mandelbrot(100)
hm = heatmap(fig[1, 1], image, colormap=:inferno)
sl_limit = Slider(fig[2, 1], range=0:50:1000, startvalue=100)

# Define a function to update the heatmap
function update_heatmap(slider_value)
    # Generate a new image based on the slider value
    new_image = mandelbrot(slider_value)
    # Update the existing heatmap with the new image
    hm.plot[3][] = new_image
end

# Observe the changes in the slider value and trigger the update_heatmap function
on(sl_limit.value) do value
    println("slider value: $value")
    update_heatmap(value)
end

# Display the figure
fig
