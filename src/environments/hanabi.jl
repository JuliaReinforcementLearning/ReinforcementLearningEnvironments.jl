using Hanabi

export HanabiEnv

@enum HANABI_OBSERVATION_ENCODER_TYPE CANONICAL
@enum COLOR R Y G W B
@enum HANABI_END_OF_GAME_TYPE NOT_FINISHED OUT_OF_LIFE_TOKENS OUT_OF_CARDS COMPLETED_FIREWORKS
@enum HANABI_MOVE_TYPE INVALID PLAY DISCARD REVEAL_COLOR REVEAL_RANK DEAL

const CHANCE_PLAYER_ID = -1

###
### moves
###

abstract type AbstractMove end

struct PlayCard <: AbstractMove
    card_idx::Int
end

function convert(Base.RefValue{Hanabi.LibHanabi.PyHanabiMove}, move::PlayCard)
    move = Ref{HanabiMove}()
    get_play_move(env.card_idx, move)
    move
end

struct DiscardCard <: AbstractMove
    card_idx::Int
end

function convert(Base.RefValue{Hanabi.LibHanabi.PyHanabiMove}, move::DiscardCard)
    move = Ref{HanabiMove}()
    get_discard_move(env.card_idx, move)
    move
end

struct RevealColor <: AbstractMove
    target_offset::Int
    color::Int
end

RevealColor(target_offset::Int, color::COLOR) = RevealColor(target_offset, Int(color))

function convert(Base.RefValue{Hanabi.LibHanabi.PyHanabiMove}, move::RevealColor)
    move = Ref{HanabiMove}()
    get_reveal_color_move(move.target_offset, move.color, move)
    move
end

struct RevealRank <: AbstractMove
    target_offset::Int
    rank::Int
end

function convert(Base.RefValue{Hanabi.LibHanabi.PyHanabiMove}, move::RevealRank)
    move = Ref{HanabiMove}()
    get_reveal_rank_move(move.target_offset, move.rank, move)
    move
end

function convert(AbstractMove, move::Base.RefValue{Hanabi.LibHanabi.PyHanabiMove})
    move_t = move_type(move)
    if move_t == PLAY
        PlayCard(card_index(move))
    elseif move_t == DISCARD
        DiscardCard(card_index(move))
    elseif move_t == REVEAL_COLOR
        RevealColor(target_offset(move), move_color(move))
    elseif move_t == REVEAL_RANK
        RevealRank(target_offset(move), move_rank(move))
    else
        error("unsupported move type: $move_t")
    end
end

"""
    HanabiEnv(;kw...)

Default game params:

random_start_player    = false,
seed                   = -1,
max_life_tokens        = 3,
hand_size              = 5,
max_information_tokens = 8,
ranks                  = 5,
colors                 = 5,
observation_type       = 1,
players                = 2
"""
mutable struct HanabiEnv
    game::Base.RefValue{Hanabi.LibHanabi.PyHanabiGame}
    state::Base.RefValue{Hanabi.LibHanabi.PyHanabiState}
    observation_encoder::Base.RefValue{Hanabi.LibHanabi.PyHanabiObservationEncoder}
    # observation_space::MultiDiscreteSpace{Int64, 1}
    # action_space::DiscreteSpace{Int64}
    reward::Dict{Int32, Int32}

    function HanabiEnv(;kw...)
        game = Ref{HanabiGame}()

        if length(kw) == 0
            new_default_game(game)
        else
            params = map(string, Iterators.flatten(kw))
            new_game(game, length(params), params)
        end

        state = Ref{HanabiState}()
        new_state(game, state)

        observation_encoder = Ref{HanabiObservationEncoder}()
        new_observation_encoder(observation_encoder, game, CANONICAL)
        observation_length = unsafe_string(observation_shape(observation_encoder))
        # observation_space = MultiDiscreteSpace(ones(Int, observation_length), zeros(Int, observation_length))

        # action_space = DiscreteSpace(Int(max_moves(game)) - 1, 0)  # start from 0

        # new(game, state, observation_encoder, observation_space, action_space, Dict{Int32, Int32}())
        new(game, state, observation_encoder, Dict{Int32, Int32}())
    end
end

# observation_space(env::HanabiEnv) = env.observation_space
# action_space(env::HanabiEnv) = env.action_space

