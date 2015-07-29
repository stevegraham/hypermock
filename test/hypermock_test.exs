defmodule HyperMockTest do
  use ExUnit.Case, async: false
  use HyperMock

  alias HyperMock.NetConnectNotAllowedError
  alias HyperMock.UnmetExpectationError

  test "making a request without a matching stub raises an error" do
    message = """
    Real HTTP connections are disabled.

    Unregistered request: GET http://example.com with headers ["User-Agent": "Lol"] and body ""

    You can stub this request with the following snippet:

    stub_request(%HyperMock.Request{body: "", headers: ["User-Agent": "Lol"], method: :get, uri: "http://example.com"})
    """

    HyperMock.intercept do
      assert_raise NetConnectNotAllowedError, message, fn ->
        :ibrowse.send_req 'http://example.com', [{'User-Agent', 'Lol'}], :get
      end
    end
  end

  test "making a request with an exactly matching stub returns request data from the stub" do
    HyperMock.intercept do
      request  = %Request{ method: :get, uri: "http://example.com", headers: ["User-Agent": "Lol"] }
      response = %Response{ body: "LOOOOOOOOOOOOL m8!", headers: ["X-Shenanigans": "U WOT M8?"] }

      stub_request request, response

      assert :ibrowse.send_req('http://example.com', [{'User-Agent', 'Lol'}], :get) == {:ok, '200', [{'X-Shenanigans', 'U WOT M8?'}], 'LOOOOOOOOOOOOL m8!'}
    end
  end

  test "making a request multiple times with the stubbed request returns request data from the stub" do
    HyperMock.intercept do
      request  = %Request{ method: :get, uri: "http://example.com", headers: ["User-Agent": "Lol"] }
      response = %Response{ body: "LOOOOOOOOOOOOL m8!", headers: ["X-Shenanigans": "U WOT M8?"] }

      stub_request request, response

      :ibrowse.send_req('http://example.com', [{'User-Agent', 'Lol'}], :get)
      :ibrowse.send_req('http://example.com', [{'User-Agent', 'Lol'}], :get)
      :ibrowse.send_req('http://example.com', [{'User-Agent', 'Lol'}], :get)

      assert :ibrowse.send_req('http://example.com', [{'User-Agent', 'Lol'}], :get) == {:ok, '200', [{'X-Shenanigans', 'U WOT M8?'}], 'LOOOOOOOOOOOOL m8!'}
    end
  end

  test "making a request with a partially matching stub raises an error" do
    HyperMock.intercept do
      request  = %Request{ method: :get, uri: "http://example.com", headers: ["User-Agent": "Lol"] }
      response = %Response{ body: "LOOOOOOOOOOOOL m8!", headers: ["X-Shenanigans": "U WOT M8?"] }

      stub_request request, response

      assert_raise NetConnectNotAllowedError, fn ->
        :ibrowse.send_req 'http://example.com', [{'User-Agent', 'Lol'}], :get
        :ibrowse.send_req 'http://example.com', [], :get
      end
    end
  end

  test "stubbing a request and not making the request raises an error" do
    message = """
    The following requests were stubbed but not made:

    %HyperMock.Request{body: "", headers: ["User-Agent": "Lol"], method: :get, uri: "http://example.com"}

    If you're not using this stub, remove it to keep your tests green and clean.
    """

    assert_raise UnmetExpectationError, message, fn ->
      HyperMock.intercept do
        request  = %Request{ method: :get, uri: "http://example.com", headers: ["User-Agent": "Lol"] }
        stub_request request
      end
    end
  end
end
