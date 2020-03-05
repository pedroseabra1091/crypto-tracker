defmodule GenCryptoFetcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @portfolio ["bitcoin", "bitcoin-cash", "ethereum", "litecoin", "ethereum-classic"]

  def start(_type, _args) do
    children = [
      %{
        id: GenCryptoFetcher.PortfolioWorker,
        start: {GenCryptoFetcher.PortfolioWorker, :start_link, [@portfolio]}
      }
    ]
    # Supervisor strategies:
    # - :one_for_one - if a child process terminates, only that process is restarted
    # - :one_for_all - if a child process terminates, all other child processes are terminated and then all
    # child processesare restarted
    # - :rest_for_one - if a child process terminates, the terminated child process and the rest of the children
    # started after it, are terminated and restarted
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
