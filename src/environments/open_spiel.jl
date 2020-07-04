import .OpenSpiel:
    load_game,
    get_type,
    provides_information_state_tensor,
    provides_observation_tensor,
    dynamics,
    new_initial_state,
    chance_mode,
    is_chance_node,
    information_state_tensor,
    information_state_tensor_size,
    information_state_string,
    num_distinct_actions,
    num_players,
    apply_action,
    current_player,
    player_reward,
    legal_actions,
    legal_actions_mask,
    rewards,
    history,
    observation_tensor_size,
    observation_tensor,
    observation_string,
    chance_outcomes
using StatsBase: sample, weights


"""
    OpenSpielEnv(name; state_type=nothing, kwargs...)

# Arguments

- `name`::`String`, you can call `ReinforcementLearningEnvironments.OpenSpiel.registered_names()` to see all the supported names. Note that the name can contains parameters, like `"goofspiel(imp_info=True,num_cards=4,points_order=descending)"`. Because the parameters part is parsed by the backend C++ code, the bool variable must be `True` or `False` (instead of `true` or `false`). Another approach is to just specify parameters in `kwargs` in the Julia style.
- `state_type`::`Union{Symbol,Nothing}`, Supported values are [`:information`](https://github.com/deepmind/open_spiel/blob/1ad92a54f3b800394b2bc7f178ccdff62d8369e1/open_spiel/spiel.h#L342-L367), [`:observation`](https://github.com/deepmind/open_spiel/blob/1ad92a54f3b800394b2bc7f178ccdff62d8369e1/open_spiel/spiel.h#L397-L408) or `nothing`. The default value is `nothing`, which means `:information` if the game ` provides_information_state_tensor`. If not, it means `:observation`.
- `seed::Int`, used to initial the internal `rng`. And the `rng` will only be used if the environment contains chance node, else it is set to `nothing`.
- `is_chance_agent_required::Bool=false`, by default, no chance agent is required. An internal `rng` will be used to automatically generate actions for chance node. If set to `true`, you need to feed the action of chance agent to environment explicitly. And the `seed` will be ignored.
"""
function OpenSpielEnv(name; seed = nothing, state_type= nothing, is_chance_agent_required=false, kwargs...)
    game = load_game(name, kwargs...)
    game_type = get_type(game)

    has_info_state = provides_information_state_tensor(game_type)
    has_obs_state = provides_observation_tensor(game_type)
    has_info_state ||
        has_obs_state ||
        @error "the environment neither provides information tensor nor provides observation tensor"
    if isnothing(state_type)
        state_type= has_info_state ? :information : :observation
    end
    if state_type== :observation
        has_obs_state ||
            @error "the environment doesn't support state_typeof $state_type"
    elseif state_type== :information
        has_info_state ||
            @error "the environment doesn't support state_typeof $state_type"
    else
        @error "unknown state_type $state_type"
    end

    d = dynamics(game_type)
    dynamic_style = if d === OpenSpiel.SEQUENTIAL
        RLBase.SEQUENTIAL
    elseif d === OpenSpiel.SIMULTANEOUS
        RLBase.SIMULTANEOUS
    else
        @error "unknown dynamic style of $d"
    end

    state = new_initial_state(game)

    if chance_mode(game_type) === OpenSpiel.DETERMINISTIC
        rng = nothing
    else
        rng = MersenneTwister(seed)
    end

    env =
        OpenSpielEnv{state_type,dynamic_style,typeof(state),typeof(game),typeof(rng),is_chance_agent_required}(
            state,
            game,
            rng,
        )
    reset!(env)
    env
end

is_chance_agent_required(env::OpenSpielEnv{O,D,S,G,R,C}) where {O,D,S,G,R,C} = C

Base.copy(env::OpenSpielEnv{O,D,S,G,R,C}) where {O,D,S,G,R,C} =
    OpenSpielEnv{O,D,S,G,R,C}(copy(env.state), env.game, env.rng)
Base.show(io::IO, env::OpenSpielEnv) = show(io, env.state)
Base.show(io::IO, obs::OpenSpielObs) = show(io, obs.state)

RLBase.DynamicStyle(env::OpenSpielEnv{O,D}) where {O,D} = D

