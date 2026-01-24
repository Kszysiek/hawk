defmodule Hawk.Repo do
  use Ecto.Repo,
    otp_app: :hawk,
    adapter: Ecto.Adapters.Postgres
end
