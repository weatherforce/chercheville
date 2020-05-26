defmodule MyPlugTest do
  use ExUnit.Case
  use Plug.Test
  import TestHelper

  @opts ChercheVille.Web.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, {:shared, self()})
  end

  describe "city search" do

    test "with valid query string" do
      insert_city(123_930_305, "Toulouse")
      # Create a test connection
      conn = conn(:get, "/cities?q=Toulouse")

      # Invoke the plug
      conn = ChercheVille.Web.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200

      response_body = conn.resp_body
      response_data = Jason.decode!(response_body)
      top_result = Enum.at(response_data, 0)
      assert Map.get(top_result, "name") == "Toulouse"
    end

    test "with invalid query string" do
      insert_city(123_930_305, "Toulouse")
      # Create a test connection
      conn = conn(:get, "/cities?foo=42")

      # Invoke the plug
      conn = ChercheVille.Web.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body =~ "missing query string param"
    end

  end
end
