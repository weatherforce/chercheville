defmodule Mix.Tasks.FetchData do
  use Mix.Task

  @base_url "http://download.geonames.org/export/dump/"
  @data_dir File.cwd!() <> "/geonames_data/"

  @shortdoc "Fetch data files from geonames.org"
  def run(country_codes) do
    File.mkdir(@data_dir)

    HTTPotion.start()

    fetch_file("admin1CodesASCII.txt")
    fetch_file("admin2Codes.txt")

    Enum.each(country_codes, fn(country_code) ->
      fetch_file(country_code <> ".zip") |> unzip
    end)
  end

  defp unzip(filename) do
    to_charlist(filename) |> :zip.unzip(cwd: @data_dir)
  end

  defp fetch_file(filename) do
    destination_filename = @data_dir <> filename
    if not File.exists?(destination_filename) do
      url = @base_url <> filename
      IO.puts("Download #{url}")
      %HTTPotion.Response{body: body, status_code: 200} = HTTPotion.get(url)
      File.write(destination_filename, body)
    else
      IO.puts("#{destination_filename} already exists")
    end
    destination_filename
  end
end
