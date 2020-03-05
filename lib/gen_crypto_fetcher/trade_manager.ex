defmodule TradeManager do
  use GenServer

  require IEx

  @desired_variation -1.5

  def start_link(portfolio_data) do
    GenServer.start_link(__MODULE__, portfolio_data)
  end

  def init(portfolio_data) do
    {:ok, portfolio_data}
  end

  def analyze_possible_deals(pid) do
    GenServer.call(pid, :analyze_possible_deals)
  end

  # Handle synchronous messaging
  def handle_call(:analyze_possible_deals, _from, portfolio_data) do
    IO.puts "\n"
    IO.puts "Looking for deals..."

    portfolio_data
    |> Enum.reduce([], fn coin_data, acc -> analyze(coin_data, coin_data[:change_percent_24hr], acc) end)
    |> display_trade_opportunities

    {:reply, [], []}
  end

  defp analyze(coin_data, percentual_change, acc) when percentual_change < @desired_variation, do: acc ++ [coin_data]
  defp analyze(_coin_data, _percentual_change, acc), do: acc

  def display_trade_opportunities([]), do: []
  def display_trade_opportunities(trade_opportunities) do
    IO.puts "Trade Opportunities"
    Enum.map(trade_opportunities, &IO.inspect/1)
  end
end