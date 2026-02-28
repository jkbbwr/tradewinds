ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Tradewinds.Repo, :manual)
Mox.defmock(Tradewinds.ClockMock, for: Tradewinds.Clock)
Application.put_env(:tradewinds, :clock_adapter, Tradewinds.ClockMock)
