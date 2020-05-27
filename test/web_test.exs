defmodule MyPlugTest do
  use ExUnit.Case
  use Plug.Test
  import TestHelper

  @opts ChercheVille.Web.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, {:shared, self()})
    insert_city(123_930_305, "Toulouse")
    :ok
  end

  describe "text search" do

    test "with valid query string" do
      # Create a test connection
      conn = get("/cities?q=Toulouse")

      # Assert the response and status
      assert conn.status == 200

      response_data = decode_body(conn)
      top_result = Enum.at(response_data, 0)
      assert Map.get(top_result, "name") == "Toulouse"

      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    end

    test "with invalid query string" do
      # Create a test connection
      conn = get("/cities?foo=42")

      # Assert the response and status
      assert conn.status == 400
      assert conn.resp_body =~ "missing query string param"
    end

  end

  describe "not found" do
    test "should return endpoints" do
      conn = get("/")
      response_data = decode_body(conn)
      assert Map.has_key?(response_data["endpoints"]["cities"], "url")
      assert Map.has_key?(response_data["endpoints"]["nearest_cities"], "url")
    end
  end

  describe "nearest search" do

    test "with valid coordinates" do
      conn = get("/cities/nearest?lat=43.1&lon=0.96")

      # Assert the response and status
      assert conn.status == 200

      response_data = decode_body(conn)
      top_result = Enum.at(response_data, 0)
      assert Map.get(top_result, "name") == "Toulouse"
    end

    test "with missing parameter" do
      conn = get("/cities/nearest?lat=43.1")

      # Assert the response and status
      assert conn.status == 400
      assert conn.resp_body =~ "invalid coordinates"
    end

    test "with invalid coordinate" do
      conn = get("/cities/nearest?lat=43.1&lon=foo")

      # Assert the response and status
      assert conn.status == 400
      assert conn.resp_body =~ "invalid coordinates"
    end
  end

  # Helper functions
  defp get(url) do
    # Create a test connection
    conn = conn(:get, url)

    # Invoke the plug
    ChercheVille.Web.call(conn, @opts)
  end

  defp decode_body(conn) do
    conn.resp_body |> Jason.decode!
  end
end
