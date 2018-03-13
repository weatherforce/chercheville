ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, :manual)

Mox.defmock(ChercheVille.FetcherMock, for: ChercheVille.Fetcher)
