import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hawk, Hawk.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "hawk_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  timeout: :infinity,
  # 2. CHECKOUT: Timeout for waiting on a connection from the pool
  pool_timeout: :infinity,

  # 3. SANDBOX: Timeout for how long a process can "own" a sandbox connection
  ownership_timeout: :infinity

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hawk, HawkWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zvazIgog0d9VyIxI6LRedAjk0TrB0Losbv+qBAvKXxXxSVm8ADhnxnQlSY18WKnd",
  server: false

# In test we don't send emails
config :hawk, Hawk.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
