defmodule ChercheVille.Web do
  use Plug.Router
  import Plug.Conn
  alias ChercheVille.Search

  plug :match
  plug :dispatch

  get "/cities" do
    conn = fetch_query_params(conn)
    case conn.params do
      %{"q" => q} ->
        results = Search.text(q)
        resp_data = post_process_results(results)
        resp_body = Jason.encode!(resp_data)
        send_resp(conn, 200, resp_body)
      _ ->
        send_resp(conn, 400, "Bad request: missing query string parameter `q`")
    end
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
      :admin1_name
    ])
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
