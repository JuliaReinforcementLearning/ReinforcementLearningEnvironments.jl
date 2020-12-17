export RewardOverriddenEnv

struct RewardOverriddenEnv{F,E<:AbstractEnv} <: AbstractEnv
    f::F
    env::E
end

(env::RewardOverriddenEnv)(args...; kwargs...) = env.env(args...; kwargs...)

RewardOverriddenEnv(f) = env -> RewardOverriddenEnv(f, env)

for f in vcat(RLBase.ENV_API, RLBase.MULTI_AGENT_ENV_API)
    if f != :reward
        @eval RLBase.$f(x::RewardOverriddenEnv, args...; kwargs...) = $f(x.env, args...; kwargs...)
    end
end

RLBase.reward(env::RewardOverriddenEnv, args...; kwargs...) = env.f(reward(env.env, args...; kwargs...))