defmodule ChercheVille.Web do
  @moduledoc """
  Expose search functionalities as a web service.
  """
  use Plug.Router
  import Plug.Conn
  alias ChercheVille.Search

  plug :match
  plug :dispatch

  get "/cities" do
    conn = fetch_query_params(conn)

    case conn.params do
      %{"q" => ""} ->
        send_resp(conn, 400, "Bad request: empty query string parameter `q`.")

      %{"q" => q} ->
        results = Search.text(q)
        resp_data = post_process_results(results)
        send_json(conn, resp_data)

      _ ->
        send_resp(conn, 400, "Bad request: missing query string parameter `q`.")
    end
  end

  get "/cities/nearest" do
    conn = fetch_query_params(conn)

    with %{"lat" => latitude, "lon" => longitude} <- conn.params,
         {latitude, _} <- Float.parse(latitude),
         {longitude, _} <- Float.parse(longitude) do
      results = Search.coordinates(latitude, longitude, country_code: country_code(conn.params))

      resp_data =
        results
        |> post_process_results

      send_json(conn, resp_data)
    else
      _ ->
        send_resp(
          conn,
          400,
          "Bad request: invalid coordinates. Expecting numbers for `lat` and `lon` parameters."
        )
    end
  end

  defp send_json(conn, resp_data, status_code \\ 200) do
    resp_body = Jason.encode!(resp_data)

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status_code, resp_body)
  end

  defp post_process_results(results) do
    results
    |> Enum.map(&extract_keys/1)
  end

  defp extract_keys(city) do
    Map.take(city, [
      :name,
      :latitude,
      :longitude,
      :admin2_code,
      :admin2_name,
      :admin1_name,
      :country_code
    ])
  end

  defp country_code(query_string) do
    default_country_code = Application.get_env(:chercheville, :default_country_code)
    Map.get(query_string, "country_code", default_country_code)
  end

  match _ do
    table_of_contents = %{
      "message" => "Not found",
      "endpoints" => %{
        "cities" => %{
          "url" => "/cities/?q={search_string}",
          "description" =>
            "City search service. Provide search string as a query string parameter `q`."
        },
        "nearest_cities" => %{
          "url" => "/cities/nearest?lat={latitude}&lon={longitude}[&country_code={country_code}]",
          "description" =>
            "Cities located nearest to requested coordinates. Optionally filter by country code."
        }
      }
    }

    send_json(conn, table_of_contents, 404)
  end
end
