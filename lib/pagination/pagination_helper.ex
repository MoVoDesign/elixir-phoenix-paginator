defmodule Pagination.PaginationHelper do
  @moduledoc """
  This module contains helper functions to create the following components:
  - order_by buttons
  - page links
  - filters

  Check `Pagination.Paginator` for a complete example.
  """
  use Phoenix.Component
  alias Pagination.PaginatorState

  # attr :label, :string, required: true
  @spec order_tag(any()) :: any()
  @doc """
  Provides a link to order following a given field

  ```
  <.order_tag label="id"
    order_by={:id}
    paginator={@things}
    arrows={%{asc: "A-Z", desc: "Z-A"}}/>
  ```
  """
  def order_tag(%{order_by: order_by, paginator: %PaginatorState{} = paginator} = assigns) do
    arrows = Map.get(assigns, :arrows, %{})

    arrow = order_arrow_indicator(paginator, order_by, arrows)
    IO.inspect(arrow: arrow, arrows: arrows, order_by: order_by)

    assigns =
      Map.merge(
        %{
          arrow: arrow,
          arrows: arrows
        },
        assigns
      )

    ~H"""
    <a href="#" phx-click="paginate", phx-value-order_by={@order_by}><%= @label %></a><%= order_arrow_indicator(@paginator, @order_by, @arrows) %>
    """
  end

  # TODO: improve indivators or use given list
  defp order_arrow_indicator(
         %PaginatorState{order_by: {direction, field}},
         tag_order_by_field,
         %{} = arrows
       )
       when field == tag_order_by_field do
    case direction do
      :asc -> Map.get(arrows, :asc, " (asc)")
      _ -> Map.get(arrows, :desc, " (desc)")
    end
  end

  defp order_arrow_indicator(_, _, _), do: ""

  @spec page_tag(any()) :: any()
  @doc """
  Provides links for pages 1...N and a select box for number of items per page.any()
  if `delta` is provided as an argument, it'll modify the boundaries around the current
  page. Default value for `delta` is 1.

  The options for the number of items per page are defined in `Pagination.PaginatorState`

  ```
  per_page_items: [5, 10, 25, 0]
  ```
  0 stands for: all records


  ```
  <.page_tag
    paginator={@things}
    delta={2} />
  ```
  """
  def page_tag(assigns) do
    # set defaults
    assigns = Map.merge(%{delta: 1}, assigns)

    ~H"""
    <div class="paginator pager" style="">
      <%= page_indicators(@paginator.page, @paginator.page_max, @delta) %>
      <form id="paginator" phx-change="paginate" style="display: inline">
        <select name="per_page_nb">
        <%= for pnb <- @paginator.per_page_items do %>
          <%= per_page_tag_option(pnb, @paginator.per_page_nb) %>
        <% end %>
        </select>
      </form>
    </div>

    """
  end

  defp per_page_tag_option(per_page_nb, per_page_nb_current, options \\ %{}) do
    default = if per_page_nb == per_page_nb_current, do: " selected", else: ""
    label = if per_page_nb == 0, do: Map.get(options, :all_label, "All"), else: per_page_nb

    """
    <option value=#{per_page_nb}#{default}>#{label}</option>
    """
    |> Phoenix.HTML.raw()
  end

  # displays a block of page numbers unless there's only one page
  defp page_indicators(_page, 1, _), do: ""

  defp page_indicators(page, page_nb, delta) do
    # get the boundaries of the window showing the current page
    w_start = max(1, page - delta)
    w_end = min(page_nb, page + delta)

    1..page_nb
    # 1, 2, 3, 4, 5, 6, 7, 8, 9 (e.g. page=4, delta=1)
    |> Enum.map(fn e ->
      if (e > 1 and e < w_start) or (e > w_end and e < page_nb), do: :space, else: e
    end)
    # 1, :space, :space, 3, 4, 5, :space, :space, :space, 9
    |> Enum.dedup()
    # 1, :space, 3, 4, 5, :space, 9
    |> Enum.reduce("", fn p, acc -> acc <> page_indicator(p, page, page_nb) end)
    |> Phoenix.HTML.raw()
  end

  defp page_indicator(page_nb, page_nb_current, page_max) do
    css_class =
      "paginator pager-page" <>
        case page_nb do
          1 -> " first"
          ^page_max -> " last"
          _ -> ""
        end

    case page_nb do
      :space ->
        """
        <span class="#{css_class} spacer">&hellip;</span>
        """

      ^page_nb_current ->
        """
          <span class="#{css_class} current">#{page_nb}</span>
        """

      _ ->
        """
        <a href="#" phx-click="paginate" phx-value-page=#{page_nb} class="#{css_class}">#{page_nb}</a>
        """
    end
  end

  # === FILTER
  @spec search_filter_tag(any()) :: any()
  @doc """
  Generates inclusive filters (filter1 and filter2 and ...)

  Filters are defined in `Pagination.PaginatorState` as tuples `{field, label}`

  ```
  filters: [id: "UID", title: "Item Title", field: "Label"]
  ```

  The button text can be configured using `label`

  ```
  <.search_filter_tag
    paginator={@things}
    label="Find" />
  ```

  """
  def search_filter_tag(assigns) do
    assigns = Map.merge(%{label: "Go!"}, assigns)

    ~H"""
    <form id={"paginator-search"} phx-submit="paginate" class="paginator search-form">
      <%= for {f, v} <- @paginator.filters do %>
        <input type="search" name={"filters[#{f}]"} placeholder={f} value={"#{v}"}>
      <% end %>
      <button type="submit"><%= @label %></button>
    </form>
    """
  end
end
