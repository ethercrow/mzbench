[ {make_install, [
    {git, {var, "mzbench_repo"}},
    {branch, {var, "worker_branch"}},
    {dir, "workers/exec"}]},
  {pool, [{size, 3},
           {worker_type, exec_worker}],
        [{declare_metric, "some.external.metric", counter},
         {loop, [{time, {20, sec}},
                 {rate, {1, rps}}],
            [{execute, "python -c 'print \"some.external.metric,counter,8,7\"'"}]}]}
].