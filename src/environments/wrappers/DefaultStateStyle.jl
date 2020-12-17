export DefaultStateStyleEnv

struct DefaultStateStyleEnv{S,E} <: AbstractEnv
    env::E
end

"""
    DefaultStateStyleEnv{S}(env::E)

Reset the result of `DefaultStateStyle` without changing the original behavior.
"""
DefaultStateStyleEnv{S}(env::E) where {S<:RLBase.AbstractStateStyle,E<:AbstractEnv} = DefaultStateStyleEnv{S,E}(env)

RLBase.DefaultStateStyle(::DefaultStateStyleEnv{S}) where {S} = S

for f in vcat(RLBase.ENV_API, RLBase.MULTI_AGENT_ENV_API)
    if f != :DefaultStateStyle
        @eval RLBase.$f(x::DefaultStateStyleEnv, args...; kwargs...) =
            $f(x.env, args...; kwargs...)
    end
end