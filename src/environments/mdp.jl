using .POMDPs

RLBase.action_space(m::Union{<:POMDP,<:MDP}) = convert(AbstractSpace, actions(m))

#####
# POMDPEnv
#####

function POMDPEnv(model::M; rng = Random.GLOBAL_RNG) where {M<:POMDP}
    s = rand(rng, initialstate(model))
    a = rand(rng, actions(model))
    o = rand(rng, initialobs(model, s))
    POMDPEnv(model, s, a, o, rng)
end

function (env::POMDPEnv)(a)
    env.action = a
    old_state = env.state
    env.state = rand(env.rng, transition(env.model, old_state, a))
    env.observation = rand(env.rng, observation(env.model, old_state, a, env.state))
end

RLBase.state(env::POMDPEnv) = env.observation
RLBase.reward(env::POMDPEnv) = reward(env.state, env.action)
RLBase.is_terminated(env::POMDPEnv) = isterminal(env.model, env.state)

function RLBase.reset!(env::POMDPEnv)
    env.state = rand(env.rng, initialstate(env.model))
    env.observation = rand(env.rng, initialobs(env.model, env.state))
    nothing
end

RLBase.action_space(env::POMDPEnv) = actions(env.model)
Random.seed!(env::POMDPEnv, seed) = seed!(env.rng, seed)

#####
# MDPEnv
#####

function MDPEnv(model::MDP; rng = Random.GLOBAL_RNG)
    s = rand(rng, initialstate(model))
    a = rand(rng, actions(model))
    MDPEnv(model, s, a, rng)
end

function (env::MDPEnv)(a)
    env.action = a
    old_state = env.state
    env.state = rand(env.rng, transition(env.model, old_state, a))
end

RLBase.state(env::MDPEnv) = env.state
RLBase.reward(env::MDPEnv) = reward(env.state, env.action)
RLBase.is_terminated(env::MDPEnv) = isterminal(env.model, env.state)

function RLBase.reset!(env::MDPEnv)
    env.state = rand(env.rng, initialstate(env.model))
end

RLBase.action_space(env::MDPEnv) = actions(env.model)

Random.seed!(env::MDPEnv, seed) = seed!(env.rng, seed)
