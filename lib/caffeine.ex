defmodule Caffeine do
  @moduledoc """
  ![Coffee Bean Boundary](./coffee.jpeg)

  An alternative stream library
  """

  defmodule Element do
    @moduledoc """
    Dialyzer declaration for an element
    """

    @typedoc """
    An element
    """
    @type t :: term
  end

  defmodule Stream do
    @moduledoc """
    Primitives and HOFs
    """

    @typedoc """
    The Caffeine.Stream data structure
    """
    @opaque t :: nonempty_improper_list(Element.t(), (() -> t)) | []

    @doc """
    This signals the end of a stream

    Don't count on `sentinel/0` returning a `[]`.
    SoE: how can we do this with a Dialyzer declaration?
    """
    @spec sentinel() :: []
    def sentinel do
      []
    end

    @doc """
    Predicate: is _s_ the sentinel?
    """
    @spec sentinel?(t) :: boolean
    def sentinel?(s)
    def sentinel?([]) do
      true
    end

    def sentinel?([_ | x]) when is_function(x, 0) do
      false
    end

    @doc """
    Predicate: is _s_ a stream of at least one element?
    """
    @spec construct?(t) :: boolean
    def construct?(s)
    def construct?([_ | x]) when is_function(x, 0) do
      true
    end

    def construct?([]) do
      false
    end

    @doc """
    A stream of at least one element _h_
    """
    @spec construct(Element.t(), (() -> t)) :: t
    def construct(h, t) when is_function(t, 0) do
      pair(h, t)
    end

    @doc """
    A list of _n_ consecutive elements from the stream _s_
    """
    @spec take(t, integer) :: list
    def take([], _) do
      []
    end

    def take(_, 0) do
      []
    end

    def take(s, n) when is_integer(n) and n > 0 do
      [head(s) | take(tail(s), n - 1)]
    end

    @doc """
    Like the stream _s_ with the function _f_ applied to each element
    """
    @spec map(t, (Element.t() -> Element.t())) :: t
    def map(s, f) do
      # import Caffeine.Stream, only: [sentinel?: 1, construct?: 1, sentinel: 0, construct: 2]

      cond do
        sentinel?(s) ->
          sentinel()

        construct?(s) ->
          g = fn -> map(tail(s), f) end
          construct(f.(head(s)), g)
      end
    end

    @doc """
    A stream whose elements prescribe to the predicate _p_
    """
    @spec filter(t, (Element.t() -> boolean)) :: t
    def filter(s, p) do
      # import Caffeine.Stream, only: [sentinel?: 1, construct?: 1, sentinel: 0, construct: 2]

      cond do
        sentinel?(s) ->
          sentinel()

        construct?(s) ->
          _filter(s, p)
      end
    end

    @doc """
    The head, if any, of the stream _s_
    """
    @spec head(t) :: Element.t()
    def head(s)
    def head([h | t]) when is_function(t, 0) do
      h
    end

    @doc """
    The tail, if any, of the stream _s_
    """
    @spec tail(t) :: t
    def tail(s)
    def tail([_ | t]) when is_function(t, 0) do
      t.()
    end

    defp pair(h, r) do
      [h | r]
    end

    defp _filter(s, p) do
      if p.(head(s)) do
        g = fn -> filter(tail(s), p) end
        construct(head(s), g)
      else
        filter(tail(s), p)
      end
    end
  end
end
