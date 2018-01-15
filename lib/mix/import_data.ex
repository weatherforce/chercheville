defmodule Mix.Tasks.ImportData do
  use Mix.Task

  @data_dir File.cwd!() <> "/geonames_data/"
  @places_headers ~w{
      geonameid         
      name              
      asciiname         
      alternatenames    
      latitude          
      longitude         
      feature_class     
      feature_code      
      country_code      
      cc2               
      admin1_code       
      admin2_code       
      admin3_code       
      admin4_code       
      population        
      elevation         
      dem               
      timezone          
      modification_date 
    }

  @shortdoc "Import data files from geonames.org into the database"
  def run(country_codes) do
    admin1_codes = read_admin_codes("admin1CodesASCII.txt")
    admin2_codes = read_admin_codes("admin2Codes.txt")
    import_countries(country_codes, admin1_codes, admin2_codes)
  end

  defp import_countries(country_codes, admin1_codes, admin2_codes) do
    Enum.each(country_codes, &import_cities_for_country(&1, admin1_codes, admin2_codes))
  end

  defp import_cities_for_country(country_code, admin1_codes, admin2_codes) do
    @data_dir <> country_code <> ".txt"
    |> File.stream!
    |> CSV.decode(separator: ?\t, headers: @places_headers)
    |> Stream.map(fn({:ok, row}) -> row end)
    |> Stream.filter(&(&1["feature_class"] == "P"))
    |> Stream.map(&add_admin1_names(&1, country_code, admin1_codes))
    |> Stream.map(&add_admin2_names(&1, country_code, admin2_codes))
    |> Enum.take(3)
    |> IO.inspect
  end

  defp add_admin1_names(row, country_code, admin1_codes) do
    key = "#{country_code}.#{row["admin1_code"]}"
    admin1_name = admin1_codes[key]["name"]
    Map.put(row, "admin1_name", admin1_name)
  end

  defp add_admin2_names(row, country_code, admin2_codes) do
    key = "#{country_code}.#{row["admin1_code"]}.#{row["admin2_code"]}"
    admin2_name = admin2_codes[key]["name"]
    Map.put(row, "admin2_name", admin2_name)
  end

  defp read_admin_codes(filename) do
    File.stream!(@data_dir <> filename)
    |> CSV.decode(separator: ?\t, headers: ["code", "name", "asciiname", "geonameid"])
    |> Enum.reduce(%{}, fn
      {:ok, row}, map -> Map.put(map, row["code"], row)
      {:error, _}, map -> map
    end)
  end
end
