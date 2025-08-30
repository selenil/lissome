defmodule LissomeFFI do
  def erlang_version, do: List.to_string(:erlang.system_info(:system_version))

  def atoms_count, do: :erlang.system_info(:atom_count)

  def ports_count, do: :erlang.system_info(:port_count)

  def processes_count, do: :erlang.system_info(:port_count)

  def uptime, do:
   round(elem(:erlang.statistics(:wall_clock), 0) / 60)

  def total_memory_usage, do: :erlang.memory()[:total]
end
