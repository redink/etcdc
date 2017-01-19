-module(etcdc_keys).

-export([get/1, get/2, set/2, set/3, del/1, del/2]).

%% ----------------------------------------------------------------------------

-type get_opt() :: recursive
                 | consistent
                 | sorted
                 | stream
                 | wait
                 | {waitIndex, integer()}.
-type set_opt() :: dir
                 | prevExist
                 | sequence
                 | {prevValue, term()}
                 | {prevIndex, term()}
                 | {ttl, term()}
                 | {ttl_renew, term()}.

-type del_opt() :: dir
                 | prevExist
                 | {prevValue, term()}
                 | {prevIndex, term()}.

%% ----------------------------------------------------------------------------

-spec get(string()) -> {ok, #{}} | {error, #{}}.
get(Path) ->
    get(Path, []).

-spec get(string(), [get_opt()]) -> {ok, #{}} | {error, #{}}.
get(Path, Opts) when is_binary(Path) ->
    get(binary_to_list(Path), Opts);
get(Path, Opts) ->
    FullPath = "/v2/keys" ++ etcdc_lib:ensure_first_slash(Path),
    etcdc_lib:call(get, FullPath, Opts).

-spec set(string(), iolist()) -> {ok, #{}} | {error, #{}}.
set(Path, Value) ->
    set(Path, Value, []).

-spec set(string(), iolist(), [set_opt()]) -> {ok, #{}} | {error, #{}}.
set(Path, Value, Opts) when is_binary(Path) ->
    set(binary_to_list(Path), Value, Opts);
set(Path, Value, Opts) ->
    FullPath = "/v2/keys" ++ etcdc_lib:ensure_first_slash(Path),
    FullOpts = [{value, Value} | Opts],
    IsSequence = proplists:get_bool(sequence, FullOpts),
    Method = case IsSequence of true -> post; false -> put end,
    etcdc_lib:call(Method, FullPath, FullOpts).

-spec del(string()) -> {ok, #{}} | {error, #{}}.
del(Path) ->
    del(Path, []).

-spec del(string(), [del_opt()]) -> {ok, #{}} | {error, #{}}.
del(Path, Opts) ->
    NewPath = "/v2/keys" ++ etcdc_lib:ensure_first_slash(Path),
    etcdc_lib:call(delete, NewPath, Opts).
