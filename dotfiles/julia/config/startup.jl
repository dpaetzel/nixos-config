try
    using Revise
catch e
    @warn "Error initializing Revise" exception = (e, catch_backtrace())
end

try
    using Infiltrator
catch e
    @warn "Error initializing Infiltrator" exception = (e, catch_backtrace())
end


# https://kristofferc.github.io/OhMyREPL.jl/latest/installation/#Installation
atreplinit() do repl
    try
        @eval using OhMyREPL
        @eval OhMyREPL.output_prompt!("> ", :red)

        # https://discourse.julialang.org/t/julia-and-kitty-terminal-integration/95368
        @eval const iskitty = ENV["TERM"] == "xterm-kitty"
        @eval OhMyREPL.input_prompt!(:green) do
            iskitty && print("\e]133;A\e\\")
            return "julia> "
        end
        @eval OhMyREPL.output_prompt!(:red) do
            iskitty && print("\e]133;C\e\\")
            return ""
        end
    catch e
        @warn "error while importing OhMyREPL" e
    end

    # I'm sometimes not careful with my Ctrl-D and don't want to recompile many
    # things all too often.
    repl.options.confirm_exit = true
end
