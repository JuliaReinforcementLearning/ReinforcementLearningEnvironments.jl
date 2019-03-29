# Benchmarks of the runtime for different environments

Each environment is estimated to run **1000** steps.

| Environment | mean time | median time | memory | allocs |
| :---------- | --------: | ----------: | -----: | -----: |
|HanabiEnv()|157.053 ms|149.206 ms|55.62 MiB|1487004|
|basic_ViZDoom_env()|656.613 ms|649.227 ms|216.30 KiB|4011|
|CartPoleEnv()|101.385 μs|82.800 μs|41.75 KiB|1096|
|MountainCarEnv()|83.251 μs|66.200 μs|31.25 KiB|1000|
|PendulumEnv()|110.044 μs|85.600 μs|142.31 KiB|2018|
|MDPEnv(LegacyGridWorld())|187.392 μs|143.900 μs|250.00 KiB|5000|
|POMDPEnv(TigerPOMDP())|834.282 μs|782.900 μs|250.00 KiB|9000|
|SimpleMDPEnv()|871.187 μs|802.800 μs|281.25 KiB|10000|
|deterministic_MDP()|11.466 ms|10.913 ms|310.38 KiB|11864|
|absorbing_deterministic_tree_MDP()|1.951 ms|1.879 ms|294.56 KiB|10852|
|stochastic_MDP()|935.682 μs|875.700 μs|281.25 KiB|10000|
|stochastic_tree_MDP()|1.069 ms|988.300 μs|281.25 KiB|10000|
|deterministic_tree_MDP_with_rand_reward()|1.349 ms|1.244 ms|281.25 KiB|10000|
|deterministic_tree_MDP()|1.322 ms|1.252 ms|281.25 KiB|10000|
|deterministic_MDP()|11.013 ms|10.662 ms|310.19 KiB|11852|
|AtariEnv("pong")|894.924 ms|884.434 ms|46.89 KiB|2001|
|GymEnv("RepeatCopy-v0")|32.195 ms|29.655 ms|1.00 MiB|32092|
|GymEnv("NChain-v0")|11.967 ms|10.462 ms|640.94 KiB|23006|
|GymEnv("Reverse-v0")|33.009 ms|30.469 ms|1020.47 KiB|31993|
|GymEnv("Roulette-v0")|16.289 ms|13.696 ms|643.44 KiB|23054|
|GymEnv("FrozenLake8x8-v0")|28.258 ms|26.594 ms|644.06 KiB|23066|
|GymEnv("Pendulum-v0")|60.782 ms|54.237 ms|1.62 MiB|46018|
|GymEnv("ReversedAddition-v0")|35.645 ms|32.383 ms|1017.66 KiB|31939|
|GymEnv("Copy-v0")|33.209 ms|30.107 ms|1.00 MiB|32107|
|GymEnv("CubeCrash-v0")|54.421 ms|49.486 ms|1.47 MiB|39099|
|GymEnv("Taxi-v2")|31.265 ms|28.624 ms|641.56 KiB|23018|
|GymEnv("KellyCoinflip-v0")|22.026 ms|18.725 ms|628.34 KiB|22950|
|GymEnv("CartPole-v0")|32.029 ms|27.756 ms|1.12 MiB|35111|
|GymEnv("CliffWalking-v0")|34.259 ms|28.796 ms|640.78 KiB|23003|
|GymEnv("FrozenLake-v0")|34.792 ms|31.889 ms|657.34 KiB|23321|
|GymEnv("MemorizeDigits-v0")|63.710 ms|61.023 ms|1.47 MiB|39117|
|GymEnv("CubeCrashScreenBecomesBlack-v0")|55.584 ms|50.865 ms|1.47 MiB|39099|
|GymEnv("CubeCrashSparse-v0")|46.757 ms|42.579 ms|1.47 MiB|39099|
|GymEnv("HotterColder-v0")|40.582 ms|36.373 ms|1.13 MiB|34018|
|GymEnv("Blackjack-v0")|49.364 ms|45.215 ms|671.25 KiB|23088|
|GymEnv("CartPole-v1")|32.812 ms|29.588 ms|1.12 MiB|35108|
|GymEnv("MountainCarContinuous-v0")|34.644 ms|28.951 ms|1.62 MiB|46006|
|GymEnv("MountainCar-v0")|35.380 ms|31.822 ms|1.11 MiB|35018|
|GymEnv("DuplicatedInput-v0")|35.698 ms|31.848 ms|1.01 MiB|32308|
|GymEnv("ReversedAddition3-v0")|36.525 ms|32.871 ms|1017.81 KiB|31942|
|GymEnv("GuessingGame-v0")|34.739 ms|30.805 ms|1.13 MiB|34018|
|GymEnv("Acrobot-v1")|186.435 ms|183.649 ms|1.11 MiB|35009|
