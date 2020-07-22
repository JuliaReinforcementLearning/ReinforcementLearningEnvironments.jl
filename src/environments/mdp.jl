using .POMDPs

RLBase.get_actions(m::Union{<:POMDP,<:MDP}) = convert(AbstractSpace, actions(m))

#####
# POMDPEnv
#####

Random.seed!(env::POMDPEnv, seed) = Random.seed!(env.rng, seed)

function POMDPEnv(model::POMDP; rng = Random.GLOBAL_RNG)
    s = initialstate(model, rng)
    a = rand(rng, actions(model))
    if :info in nodenames(DDNStructure(model))
        sp, o, r, info = gen(DDNOut(:sp, :o, :r, :info), model, s, a, rng)
    else
        (sp, o, r), info = gen(DDNOut(:sp, :o, :r), model, s, a, rng), nothing
    end
    env = POMDPEnv(model, sp, o, info, r, rng)
    reset!(env)
    env
end

# no info
function (env::POMDPEnv{<:POMDP,<:Any,<:Any,<:Nothing,<:Any,<:AbstractRNG})(a)
    sp, o, r = gen(DDNOut(:sp, :o, :r), env.model, env.state, a, env.rng)
    env.state = sp
    env.observation = o
    env.reward = r
    nothing
end

# has info
function (env::POMDPEnv)(a)
    sp, o, r, info = gen(DDNOut(:sp, :o, :r, :info), env.model, env.state, a, env.rng)
    env.state = sp
    env.observation = o
    env.info = info
    env.reward = r
    nothing
end

RLBase.get_state(env::POMDPEnv) = env.observation
RLBase.get_reward(env::POMDPEnv) = env.reward
RLBase.get_terminal(env::POMDPEnv) = isterminal(env.model, env.state)

function RLBase.reset!(env::POMDPEnv)
    env.state = initialstate(env.model, env.rng)
    env.observation = initialobs(env.model, env.state, env.rng)
    nothing
end

RLBase.get_actions(env::POMDPEnv) = get_actions(env.model)

#####
# MDPEnv
#####

Random.seed!(env::MDPEnv, seed) = seed!(env.rng, seed)

function MDPEnv(model::MDP; rng=Random.GLOBAL_RNG)
    s = initialstate(model, rng)
    a = rand(rng, actions(model))
    if :info in nodenames(DDNStructure(model))
        sp, r, info = gen(DDNOut(:sp, :r, :info), model, s, a, rng)
    else
        (sp, r), info = gen(DDNOut(:sp, :r), model, s, a, rng), nothing
    end
    env = MDPEnv(model, sp, info, r, rng)
    reset!(env)
    env
end

# no info
function (env::MDPEnv{<:MDP,<:Any,<:Nothing,<:Any,<:AbstractRNG})(a)
    sp, r = gen(DDNOut(:sp, :r), env.model, env.state, a, env.rng)
    env.state = sp
    env.reward = r
    nothing
end

# has info
function (env::MDPEnv)(a)
    sp, r, info = gen(DDNOut(:sp, :r, :info), env.model, env.state, a, env.rng)
    env.state = sp
    env.info = info
    env.reward = r
    nothing
end

RLBase.get_state(env::MDPEnv) = env.state
RLBase.get_reward(env::MDPEnv) = env.reward
RLBase.get_terminal(env::MDPEnv) = isterminal(env.model, env.state)

function RLBase.reset!(env::MDPEnv)
    env.state = initialstate(env.model, env.rng)
    nothing
end

RLBase.get_actions(env::MDPEnv) = get_actions(env.model)
