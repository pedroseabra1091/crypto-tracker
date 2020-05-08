defmodule CryptoTracker.CoinData do
  def fetch(coin_name) do
    coin_name
    |> assets_endpoint()
    |> HTTPoison.get!()
    |> Map.fetch!(:body)
    |> Jason.decode!
    |> parse
  end

  defp parse(%{"data" => %{"priceUsd" => price_usd}}), do: {:ok, String.to_float(price_usd)}

  defp parse(%{"error" => error}), do: {:error, error}

  defp assets_endpoint(coin), do: "https://api.coincap.io/v2/assets/" <> coin
end