function RLBase.reset!(env::OpenSpielEnv)
    state = new_initial_state(env.game)
    is_chance_agent_required(env) || _sample_external_events!(env.rng, state)
    env.state = state
end

function RLBase.reset!(env::OpenSpielEnv, state)
    is_chance_agent_required(env) || _sample_external_events!(env.rng, state)
    env.state = state
end

_sample_external_events!(::Nothing, state) = nothing

function _sample_external_events!(rng::AbstractRNG, state)
    while is_chance_node(state)
        outcomes_with_probs = chance_outcomes(state)
        actions, probs = zip(outcomes_with_probs...)
        action = actions[sample(rng, weights(collect(probs)))]
        apply_action(state, action)
    end
end

function (env::OpenSpielEnv)(action)
    apply_action(env.state, action)
    is_chance_agent_required(env) || _sample_external_events!(env.rng, env.state)
end

(env::OpenSpielEnv)(player, action) = env(DynamicStyle(env), player, action)

function (env::OpenSpielEnv)(::Sequential, player, action)
    if get_current_player(env) == player
        apply_action(env.state, action)
    else
        apply_action(env.state, OpenSpiel.INVALID_ACTION[])
    end
    is_chance_agent_required(env) || _sample_external_events!(env.rng, env.state)
end

(env::OpenSpielEnv)(::Simultaneous, player, action) =
    @error "Simultaneous environments can not take in the actions from players seperately"

RLBase.observe(env::OpenSpielEnv{O,D,S}, player) where {O,D,S} =
    OpenSpielObs{O,D,S}(env.state, player)

RLBase.get_action_space(env::OpenSpielEnv) =
    DiscreteSpace(0:num_distinct_actions(env.game)-1)

function RLBase.get_observation_space(env::OpenSpielEnv{:information})
    s = information_state_tensor_size(env.game)
    MultiContinuousSpace(fill(typemin(Float64), s...), fill(typemax(Float64), s...))
end

function RLBase.get_observation_space(env::OpenSpielEnv{:observation})
    s = observation_tensor_size(env.game)
    MultiContinuousSpace(fill(typemin(Float64), s...), fill(typemax(Float64), s...))
end

RLBase.get_current_player(env::OpenSpielEnv) = current_player(env.state)
RLBase.get_chance_player(env::OpenSpielEnv) = convert(Int, OpenSpiel.CHANCE_PLAYER)
RLBase.get_players(env::OpenSpielEnv) = 0:(num_players(env.game)-1)

Random.seed!(env::OpenSpielEnv, seed) = Random.seed!(env.rng, seed)

RLBase.ActionStyle(::OpenSpielObs) = FULL_ACTION_SET

RLBase.get_legal_actions(obs::OpenSpielObs) = legal_actions(obs.state, obs.player)

RLBase.get_legal_actions_mask(obs::OpenSpielObs) = convert(Vector{Bool}, legal_actions_mask(obs.state, obs.player))

RLBase.get_terminal(obs::OpenSpielObs) = OpenSpiel.is_terminal(obs.state)

RLBase.get_reward(obs::OpenSpielObs) = player_reward(obs.state, obs.player)
RLBase.get_reward(env::OpenSpielEnv) = rewards(env.state)

function RLBase.get_state(obs::OpenSpielObs{:information})
    if obs.player >=0
        information_state_tensor(obs.state, obs.player)
    else
        # OpenSpiel doesn't allow getting information for chance nodes
        nothing
    end
end

function RLBase.get_state_str(obs::OpenSpielObs{:information})
    if obs.player >=0
        information_state_string(obs.state, obs.player)
    else
        # OpenSpiel doesn't allow getting information for chance nodes
        ""
    end
end

RLBase.get_state(obs::OpenSpielObs{:observation}) =
    observation_tensor(obs.state, obs.player)

RLBase.get_state_str(obs::OpenSpielObs{:observation}) =
    observation_string(obs.state, obs.player)

RLBase.get_env_state(obs::OpenSpielObs) = obs.state
RLBase.get_chance_outcome(obs::OpenSpielObs) = chance_outcomes(obs.state)
RLBase.get_history(obs::OpenSpielObs) = history(obs.state)
RLBase.get_history(obs::OpenSpielObs) = history(obs.state)
RLBase.get_history(env::OpenSpielEnv) = history(env.state)
