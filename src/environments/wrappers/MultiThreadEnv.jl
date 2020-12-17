"""
    MultiThreadEnv(envs::Vector{<:AbstractEnv})

Wrap multiple instances of the same environment type into one environment.
Each environment will run in parallel by leveraging `Threads.@spawn`.
So remember to set the environment variable `JULIA_NUM_THREADS`!
"""
struct MultiThreadEnv{E,N,A,S,L} <: AbstractEnv
    envs::Vector{E}
    states::Array{Float32, N}
    rewards::Vector{Float32}
    terminals::Vector{Bool}
    action_space::A
    state_space::S
    legal_action_space_mask::L
end

function MultiThreadEnv(f, n)
    envs = [f() for _ in 1:n]

    S = state_space(envs[1])
    s = state(envs[1])
    if S isa Space
        S_batch = similar(S, size(S)..., n)
        s_batch = similar(s, size(s)..., n)
        for j in 1:n
            Sₙ = state_space(envs[j])
            sₙ = state(envs[j])
            for i in CartesianIndices(size(S))
                S_batch[i, j] = Sₙ[i]
                s_batch[i, j] = sₙ
            end
        end
    else
        S_batch = Space(state_space.(envs))
        s_batch = state.(envs)
    end

    A = action_space(envs[1])
    if A isa Space
        A_batch = similar(A, size(A)..., n)
        for j in 1:n
            Aⱼ = action_space(envs[j])
            for i in CartesianIndices(size(A))
                A_batch[i, j] = Aⱼ[i]
            end
        end
    else
        A_batch = Space(state_space.(envs))
    end

    r_batch = reward.(envs)
    t_batch = is_terminated.(envs)
    if ActionStyle(env) === FULL_ACTION_SET
        m_batch = BitArray(undef, size(A_batch))
        for j in 1:n
            L = legal_action_space_mask(envs[j])
            for i in CartesianIndices(size(A))
                m_batch[i, j] = L[i]
            end
        end
    else
        m_batch = nothing
    end
    MultiThreadEnv(envs, s_batch, r_batch, t_batch, A_batch, S_batch, m_batch)
end

@forward MultiThreadEnv.envs Base.getindex, Base.length, Base.iterate

function (env::MultiThreadEnv)(actions)
    @sync for i in 1:length(env)
        @spawn begin
            env[i](actions[i])
        end
    end
end

function RLBase.reset!(env::MultiThreadEnv; is_force = false)
    if is_force
        for i in 1:length(env)
            reset!(env[i])
        end
    else
        @sync for i in 1:length(env)
            if get_terminal(env[i])
                @spawn begin
                    reset!(env[i])
                end
            end
        end
    end
end

const MULTI_THREAD_ENV_CACHE = IdDict{AbstractEnv,Dict{Symbol,Array}}()

function RLBase.state(env::MultiThreadEnv{E,N}) where {E,N}
    @sync for i in 1:length(env)
        @spawn selectdim(env.states, N, i) .= state(env[i])
    end
    env.states
end

function RLBase.reward(env::MultiThreadEnv)
    env.rewards .= reward.(env.envs)
    env.rewards
end

function RLBase.is_terminated(env::MultiThreadEnv)
    env.terminals .= is_terminated.(env.envs)
    env.terminals
end

function RLBase.legal_action_space_mask(env::MultiThreadEnv)
    @sync for i in 1:length(env)
        @spawn selectdim(env.legal_action_space_mask, N, i) .= legal_action_space_mask(env[i])
    end
    env.legal_action_space_mask
end

RLBase.action_space(env::MultiThreadEnv) = env.action_space
RLBase.state_space(env::MultiThreadEnv) = env.state_space
RLBase.current_player(env::MultiThreadEnv) = current_player.(env.envs)

for f in RLBase.ENV_API
    if endswith(String(f), "Style")
        @eval RLBase.$f(x::MultiThreadEnv) = $f(x[1])
    end
end