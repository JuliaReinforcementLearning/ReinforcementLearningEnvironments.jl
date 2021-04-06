
export FrozenLakeEnv

Base.@kwdef mutable struct frozenlakeEnv <: AbstractEnv
	# lake: 3 is the spawn point, 1 is the goal and 2 are obstacles.
	lake::Array{Int8,2} = [1 0 0 0 0
		                   0 2 0 2 0
		                   0 0 0 2 0
						   0 2 0 0 0
		                   0 0 0 0 3]
	reward::Union{Nothing, Float64} = 0
	observation::Int = 24
	is_terminated = false
	num_steps::Int8 = 0
	MAX_STEPS::Int8 = 100
end

RLBase.action_space(env::frozenlakeEnv) = (:up, :right, :down, :left)

begin
    RLBase.state(env::frozenlakeEnv) = env.observation
    RLBase.state_space(env::frozenlakeEnv) = collect(0:24)
    RLBase.is_terminated(env::frozenlakeEnv) = env.is_terminated  
end

function RLBase.reset!(env::frozenlakeEnv)
	env.reward = 0
	env.observation = 24
	env.num_steps = 0
	env.is_terminated = false
end

function moveDeterministic(action::String, observation)
	if action == "up"
		observation = clamp((observation÷5)-1, 0, 4)*5 + (observation - 5*(observation÷5))
	elseif action == "down"
		observation = clamp((observation÷5)+1, 0, 4)*5 + (observation - 5*(observation÷5))
	elseif action == "left"
		observation = observation÷5*5 + clamp((observation - 5*(observation÷5))-1, 0, 4)
	elseif action == "right"
		observation = observation÷5*5 + clamp((observation - 5*(observation÷5))+1, 0, 4)
	end
	return observation
end


function (env::frozenlakeEnv)(action)
	r = rand()
	env.num_steps += 1
	if action == :up
		if r < 1/3
			# goes up
			env.observation = moveDeterministic("up", env.observation)
		elseif r < 2/3
			# goes left
			env.observation = moveDeterministic("left", env.observation)
		else
			# goes right
			env.observation = moveDeterministic("left", env.observation)
		end
	
	elseif action == :right
		if r < 1/3
			# goes right
			env.observation = moveDeterministic("right", env.observation)
		elseif r < 2/3
			# goes up
			env.observation = moveDeterministic("up", env.observation)
		else
			# goes down
			env.observation = moveDeterministic("down", env.observation)
		end
	
	elseif action == :down
		if r < 1/3
			# goes right
			env.observation = moveDeterministic("right", env.observation)
		elseif r < 2/3
			# goes left
			env.observation = moveDeterministic("left", env.observation)
		else
			# goes down
			env.observation = moveDeterministic("down", env.observation)
		end
	
	elseif action == :left
		if r < 1/3
			# goes up
			env.observation = moveDeterministic("up", env.observation)
		elseif r < 2/3
			# goes left
			env.observation = moveDeterministic("left", env.observation)
		else
			# goes down
			env.observation = moveDeterministic("down", env.observation)
		end
	else
        @error "unknown action of $action"
	end

	obdiv5 = env.observation÷5
	if env.num_steps>env.MAX_STEPS
		env.is_terminated = true
	end
	if env.lake[obdiv5+1, env.observation - (5*obdiv5) + 1] == 0 || env.lake[obdiv5+1, env.observation - (5*obdiv5) + 1] == 3
		env.reward-=0.01
	elseif env.lake[obdiv5+1, env.observation - (5*obdiv5) + 1] == 2
		env.is_terminated = true
		env.reward-=1
	elseif env.lake[obdiv5+1, env.observation - (5*obdiv5) + 1] == 1
		env.is_terminated = true
		env.reward+=5
    end
	# println(env.reward," ", env.num_steps, " ", env.observation)
end

RLBase.reward(env::frozenlakeEnv) = env.reward

# Env = frozenlakeEnv()
# RLBase.test_runnable!(Env)
# begin
# 	run(RandomPolicy(action_space(Env)), Env, StopAfterEpisode(1)) 
# end

# begin
#     hook = TotalRewardPerEpisode()
#     run(RandomPolicy(action_space(Env)), Env, StopAfterEpisode(10), hook)
#     plot(hook.rewards)
# end
# p = QBasedPolicy(
#     learner = MonteCarloLearner(;
#             approximator=TabularQApproximator(
#                 n_state = length(state_space(Env)),
#                 n_action = length(action_space(Env)),
#             )
#         ),
#     explorer = EpsilonGreedyExplorer(0.1)
# )