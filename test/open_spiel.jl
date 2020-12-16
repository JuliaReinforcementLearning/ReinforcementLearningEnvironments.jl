@testset "OpenSpielEnv" begin

    for name in [
        "tic_tac_toe",
        "kuhn_poker",
        "goofspiel(imp_info=True,num_cards=4,points_order=descending)",
    ]
        @info "testing OpenSpiel: $name"
        env = OpenSpielEnv(name)
        RLBase.current_player(env)
        action_space(env)

        reset!(env)

        while true
            is_terminated(env) && break
            action = rand(legal_action_space(env))
            env(action)
        end
        @test true
    end
end
