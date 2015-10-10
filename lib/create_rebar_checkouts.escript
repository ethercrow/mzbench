#!/usr/bin/env escript

get_repos_and_refs_from_rebar_lock() ->
    case filelib:is_file("rebar.lock") of
        true ->
            {ok, [Deps]} = file:consult("rebar.lock"),
            Result = lists:filtermap(
                fun({Name, {git, Repo, {ref, Ref}}, _}) ->
                    {true, {binary_to_list(Name), Repo, {ref, Ref}}};
                   (_) -> false
                end,
                proplists:delete(<<"jiffy">>, Deps)),
            Result;
        false -> []
    end.

get_repos_and_refs_from_rebar_config() ->
    case filelib:is_file("rebar.config") of
        false ->
            {ok, Cwd} = file:get_cwd(),
            io:format("There's no rebar.config in ~p", [Cwd]),
            halt(1);
        _ -> ok
    end,
    {ok, RebarConfig} = file:consult("rebar.config"),
    Deps = proplists:get_value(deps, RebarConfig),
    Result = lists:filtermap(
        fun({Name, {git, Repo, {tag, Tag}}}) -> {true, {atom_to_list(Name), Repo, {tag, Tag}}};
           ({Name, {git, Repo, {ref, Ref}}}) -> {true, {atom_to_list(Name), Repo, {ref, Ref}}};
           ({Name, _, {git, Repo, {tag, Tag}}}) -> {true, {atom_to_list(Name), Repo, {tag, Tag}}};
           ({Name, _, {git, Repo, {ref, Ref}}}) -> {true, {atom_to_list(Name), Repo, {ref, Ref}}};
           (_) -> false
        end,
        proplists:delete(jiffy, Deps)),
    Result. 

main(_) ->
    case os:find_executable("parallel") of
        false ->
            io:format("GNU parallel is unavailable"),
            halt(2);
        _ -> ok
    end,
    GitReposAndTags =
        lists:usort(
            fun({Name1, _, _}, {Name2, _, _}) -> Name1 == Name2 end,
            get_repos_and_refs_from_rebar_lock() ++ get_repos_and_refs_from_rebar_config()),
    filelib:ensure_dir("_checkouts/"),
    file:set_cwd("_checkouts"),
    CloneCommands =
        lists:map(
            fun({Name, Repo, {tag, Tag}}) ->
                "git clone --single-branch --branch " ++ Tag ++ " " ++ Repo ++ " " ++ Name;
               ({Name, Repo, {ref, Ref}}) ->
                "git clone " ++ Repo ++ " " ++ Name ++ " && cd " ++ Name ++ " && git checkout " ++ Ref 
            end,
            GitReposAndTags),
    Cmd = "parallel -j8 --arg-sep ,, ,, " ++
        string:join(
            lists:map(
                fun(S) ->
                    [$"] ++ S ++ [$"]
                end,
                CloneCommands),
            " "),
    io:format("~s~n", [os:cmd(Cmd)]).