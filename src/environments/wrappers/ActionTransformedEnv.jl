export ActionTransformedEnv

struct ActionTransformedEnv{P,M,E<:AbstractEnv} <: AbstractEnv
    action_space_mapping::P
    action_mapping::M
    env::E
end

"""
    ActionTransformedEnv(env;action_space_mapping=identity, action_mapping=identity)

`action_space_mapping` will be applied to `action_space(env)` and
`legal_action_space(env)`. `action_mapping` will be applied to `action` before
feeding it into `env`.
"""
function ActionTransformedEnv(env; action_space_mapping=identity, action_mapping=identity)
    ActionTransformedEnv(env, action_space_mapping, action_mapping)
end

for f in vcat(RLBase.ENV_API, RLBase.MULTI_AGENT_ENV_API)
    if f ∉ (:action_space, :legal_action_space)
        @eval RLBase.$f(x::ActionTransformedEnv, args...; kwargs...) =
            $f(x.env, args...; kwargs...)
    end
end

RLBase.state_space(env::ActionTransformedEnv) = env.action_space_mapping(action_space(env.env))
RLBase.legal_action_space(env::ActionTransformedEnv) = env.action_space_mapping(legal_action_space(env.env))

(env::ActionTransformedEnv)(action, args...; kwargs...) = env.env(env.action_space_mapping(action), args...; kwargs...)
