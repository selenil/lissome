-module(lissome_ffi).
-export([
  erlang_version/0,
  atoms_count/0,
  ports_count/0,
  processes_count/0,
  uptime/0,
  total_memory_usage/0
]).

erlang_version() ->
  unicode:characters_to_binary(erlang:system_info(system_version)).

atoms_count() ->
  erlang:system_info(atom_count).

ports_count() ->
  erlang:system_info(port_count).

processes_count() ->
  erlang:system_info(process_count).

uptime() ->
  Uptime = erlang:statistics(wall_clock),
  erlang:element(1, Uptime).

total_memory_usage() ->
  {total, TotalMemory} = lists:keyfind(total, 1, erlang:memory()),
  TotalMemory.
