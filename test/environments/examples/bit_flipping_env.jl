@testset "bit_flipping_env" begin

    env = BitFlippingEnv(; N = 7)
    test_state = state(env,GoalState())
    RLBase.test_interfaces!(env)
    RLBase.test_runnable!(env)

end
