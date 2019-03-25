using Hanabi

export HanabiEnv

@enum HANABI_OBSERVATION_ENCODER_TYPE CANONICAL
@enum COLOR R Y G W B

const CHANCE_PLAYER_ID = -1

abstract type AbstractMove end

struct PlayCard <: AbstractMove
    card_idx::Int
end

function to_hanabi_move(move::PlayCard)
    move = Ref{HanabiMove}()
    get_play_move(env.card_idx, move)
    move
end

struct DiscardCard <: AbstractMove
    card_idx::Int
end

function to_hanabi_move(move::DiscardCard)
    move = Ref{HanabiMove}()
    get_discard_move(env.card_idx, move)
    move
end

struct RevealColor <: AbstractMove
    target_offset::Int
    color::Int
end

RevealColor(target_offset::Int, color::COLOR) = RevealColor(target_offset, Int(color))

function to_hanabi_move(move::RevealColor)
    move = Ref{HanabiMove}()
    get_reveal_color_move(move.target_offset, move.color, move)
    move
end

struct RevealRank <: AbstractMove
    target_offset::Int
    rank::Int
end

function to_hanabi_move(move::RevealRank)
    move = Ref{HanabiMove}()
    get_reveal_rank_move(move.target_offset, move.rank, move)
    move
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

        new(game, state, observation_encoder, Dict{Int32, Int32}())
    end
end

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
    new_state(game, state)
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
    move = to_hanabi_move(action)
    _apply_move(env, move)
    nothing
end

function _apply_move(env::HanabiEnv, move)
    move_is_legal(env.state, move) || error("illegal move $(unsafe_string(move_to_string(move)))")
    player, old_score = state_cur_player(env.state), state_score(env.state)
    state_apply_move(env.state, move)
    while state_cur_player(env.state) == CHANCE_PLAYER_ID :
        self.state.deal_random_card()
    end
    new_score = state_score(env.state)
    env.reward = Dict(player, new_score - old_score)
end