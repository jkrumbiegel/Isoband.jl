module Isoband

using isoband_jll


export isobands, isolines


struct ReturnValue
    xs::Ptr{Cdouble}
    ys::Ptr{Cdouble}
    ids::Ptr{Cint}
    len::Cint
end

function isobands(xs, ys, zs, low::Real, high::Real)
    results = isobands(xs, ys, zs, Float64[low], Float64[high])
    results[1]
end

function isobands(xs::AbstractVector, ys::AbstractVector, zs::AbstractMatrix, lows::AbstractVector, highs::AbstractVector)
    isobands(Float64.(xs), Float64.(ys), Float64.(zs), Float64.(lows), Float64.(highs))
end

function isobands(
        xs::Vector{Float64},
        ys::Vector{Float64},
        zs::Matrix{Float64},
        low_values::Vector{Float64},
        high_values::Vector{Float64})

    lenx = length(xs)
    leny = length(ys)
    nrow, ncol = size(zs)

    lenx != ncol && error("Length of x ($(length(xs))) must be equal to number of columns in z ($(size(z, 2)))")
    lenx != ncol && error("Length of y $(length(ys)) must be equal to number of rows in z ($(size(z, 1))")

    length(low_values) != length(high_values) && error("Number of low values ($(length(low_values)))and high values ($(length(high_values))) must be equal.")

    nbands = length(low_values)

    result = ccall((:isobands_impl, libisoband),
        Ptr{ReturnValue},
        (Ptr{Cdouble},
            Cint,
            Ptr{Cdouble},
            Cint,
            Ptr{Cdouble},
            Cint,
            Cint,
            Ptr{Cdouble},
            Ptr{Cdouble},
            Cint),
        xs, length(xs),
        ys, length(ys),
        zs, size(zs, 1), size(zs, 2),
        low_values, high_values, nbands)
    

    returnvalues = unsafe_wrap(Vector{ReturnValue}, result, nbands, own = true)

    groups = map(returnvalues) do rv
        n = rv.len
        xsr = unsafe_wrap(Vector{Cdouble}, rv.xs, n, own = true)
        ysr = unsafe_wrap(Vector{Cdouble}, rv.ys, n, own = true)
        idr = unsafe_wrap(Vector{Cint}, rv.ids, n, own = true)
        (x = xsr, y = ysr, id = idr)
    end

    groups
end


function isolines(xs, ys, zs, value::Real)
    results = isolines(xs, ys, zs, Float64[value])
    results[1]
end

function isolines(xs::AbstractVector, ys::AbstractVector, zs::AbstractMatrix, values::AbstractVector)
    isolines(Float64.(xs), Float64.(ys), Float64.(zs), Float64.(values))
end

function isolines(
        xs::Vector{Float64},
        ys::Vector{Float64},
        zs::Matrix{Float64},
        values::Vector{Float64})

    lenx = length(xs)
    leny = length(ys)
    nrow, ncol = size(zs)

    lenx != ncol && error("Length of x ($(length(xs))) must be equal to number of columns in z ($(size(z, 2)))")
    lenx != ncol && error("Length of y $(length(ys)) must be equal to number of rows in z ($(size(z, 1))")

    nvalues = length(values)

    result = ccall((:isolines_impl, libisoband),
        Ptr{ReturnValue},
        (Ptr{Cdouble},
            Cint,
            Ptr{Cdouble},
            Cint,
            Ptr{Cdouble},
            Cint,
            Cint,
            Ptr{Cdouble},
            Cint),
        xs, length(xs),
        ys, length(ys),
        zs, size(zs, 1), size(zs, 2),
        values, nvalues)
    

    returnvalues = unsafe_wrap(Vector{ReturnValue}, result, nvalues, own = true)

    groups = map(returnvalues) do rv
        n = rv.len
        xsr = unsafe_wrap(Vector{Cdouble}, rv.xs, n, own = true)
        ysr = unsafe_wrap(Vector{Cdouble}, rv.ys, n, own = true)
        idr = unsafe_wrap(Vector{Cint}, rv.ids, n, own = true)
        (x = xsr, y = ysr, id = idr)
    end
    
    groups
end


end
