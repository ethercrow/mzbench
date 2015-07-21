-module(exec_worker).

-export([
    initial_state/0,
    declare_metric/4,
    metrics/1,
    execute/3
]).

-include_lib("../../common_apps/mzbench_language/include/mzbl_types.hrl").

initial_state() -> "".

metrics(Script) ->
    lager:info("exec_worker:script(~p)", [Script]),
    [{Name, Type} || #operation{name = declare_metric, args = [Name, Type]} <- Script]
        ++ [
         {"success", counter},
         {"fail", counter},
         {"latency_us", histogram}
        ].

execute(State, _Meta, Command) ->
    lager:info("Executing ~p...~n", [Command]),
    TimeStart = os:timestamp(),
    case run(Command, []) of
        0 -> 
            mzb_metrics:notify("success", 1);
        ExitCode ->
            mzb_metrics:notify("fail", 1),
            lager:error("Execution failed~nCommand: ~p~nExit Code: ~p~n", [Command, ExitCode])
    end,
    TimeFinish = os:timestamp(),
    mzb_metrics:notify({"latency_us", histogram}, timer:now_diff(TimeFinish, TimeStart)),
    {nil, State}.

run(Command, Opts) ->
    Port = open_port({spawn, Command}, [eof, exit_status, {line, 255} | Opts]),
    Loop = fun Loop() ->
        receive
            {Port, {data, {eol, Data}}} ->
                parse_and_report_metric_values(Data),
                Loop();
            {Port, {data, {noeol, Data}}} ->
                parse_and_report_metric_values(Data),
                Loop();
            {Port, eof} ->
                Port ! {self(), close},
                Loop();
            stop ->
                Port ! {self(), close},
                Loop();
            {Port, closed} ->
                receive
                    {Port, {exit_status, Code}} -> Code
                end
        end end,
    Loop().

parse_and_report_metric_values(Data) ->
     try
         [Name, Type | Values] = string:tokens(Data, ","),
         _ = [mzb_metrics:notify({Name, list_to_atom(Type)}, string_to_number(Value)) || Value <- Values]
     catch C:E ->
         lager:error("Error while parsing metric info from exec worker: ~p:~p", [C, E])
     end.

string_to_number(S) ->
    case string:to_float(S) of
        {F, []} -> F;
        {error, no_float} -> list_to_integer(S)
    end.

declare_metric(State, _Meta, _Name, _Type) ->
    {nil, State}.