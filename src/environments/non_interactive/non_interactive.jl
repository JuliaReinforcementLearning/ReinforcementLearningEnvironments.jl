export NonInteractiveEnv

abstract type NonInteractiveEnv <: AbstractEnv end
(env::NonInteractiveEnv)() = env(nothing)
RLBase.action_space(::NonInteractiveEnv) = EmptySpace()

include("pendulum.jl")
