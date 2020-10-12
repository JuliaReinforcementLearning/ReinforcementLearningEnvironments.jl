export RLBaseGridWorld
import .GridWorlds

mutable struct RLBaseGridWorld{T<:GridWorlds.AbstractGridWorld} <: RLBase.AbstractEnv
    env::T
end

Base.convert(::Type{RLBase.AbstractEnv}, env::GridWorlds.AbstractGridWorld) = convert(RLBaseGridWorld, env)

Base.convert(::Type{RLBaseGridWorld}, env::GridWorlds.AbstractGridWorld) = RLBaseGridWorld(env)

RLBase.get_state(env::RLBaseGridWorld) = GridWorlds.get_state(env.env)

RLBase.get_actions(env::RLBaseGridWorld) = GridWorlds.get_actions(env.env)

RLBase.get_reward(env::RLBaseGridWorld) = GridWorlds.get_reward(env.env)

RLBase.get_terminal(env::RLBaseGridWorld) = GridWorlds.get_terminal(env.env)

RLBase.get_legal_actions(env::RLBaseGridWorld) = GridWorlds.get_legal_actions(env.env)

RLBase.get_legal_actions_mask(env::RLBaseGridWorld) = GridWorlds.get_legal_actions_mask(env.env)

RLBase.reset!(env::RLBaseGridWorld) = GridWorlds.reset!(env.env)

(env::RLBaseGridWorld)(action) = env.env(action)
