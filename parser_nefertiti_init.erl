%%This module is to get access to the website we need. It connects to the website that is extracted by this parser.


%%Crate the module
-module(parser_nefertiti_init). 

%%Set up the method that is exported
-export([get_info/0]).

%%Initialize the information domains(Name, Tid etc) that are extracted from the website and set an empty list for each of them. And put all information in one list called "Event".
get_info() ->
    inets:start(),
 
    Name = [],
    Description =[],
    Datum = [],
    Tid = [],
    Picture = [],
    Event = [Name, Description, Tid, Datum, Picture],
    initialize1(Event),
    initialize2(Event).
    
%% Start to get the connection to the first page of the website we parse.
initialize1(Event)->    
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.nefertiti.se/program"),
    get_link(Body, Event).
%% Start to get the connection to the second page of the website we parse.
initialize2(Event) ->
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body2}} =
	httpc:request("http://nefertiti.se/program/index.php?page=2"),
    get_link(Body2, Event).    

%% Get the link to each event of the website by finding the tag. 
get_link([$\",$r,$i,$g,$h,$t,$\",$>,$<,$a,$ ,$h,$r,$e,$f,$=,$\"|T], Event)->
    take_link(T,[], Event);
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> ok. 

%% Request to connect to the link
take_link([$"|T], List, Event) ->
    NewLink = lists:reverse(List),
    {ok, {{_Version1, 200, _ReasonPhrase1}, _Headers, Body}} =
	httpc:request("http://nefertiti.se" ++ NewLink),
    parser_nefertiti:check_text(Body, Event),
    get_link(T, Event);

take_link([H|T], List, Event) -> 
    take_link(T, [H|List], Event).