function Base.show(io::IO, env::HanabiEnv)
    params = unsafe_string(game_param_string(env.game))
    state = unsafe_string(state_to_string(env.state))
    line_sep = repeat("=", 50)
    println(io, "[HanabiEnv]")
    println(io, line_sep)
    println(io, "[Params]")
    print(io, params)
    println(io, line_sep)
    println(io, "[State]")
    print(io, state)
end

function reset!(env::HanabiEnv)
    state = Ref{HanabiState}()
    new_state(env.game, state)
    env.state = state
    nothing
end

function interact!(env::HanabiEnv, action::Int)
    move = Ref{HanabiMove}()
    get_move_by_uid(env.game, action, move)
    _apply_move(env, move)
    nothing
end

function interact!(env::HanabiEnv, action::AbstractMove)
    move = convert(Base.RefValue{Hanabi.LibHanabi.PyHanabiMove}, action)
    _apply_move(env, move)
    nothing
end

function _apply_move(env::HanabiEnv, move)
    move_is_legal(env.state, move) || error("illegal move $(unsafe_string(move_to_string(move)))")
    player, old_score = state_cur_player(env.state), state_score(env.state)
    state_apply_move(env.state, move)
    while state_cur_player(env.state) == CHANCE_PLAYER_ID
        state_deal_random_card(env.state)
    end
    new_score = state_score(env.state)
    env.reward = Dict(player, new_score - old_score)
end

function observe(env::HanabiEnv; observer)
    observation = Ref{HanabiObservation}()
    new_observation(env.state, observer, observation)
    (observation = _encode_observation(observation, env.observation_encoder),
     reward      = get(env.reward, observer, zero(Int32)),
     isdone      = state_end_of_game_status(env.state) != NOT_FINISHED)
end

_encode_observation(observation, encoder) = [parse(Int, x) for x in split(unsafe_string(encode_observation(encoder, observation)), ',')]

function observe(env::HanabiEnv)
    n_players = num_players(env.game)
    observations = []
    for pid in 0:n_players-1
        observation = Ref{HanabiObservation}()
        new_observation(env.state, pid, observation)
        obs_dict = obs_to_dict(env, observation)
        push!(observations, obs_dict)
    end

    Dict(
        "current_player": state_cur_player(env.state),
        "observations": observations
    )
end

function obs_to_dict(env::HanabiEnv, obs)
    Dict(
        "current_player"        => state_cur_player(env.state),
        "current_player_offset" => obs_cur_player_offset(obs),
        "life_tokens"           => obs_life_tokens(obs),
        "information_tokens"    => obs_information_tokens(obs),
        "num_players"           => obs_num_players(obs),
        "deck_size"             => obs_deck_size(obs),
        "fireworks"             => Dict(c => observation_fireworks(obs, c) for c in instances(COLOR)),
        "legal_moves"           => [convert(AbstractMove, x) for x in legal_moves(obs)],
        "legal_moves_as_int"    => [get_move_uid(env.game, move) for move in legal_moves(observation)],
        "observed_hands"        => [begin
                                        card_ref = Ref{HanabiCard}()
                                        obs_get_hand_card(observation, pid, i, card_ref)
                                        card_ref[]
                                    end
                                    for i in 0:obs_get_hand_size(observation, pid)-1],
        "discard_pile"          => [begin
                                        card_ref = Ref{HanabiCard}()
                                        obs_get_discard(obs, i, card_ref)
                                        card_ref[]
                                    end
                                    for i in 0:obs_discard_pile_size(obs)-1],
        "card_knowledge"        => [[begin
                                        kd = Ref{HanabiCardKnowledge}()
                                        obs_get_hand_card_knowledge(obs, pid, i, kd)
                                        Dict(
                                            "color" => color_was_hinted(kd) ? COLOR(known_color(kd)) : nothing,
                                            "rank"  => rank_was_hinted(kd) ? known_rank(kd) : nothing)
                                     end
                                     for i in 0:obs_get_hand_size(obs, pid) - 1]
                                    for pid in 0:obs_num_players(obs)-1],
        "vectorized"            => _encode_observation(obs, env.observation_encoder),
        "observation"           => obs,
        "observation_string"    => unsafe_string(obs_to_string(observation))
    )
end