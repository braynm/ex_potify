defmodule ExPotifyWeb.Utils.TrackDurationFormatter do
  @moduledoc """
  Converts track duration from milliseconds to human-readable format e.g.(3:31)

  Example usage:
    iex> TrackDurationFormatter.format(30000)
    iex> "5:30"
  """

  @spec format(integer) :: String.t()
  def format(duration_ms) do
    minutes = trunc(:math.floor(duration_ms / 60000))
    seconds = trunc(rem(duration_ms, 60000) / 1000)
    "#{minutes}:#{seconds_display(seconds)}#{seconds}"
  end

  defp seconds_display(second) when second < 10, do: "0"
  defp seconds_display(_second), do: ""
end
