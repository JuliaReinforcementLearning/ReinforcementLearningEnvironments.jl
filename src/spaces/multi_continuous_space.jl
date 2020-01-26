export MultiContinuousSpace
using Distributions: Uniform
using Random: AbstractRNG

struct MultiContinuousSpace{S, N, Fl<:AbstractFloat, AFl<:AbstractArray{Fl,N}} <: AbstractDiscreteSpace
    low::AFl
    high::AFl
end

function MultiContinuousSpace(low::AFl, high::AFl) where {Fl <: AbstractFloat, AFl <: AbstractArray{Fl}}
  size(low) == size(high) || throw(ArgumentError("$(size(low)) != $(size(high)), size must match"))
  all(l < h for (l, h) in zip(
      low,
      high,
  )) || throw(ArgumentError("each element of $low must be less than $high"))
  MultiContinuousSpace{size(low),Fl,ndims(low),AFl}(low, high)
end

MultiContinuousSpace(low, high; float_type = Float64) =
    MultiContinuousSpace(convert(Array{float_type}, low), convert(Array{float_type}, high))

Base.eltype(::MultiContinuousSpace{S,N,Fl}) where {S,Fl,N} = Array{Fl,N}
Base.in(xs, s::MultiContinuousSpace) =
    size(xs) == S && all(l <= x <= h for (l, x, h) in zip(s.low, xs, s.high))
Base.:(==)(s1::MultiContinuousSpace, s2::MultiContinuousSpace) =
    s1.low == s2.low && s1.high == s2.high
Base.rand(rng::AbstractRNG, s::MultiContinuousSpace) =
    map((l, h) -> rand(rng, Uniform(l, h)), s.low, s.high)
Base.size(s::MultiContinuousSpace) = size(s.low)
Base.length(s::MultiContinuousSpace) = length(s.low)