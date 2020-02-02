module ReinforcementLearningEnvironments

export RLEnvs
const RLEnvs = ReinforcementLearningEnvironments

using Reexport
using Requires
@reexport using ReinforcementLearningBase
using ReinforcementLearningCore

# built-in environments
include("environments/classic_control/classic_control.jl")

# dynamic loading environments
function __init__()
    @require ArcadeLearningEnvironment = "b7f77d8d-088d-5e02-8ac0-89aab2acc977" include("environments/atari.jl")
    @require PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0" include("environments/gym.jl")
end

end # module
