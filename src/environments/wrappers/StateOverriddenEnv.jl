export StateOverriddenEnv

"""
    StateOverriddenEnv(f, env)

Apply `f` to override `state(env)`.
"""
struct StateOverriddenEnv{F,E<:AbstractEnv} <: AbstractEnv
    f::F
    env::E
end

StateOverriddenEnv(f) = env -> StateOverriddenEnv(f, env)

(env::StateOverriddenEnv)(args...; kwargs...) = env.env(args...; kwargs...)

for f in vcat(RLBase.ENV_API, RLBase.MULTI_AGENT_ENV_API)
    if f != :state
        @eval RLBase.$f(x::StateOverriddenEnv, args...; kwargs...) = $f(x.env, args...; kwargs...)
    end
end

RLBase.state(env::StateOverriddenEnv, args...; kwargs...) = env.f(state(env.env, args...;kwargs...))
