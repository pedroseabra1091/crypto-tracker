defmodule GenCryptoFetcher.PortfolioWorker do
  use GenServer

  import IEx

  @request_interval 8000

  # Could be shortened by removing 'as'
  alias GenCryptoFetcher.CoinData, as: CoinData

  def start_link(portfolio) do
    GenServer.start_link(__MODULE__, portfolio)
  end

  def init(portfolio) do
    schedule_portfolio_fetch()
    {:ok, portfolio}
  end

  def handle_info(:fetch_portfolio, portfolio) do
    portfolio_data = Enum.map(portfolio, &(CoinData.fetch/1))

    {:ok, pid } = TradeManager.start_link(portfolio_data)
    TradeManager.analyze_possible_deals(pid)

    schedule_portfolio_fetch()
    {:noreply, portfolio}
  end

  def schedule_portfolio_fetch() do
    Process.send_after(self(), :fetch_portfolio, @request_interval)
  end
end