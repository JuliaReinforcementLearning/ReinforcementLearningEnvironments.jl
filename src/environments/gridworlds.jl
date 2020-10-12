import ReinforcementLearningBase
import .GridWorlds
export RLBaseGridWorld

mutable struct RLBaseGridWorld{T<:GridWorlds.AbstractGridWorld} <: ReinforcementLearningBase.AbstractEnv
    env::T
end

Base.convert(::Type{ReinforcementLearningBase.AbstractEnv}, env::GridWorlds.AbstractGridWorld) = convert(RLBaseGridWorld, env)

Base.convert(::Type{RLBaseGridWorld}, env::GridWorlds.AbstractGridWorld) = RLBaseGridWorld(env)

ReinforcementLearningBase.get_state(env::RLBaseGridWorld) = GridWorlds.get_state(env.env)

ReinforcementLearningBase.get_actions(env::RLBaseGridWorld) = GridWorlds.get_actions(env.env)

ReinforcementLearningBase.get_reward(env::RLBaseGridWorld) = GridWorlds.get_reward(env)

ReinforcementLearningBase.get_terminal(env::RLBaseGridWorld) = GridWorlds.get_terminal(env.env)

ReinforcementLearningBase.get_legal_actions(env::RLBaseGridWorld) = GridWorlds.get_legal_actions(env.env)

ReinforcementLearningBase.get_legal_actions_mask(env::RLBaseGridWorld) = GridWorlds.get_legal_actions_mask(env.env)

ReinforcementLearningBase.reset!(env::RLBaseGridWorld) = GridWorlds.reset!(env.env)

(env::RLBaseGridWorld)(action) = env.env(action) 
