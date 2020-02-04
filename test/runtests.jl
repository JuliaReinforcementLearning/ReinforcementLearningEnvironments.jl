using Test
using ReinforcementLearningBase
using ReinforcementLearningCore
using ReinforcementLearningEnvironments
using ArcadeLearningEnvironment
using PyCall
using POMDPs
using POMDPModels

RLBase.get_observation_space(m::TigerPOMDP) = DiscreteSpace(1, 0)
RLBase.get_action_space(m::TigerPOMDP) = DiscreteSpace(2, 0)

@testset "ReinforcementLearningEnvironments" begin

    include("environments.jl")
    include("atari.jl")
end