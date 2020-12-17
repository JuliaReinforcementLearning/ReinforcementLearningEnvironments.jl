
    gym_env_names = ReinforcementLearningEnvironments.list_gym_env_names(
        modules = [
            "gym.envs.algorithmic",
            "gym.envs.classic_control",
            "gym.envs.toy_text",
            "gym.envs.unittest",
        ],
    )  # mujoco, box2d, robotics are not tested here

    gym_env_names = filter(x -> x != "KellyCoinflipGeneralized-v0", gym_env_names)  # not sure why this env has outliers