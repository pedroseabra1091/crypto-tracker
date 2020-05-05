defmodule CryptoTracker.PortfolioManager do
  use GenServer

  @request_interval 5000

  @profit_taking_change 0.05
  @withdraw_change -0.04
  @place_position_change -0.00001

  alias CryptoTracker.{Coin, CoinTracker}

  require IEx

  def prepare(portfolio \\ []), do: GenServer.start_link(__MODULE__, portfolio)

  def init(portfolio) do
    create(self(), %Coin{name: "ethereum", symbol: "ETH", position_price: 100, position_size: 10})
    create(self(), %Coin{name: "ethereum-classic", symbol: "ETC", position_price: nil})
    track(self())
    {:ok, portfolio}
  end

  def track(pid) do
    schedule_portfolio_fetch(pid)
    schedule_portfolio_tracker_reset(pid)
  end

  def create(pid, coin) do
    GenServer.cast(pid, {:create, coin})
  end

  def show(pid) do
    GenServer.call(pid, {:show})
  end

  def delete(pid, coin) do
    GenServer.call(pid, {:delete, coin})
  end

  def handle_cast({:create, coin}, portfolio) do
    {:ok, current_market_value} = track_coin(coin.name)
    new_coin = %Coin{coin | market_value: current_market_value}

    IO.puts("==== Portfolio ====")
    IO.inspect(new_coin)
    {:noreply, portfolio ++ [new_coin]}
  end

  def handle_call({:show}, _from, portfolio) do
    {:reply, portfolio, portfolio}
  end

  def handle_call({:delete, coin}, _from, portfolio) do
    update_porfolio = List.delete(portfolio, coin)
    {:reply, update_porfolio, update_porfolio}
  end

  def handle_info(:fetch_portfolio, portfolio) do
    Enum.each(portfolio, &track_and_log/1)

    schedule_portfolio_fetch(self())
    {:noreply, portfolio}
  end

  def track_and_log(coin) do
    case track_coin(coin.name) do
      {:ok, current_market_value} ->
        current_market_value
        |> calculate_change(coin)
        |> Float.round(3)
        |> log_or_notify(coin)
      {:error, error} ->
        error
    end
  end

  def track_coin(coin_name) do
    {:ok, pid} = CoinTracker.prepare
    CoinTracker.track(pid, coin_name)
  end

  defp calculate_change(current_market_value, %Coin{position_price: nil, market_value: market_value}) do
    ((current_market_value - market_value) / market_value)
  end

  defp calculate_change(current_market_value, %Coin{position_price: position_price}) do
    ((current_market_value - position_price) / position_price)
  end

  defp log_or_notify(change, %Coin{position_price: nil} = coin) when change <= @place_position_change do
    push_notification( "#{coin.symbol} 📉", "Change: #{change * 100}%", "Open a position?")
  end

  defp log_or_notify(change, coin) when change <= @withdraw_change or change >= @profit_taking_change  do
    push_notification("#{coin.symbol} 🚀", "Change: #{change * 100}%", "Position profit: #{profit(change, coin)}$")
  end

  defp log_or_notify(change, coin) do
    IO.puts("#{coin.symbol} latest market value: #{coin.market_value * (1 + change)}$")
  end

  def push_notification(title, subtitle, message) do
    opts = ["-title", title, "-subtitle", subtitle, "-message", message, "-open", "https://www.coinbase.com/", "-sound", "default"]
    Rambo.run("terminal-notifier", opts)
  end

  defp profit(change, coin) do
    ((coin.position_price * (1 + change)) * coin.position_size) |> Float.round(3)
  end

  def schedule_portfolio_fetch(pid), do: Process.send_after(pid, :fetch_portfolio, @request_interval)

  def schedule_portfolio_tracker_reset(pid), do: Process.send_after(pid, :track_reset, 24 * 60 * 60 * 1000)
end