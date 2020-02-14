defmodule EctoTemp.Extra.Assertions do
  import ExUnit.Assertions

  def assert_eq(left, right, opts \\ [])

  def assert_eq(left, right, opts) when is_list(left) and is_list(right) do
    {left, right} =
      if Keyword.get(opts, :ignore_order, false) do
        {Enum.sort(left), Enum.sort(right)}
      else
        {left, right}
      end

    assert left == right
    left
  end

  def assert_eq(string, %Regex{} = regex, _opts) when is_binary(string) do
    unless string =~ regex do
      ExUnit.Assertions.flunk("""
        Expected string to match regex
        left (string): #{string}
        right (regex): #{regex |> inspect}
      """)
    end

    string
  end

  def assert_eq(actual, %Regex{} = regex, _opts) do
    unless to_string(actual) =~ regex do
      ExUnit.Assertions.flunk("""
        Expected value to match regex
        left (string): #{actual}
        right (regex): #{regex |> inspect}
      """)
    end

    actual
  end

  def assert_eq(left, right, _opts) do
    assert left == right
    left
  end

  def assert_event(event_fn, changes: query_fn, from: before_value, to: after_value)
      when is_function(event_fn) and is_function(query_fn) do
    query_fn.()
    |> assert_eq(before_value)

    event_fn.()

    query_fn.()
    |> assert_eq(after_value)
  end

  def assert_recent(timestamp) do
    timestamp = timestamp |> NaiveDateTime.truncate(:second)
    now = NaiveDateTime.local_now()

    cond do
      NaiveDateTime.compare(timestamp, NaiveDateTime.add(now, -30, :second)) == :lt ->
        flunk("""
        Expected timestamp to be recent, but was older than 30 seconds ago
        Timestamp: #{timestamp}
        """)

      NaiveDateTime.compare(timestamp, now) == :gt ->
        flunk("""
        Expected timestamp to be recent, but was in the future
        Timestamp: #{timestamp}
        """)

      true ->
        timestamp
    end
  end
end
