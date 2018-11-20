defmodule ChercheVille.Repo do
  use Ecto.Repo, otp_app: :chercheville,
                 adapter: Ecto.Adapters.Postgres
end
