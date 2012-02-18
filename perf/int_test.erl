-module(int_test).
-export([test/3]).

add(Base, 0) ->
	Base;

add(Base, Time) when Time > 0 ->
	add(Base + 1, Time - 1).

loop(Base, 0) ->
	Base;

loop(Base, Time) when Time > 0 ->
	loop(Base, Time - 1).

test(add, Base, Time) ->
	useTime(fun add/2, Base, Time);

test(loop, Base, Time) ->
	useTime(fun loop/2, Base, Time).

useTime(F, Base, Time) -> 
	{_, StartM, StartL} = now(), 
	F(Base, Time), 
	{_, EndM, EndL} = now(), 
	(EndM - StartM) * 1000000 + (EndL - StartL).