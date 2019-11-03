export MultiThreadEnv
import Base.Threads.@spawn

struct MultiThreadEnv{O, E} <: AbstractEnv
    envs::Vector{E}
end

function MultiThreadEnv(f, n)
    envs = [f() for _ in 1:n]
    obs = observe(envs[1])
    MultiThreadEnv{typeof(obs), typeof(envs[1])}(envs)
end

Base.getindex(env::MultiThreadEnv, i) = getindex(env.envs, i)
Base.length(env::MultiThreadEnv) = length(env.envs)

function interact!(env::MultiThreadEnv, actions)
    @sync for i in 1:length(env)
        @spawn interact!(env[i], actions[i])
    end
end

function observe(env::MultiThreadEnv{O, E}) where {O, E}
    n = length(env)
    obs = Vector{O}(undef, n)
    @sync for i in 1:n
        @spawn begin
            o = observe(env[i])
            if o.terminal
                r, t = o.reward, o.terminal
                reset!(env[i])
                first_obs = observe(env[i])
                o = Observation(r, t, first_obs.state, first_obs.meta)
            end
            obs[i] = o
        end
    end
end