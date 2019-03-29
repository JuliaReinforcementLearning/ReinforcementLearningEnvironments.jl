@testset "basic environment test" begin

    function basic_env_test(env, n=100)
        reset!(env)
        os = observation_space(env)
        as = action_space(env)
        @test os isa AbstractSpace
        @test as isa AbstractSpace
        @test reset!(env) == nothing
        for _ in 1:n
            a = rand(as)
            @test a in as
            obs, reward, isdone = interact!(env, a)
            @test obs in os
            if isdone
                reset!(env)
            end
        end
    end

    function basic_env_test(env::HanabiEnv, n=100)
        reset!(env)
        os = observation_space(env)
        as = action_space(env)
        @test os isa AbstractSpace
        @test as isa AbstractSpace
        @test reset!(env) == nothing
        for _ in 1:n
            a = rand(legal_actions(env))
            @test a in as
            interact!(env, a)
            obs, reward, isdone = observe(env)
            @test obs in os
            if isdone
                reset!(env)
            end
        end
    end

    gym_env_names = ReinforcementLearningEnvironments.list_gym_env_names(modules=[
        "gym.envs.algorithmic",
        "gym.envs.classic_control",
        "gym.envs.toy_text",
        "gym.envs.unittest"])  # mujoco, box2d, robotics are not tested here

    gym_env_names = filter(x -> x != "KellyCoinflipGeneralized-v0", gym_env_names)  # not sure why this env has outliers

    atari_env_names = ReinforcementLearningEnvironments.list_atari_rom_names()
    atari_env_names = filter(x -> x in ["pong"], atari_env_names)  # many atari games will have segment fault

    for env_exp in [
        :(HanabiEnv()),
        :(basic_ViZDoom_env()),
        :(CartPoleEnv()),
        :(MountainCarEnv()),
        :(PendulumEnv()),
        :(MDPEnv(LegacyGridWorld())),
        :(POMDPEnv(TigerPOMDP())),
        :(SimpleMDPEnv()),
        :(deterministic_MDP()),
        :(absorbing_deterministic_tree_MDP()),
        :(stochastic_MDP()),
        :(stochastic_tree_MDP()),
        :(deterministic_tree_MDP_with_rand_reward()),
        :(deterministic_tree_MDP()),
        :(deterministic_MDP()),
        (:(AtariEnv($x)) for x in atari_env_names)...,
        (:(GymEnv($x)) for x in gym_env_names)...
        ]
        
        @info "Testing $env_exp"
        env = eval(env_exp)
        basic_env_test(env)
    end
end