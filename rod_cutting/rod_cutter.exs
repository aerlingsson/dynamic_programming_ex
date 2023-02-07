defmodule RodCutter do
  @prices %{
    1 => 1,
    2 => 5,
    3 => 8,
    4 => 9,
    5 => 10,
    6 => 17,
    7 => 17,
    8 => 20,
    9 => 22,
    10 => 26,
    11 => 27,
    12 => 30,
    13 => 32,
    14 => 35,
    15 => 38,
    16 => 41,
    17 => 43,
    18 => 48,
    19 => 49,
    20 => 51
  }

  # _   _       _
  #| \ | |     (_)
  #|  \| | __ _ ___   _____
  #| . ` |/ _` | \ \ / / _ \
  #| |\  | (_| | |\ V /  __/
  #|_| \_|\__,_|_| \_/ \___|

  @doc """
  Naive implementation that always recalculates all intermediate results

  iex(1)> RodCutter.cut_rod_naive(20)
  "Input: 20, result: 56, time: 118000 µs"
  """
  def cut_rod_naive(n) do
    {time, res} = :timer.tc(&do_cut_rod_naive/1, [n])
    "Input: #{n}, result: #{res}, time: #{time} µs"
  end

  defp do_cut_rod_naive(0), do: 0

  defp do_cut_rod_naive(n) do
    Enum.reduce(1..n, -1, fn m, best ->
      max(best, @prices[m] + do_cut_rod_naive(n-m))
    end)
  end

  # _______                _
  #|__   __|              | |
  #   | | ___  _ __     __| | _____      ___ __
  #   | |/ _ \| '_ \   / _` |/ _ \ \ /\ / / '_ \
  #   | | (_) | |_) | | (_| | (_) \ V  V /| | | |
  #   |_|\___/| .__/   \__,_|\___/ \_/\_/ |_| |_|
  #           | |
  #           |_|

  @doc """
  Dynamic programming implementation that recursively calculates the best price for each length
  and memoizes each result.
  Has O(n^2) running time.

  iex(2)> RodCutter.cut_rod_td(20)
  "Input: 20, result: 56, time: 55 µs"
  """
  def cut_rod_td(n) do
    {time, {res, _memo}} = :timer.tc(&do_cut_rod_td/1, [n])
    "Input: #{n}, result: #{res}, time: #{time} µs"
  end

  defp do_cut_rod_td(n, memo \\ %{})

  defp do_cut_rod_td(0, memo), do: {0, memo}

  defp do_cut_rod_td(n, memo) do
    Enum.reduce(1..n, {-1, memo}, fn m, {best, memo} ->
      {sub_cut, memo} =
        case Map.has_key?(memo, n-m) do
          true -> {memo[n-m], memo}
          false ->
            {sub_cut, memo} = do_cut_rod_td(n-m, memo)
            {sub_cut, Map.put_new(memo, n-m, sub_cut)}
        end

        {max(best, @prices[m] + sub_cut), memo}
    end)
  end

  # ____        _   _
  #|  _ \      | | | |
  #| |_) | ___ | |_| |_ ___  _ __ ___    _   _ _ __
  #|  _ < / _ \| __| __/ _ \| '_ ` _ \  | | | | '_ \
  #| |_) | (_) | |_| || (_) | | | | | | | |_| | |_) |
  #|____/ \___/ \__|\__\___/|_| |_| |_|  \__,_| .__/
  #                                           | |
  #                                           |_|

  @doc """
  Dynamic programming implementation that first calculates the best price for each length up to n
  and stores each calculation in a map.
  Then looks up the best price for n.
  Has O(n^2) running time.

  If you were to run this once for all keys in @prices and store the result in e.g. a dets file,
  this would be the most optimal implementation; calculate once and then simply lookup any n.

  iex(16)> RodCutter.cut_rod_bu(20)
  "Input: 20, result: 56, time: 62 µs"
  """
  def cut_rod_bu(n) do
    {time, res} = :timer.tc(&do_cut_rod_bu/1, [n])
    "Input: #{n}, result: #{res}, time: #{time} µs"
  end

  defp do_cut_rod_bu(n) do
    memo =
      Enum.reduce(1..n, %{0 => 0}, fn m, memo ->
        best =
          Enum.reduce(1..m, -1, fn o, best ->
            max(best, @prices[o] + memo[m - o])
          end)
        Map.put_new(memo, m, best)
      end)

    memo[n]
  end
end
