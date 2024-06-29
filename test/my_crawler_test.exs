defmodule MyCrawlerTest do
  use ExUnit.Case
  doctest MyCrawler

  test "greets the world" do
    assert MyCrawler.hello() == :world
  end
end
