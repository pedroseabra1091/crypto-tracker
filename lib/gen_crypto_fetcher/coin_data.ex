defmodule GenCryptoFetcher.CoinData do
  alias GenCryptoFetcher.CurrencyExchange

  def fetch(coin) do
    coin
    |> assets_endpoint()
    |> HTTPoison.get!()
    |> Map.fetch!(:body)
    |> Jason.decode!
    |> parse
  end

  defp parse(%{"data" => data}) do
    %{
      asset: data["symbol"],
      price_eur: String.to_float(data["priceUsd"]) |> CurrencyExchange.exchange(:usd, :eur),
      change_percent_24hr: String.to_float(data["changePercent24Hr"]) |> CurrencyExchange.exchange(:usd, :eur)
    }
  end

  defp parse(%{"error" => error}), do: IO.puts error

  defp assets_endpoint(coin), do: "https://api.coincap.io/v2/assets/" <> coin
end