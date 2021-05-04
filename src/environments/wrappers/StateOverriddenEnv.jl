export StateOverriddenEnv

"""
    StateOverriddenEnv(env; state_mapping=identity, state_space_mapping=identity)

Apply `state_mapping` on `state(env)`.
Apply `state_space_mapping` on `state_space(env)`.
"""
struct StateOverriddenEnv{P,M,E<:AbstractEnv} <: AbstractEnvWrapper
    state_mapping::P
    state_space_mapping::M
    env::E
end

StateOverriddenEnv(env; state_mapping=identity, state_space_mapping=identity) = 
    StateOverriddenEnv(state_mapping, state_space_mapping, env)

StateOverriddenEnv(; state_mapping=identity, state_space_mapping=identity) = 
    env -> StateOverriddenEnv(state_mapping, state_space_mapping, env)

RLBase.state(env::StateOverriddenEnv, args...; kwargs...) =
    env.state_mapping(state(env.env, args...; kwargs...))

RLBase.state_space(env::StateOverriddenEnv, args...; kwargs...) = 
    env.state_space_mapping(state_space(env.env, args...; kwargs...))