defmodule SeedDataTest do
  use ExUnit.Case
  import Ecto.Query, only: [from: 2]
  import Mox
  alias ChercheVille.SeedData

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)

    on_exit(fn ->
      File.rm(fetched_file("YY.zip"))
      File.rm(fetched_file("YY.txt"))
    end)

    verify_on_exit!()
  end

  defp source_file(filename) do
    Path.join([Application.get_env(:chercheville, :data_dir), "source", filename])
  end

  defp fetched_file(filename) do
    Path.join([Application.get_env(:chercheville, :data_dir), filename])
  end

  describe "insert data" do
    test "insert data" do
      SeedData.insert_data(["ZZ"])

      verify_inserted_data()
    end

    test "should use local admin1 name" do
      SeedData.insert_data(["ZZ"])

      query = from(c in ChercheVille.City, where: c.name == "Brussels")

      brussels = query |> ChercheVille.Repo.one()
      assert Map.get(brussels, :admin1_name) == "Bruxelles-Capitale"
    end
  end

  test "fetch data" do
    setup_http_mock()

    SeedData.fetch_data(["YY"])

    verify_fetched_file()
  end

  test "import data" do
    setup_http_mock()

    SeedData.import_data(["YY", "ZZ"])

    verify_fetched_file()
    verify_inserted_data()
  end

  def setup_http_mock do
    ChercheVille.FetcherMock
    |> expect(:start, fn -> :ok end)
    |> expect(:get, fn _url ->
      %HTTPotion.Response{body: File.read!(source_file("YY.zip")), status_code: 200}
    end)
  end

  def verify_fetched_file do
    assert File.exists?(fetched_file("YY.txt"))
    assert File.read!(fetched_file("YY.txt")) == "<source data>\n"
  end

  def verify_inserted_data do
    query = from(c in ChercheVille.City, where: c.name == "Brussels")

    brussels = query |> ChercheVille.Repo.one()
    assert %ChercheVille.City{population: 1_019_022} = brussels
  end
end
