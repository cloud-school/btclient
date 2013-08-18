-module(btclient).
-export([getinfo/0, getnewaddress/1, gettransaction/1]).

getinfo() ->
  request(getinfo).

getnewaddress(Account) when is_binary(Account) ->
  request(getnewaddress, [Account]).

gettransaction(TxId) when is_binary(TxId) ->
  request(gettransaction, [TxId]).

request(Cmd) ->
  request(Cmd, []).

request(Cmd, Params) ->
  Url = get_env(url, "http://127.0.0.1:18332"),
  Headers = [auth_header(), {"Content-Type","text/json"}],
  Options = [{body_format,binary}],

  Body = [{<<"jsonrpc">>, <<"1.0">>}] ++
         [{<<"method">>, erlang:atom_to_binary(Cmd, utf8)}] ++
         [{<<"params">>, Params}],

  BodyStream = jsx:encode(Body),

  {ok, {{_, 200, _}, _, ResultStream}} = httpc:request(post, {Url, Headers, "text/json", BodyStream}, [], Options),

  Result = jsx:decode(ResultStream),

  proplists:get_value(<<"result">>, Result, []).

auth_header() ->
  Username = get_env(username, "bitcoinrpc"),
  Password = get_env(password, "bitcoinpwd"),
  auth_header(Username, Password).

auth_header(Username, Password) ->
  {"Authorization","Basic " ++ base64:encode_to_string(
      lists:append([Username, ":", Password]))}.

get_env(Key, Def) ->
  case application:get_env(btclient, Key) of
    {ok, Val} -> Val;
    undefined -> Def
  end.
