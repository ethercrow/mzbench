[ % shell command execution example, trying to execute "sleep" and "buy milk" commands in two threads
    {make_install, [
        {git, "file:///Users/divanov/src/mzbench"}, 
        {branch, "exec_worker_metrics"},
        {dir, "workers/exec"}]},
    {pool, [{size, 2},
           {worker_type, exec_worker}],
        [{declare_metric, "external.stuff", counter},
         {loop, [{time, {20, sec}},
                 {rate, {1, rps}}],
            [{execute, "/Users/divanov/bin/megaworker.py"}]}]},
    {pool, [{size, 2}, % second pool starts simultaneously with the same rate and duration
            {worker_type, exec_worker}],
        [{loop, [{time, {20, sec}},
                 {rate, {1, rps}}],
            % unknown shell command (won't break execution)
            [{execute, "buy milk"}]}]}
].
