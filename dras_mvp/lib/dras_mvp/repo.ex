defmodule DrasMvp.Repo do
  use Ecto.Repo,
    otp_app: :dras_mvp,
    adapter: Ecto.Adapters.SQLite3
end
