using Test
using ReinforcementLearningEnvironments
using ArcadeLearningEnvironment
using PyCall

@testset "ReinforcementLearningEnvironments" begin

    include("environments.jl")
    include("atari.jl")
end