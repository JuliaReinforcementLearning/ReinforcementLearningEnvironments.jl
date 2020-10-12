import .GridWorlds

mutable struct RLBaseGridWorld{T<:GridWorlds.AbstractGridWorld} <: AbstractEnv
    env::T
end

Base.convert(::Type{AbstractEnv}, env::GridWorlds.AbstractGridWorld) = convert(RLBaseGridWorld, env)

Base.convert(::Type{RLBaseGridWorld}, env::GridWorlds.AbstractGridWorld) = RLBaseGridWorld(env)

get_state(env::RLBaseGridWorld) = GridWorlds.get_state(env.env)

get_actions(env::RLBaseGridWorld) = GridWorlds.get_actions(env.env)

get_reward(env::RLBaseGridWorld) = GridWorlds.get_reward(env)

get_terminal(env::RLBaseGridWorld) = GridWorlds.get_terminal(env.env)

get_legal_actions(env::RLBaseGridWorld) = GridWorlds.get_legal_actions(env.env)

get_legal_actions_mask(env::RLBaseGridWorld) = GridWorlds.get_legal_actions_mask(env.env)

reset!(env::RLBaseGridWorld) = GridWorlds.reset!(env.env)

(env::RLBaseGridWorld)(action) = env.env(action) 
