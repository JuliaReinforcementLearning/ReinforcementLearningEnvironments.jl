using Hanabi

export HanabiEnv

@enum HANABI_OBSERVATION_ENCODER_TYPE CANONICAL

const COLOR_CHAR = ["R", "Y", "G", "W", "B"]

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
struct HanabiEnv <: AbstractEnv
    game::Base.RefValue{Hanabi.LibHanabi.PyHanabiGame}
    state::Base.RefValue{Hanabi.LibHanabi.PyHanabiState}
    observation_encoder::Base.RefValue{Hanabi.LibHanabi.PyHanabiObservationEncoder}

    function HanabiEnv(;kw...)

        params = map(string, Iterators.flatten(kw))
        game = Ref{HanabiGame}()
        game = new_game(game, length(params), params)

        state = Ref{HanabiState}()
        new_state(game, state)

        observation_encoder = Ref{HanabiObservationEncoder}()
        new_observation_encoder(observation_encoder, game, CANONICAL)

        HanabiEnv(game, state, observation_encoder)
    end
end

function Base.show(io::IO, env::HanabiEnv)
    params = unsafe_string(game_param_string(env.game))
    state = unsafe_string(state_to_string(env.state))
    line_sep = repeat("=", 50)
    println(io, "HanabiEnv:")
    println(io, line_sep)
    println(io, "Params:")
    print(io, params)
    println(io, line_sep)
    println(io, "State:")
    print(io, state)
end