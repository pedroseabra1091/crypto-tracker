defmodule CryptoTracker do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: CryptoTracker.PortfolioManager,
        start: {CryptoTracker.PortfolioManager, :prepare, []}
      }
    ]
    # Supervisor strategies:
    # - :one_for_one - if a child process terminates, only that process is restarted
    # - :one_for_all - if a child process terminates, all other child processes are terminated and then all
    # child processes are restarted
    # - :rest_for_one - if a child process terminates, the terminated child process and the rest of the children
    # started after it, are terminated and restarted
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
