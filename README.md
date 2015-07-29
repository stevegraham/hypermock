# HyperMock

HTTP request stubbing and expectation Elixir library. Intercepts HTTP calls and
either returns a stubbed response if that request was stubbed or raises an error
if a matching request was not found in the stubbed requests.

The idea is to provide tools to explicitly verify properties of the actual request
rather than loose stubbing to return canned responses in your tests.

```elixir
defmodule RequestTest do
  use HyperMock

  def fail do
    HyperMock.intercept do
      # No expectations have been set. This will raise an error.
      HTTPotion.get "http://example.com:3000/users", [body: "hello=world", headers: ["User-Agent": "My App"]]
    end
  end

  def yay do
    HyperMock.intercept do
      request  = %Request{ method: :get, uri: "http://lol.biz.info", headers: ["User-Agent": "My App"] }
      response = %Response{ body: "LOOOOOOOOOOOOL m8!" }

      stub_request request, response

      # This will return a HTTPotion.Response struct with a 200 status and body of "LOOOOOOOOOOOOL m8!"
      HTTPotion.get("http://lol.biz.info", headers: ["User-Agent": "My App"]) |> inspect |> IO.puts
    end
  end
end
```

# Limitations

Only works with ibrowse synchronous requests right now. If you want to add support
for asynchronous requests or another client open an issue and let's talk about it :)

# Contributing

If you have an idea please open an issue to start discussion first. The feature may
have been discussed previously or in development.
