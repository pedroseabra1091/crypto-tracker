defmodule CryptoTracker.CoinTracker do
  use GenServer

  alias CryptoTracker.CoinData

  def prepare, do: GenServer.start_link(__MODULE__, [])

  def init(init_args) do
    {:ok, init_args}
  end

  def track(pid, coin_name), do: GenServer.call(pid, {:track, coin_name})

  def handle_call({:track, coin_name}, _from, state) do
    coin_name
    |> CoinData.fetch
    |> return_response(state)
  end

  def return_response({:ok, current_market_value}, state) do
    {:reply, {:ok, current_market_value}, state}
  end

  def return_response({:error, error}, state), do: {:reply, {:error, error}, state}
end