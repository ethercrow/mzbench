[ {make_install,
    [{git, "git://github.com/ethercrow/mzbench"},
     {branch, exec_worker_metrics},
     {dir, "workers/exec"}]},
  {pool, [{size, 3},
           {worker_type, exec_worker}],
        [{declare_metric, "some.external.metric", counter},
         {loop, [{time, {20, sec}},
                 {rate, {1, rps}}],
            [{execute, "python <<< 'print \"some.external.metric,counter,8,7\"'"}]}]}
].