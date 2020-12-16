using Test
using ReinforcementLearningBase
using ReinforcementLearningEnvironments
using ArcadeLearningEnvironment
using PyCall
using OpenSpiel
# using SnakeGames
using Random

@testset "ReinforcementLearningEnvironments" begin

    include("environments.jl")
    include("atari.jl")
    include("open_spiel.jl")
end
