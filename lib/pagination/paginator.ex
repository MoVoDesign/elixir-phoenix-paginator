defmodule Pagination.Paginator do
  @moduledoc """
  This module provides live pagination for a given query.

  It is paired with helper components used to organize and present large
  sets of data in a user-friendly way. It also provides a mechanism for dividing data into
  smaller, more manageable chunks or pages and allows users to navigate through these
  pages using a set of controls such as "next page", "previous page," and page numbers.

  In addition to pagination, this module offers features such as sorting, filtering,
  and search capabilities, allowing users to further refine and customize the data they see.

  Here's a sample `index.html.heex`:

  ```
    <.search_filter_tag paginator={@things} label="Find" />
    <.page_tag paginator={@things} delta={1} />
    <table>
      <thead>
        <tr>
          <td style="width:15%"><.order_tag label="id" order_by={:id} paginator={@things} /></td>
          <td style="width:85%"><.order_tag label="title" order_by={:title} paginator={@things} /></td>
        </tr>
      </thead>
    <%= for t <- @things.data do %>
      <tr>
        <td><%= t.id %></td>
        <td><%= t.title %></td>
      </tr>
    <% end %>
    </table>
  ```

  `@things` is a `Pagination.PaginatorState` that includes pagination parameters and the resulting dataset.

  Do note that you can place `filters_tag`, `page_tag` and `order_tag` pretty much anywhere
  in your page code.

  All changes are handled via event. The `paginate` event must be handled in `index.ex`

  ```
    def mount(params, _session, socket),
      do: {:ok, assign(socket, things: Things.paginate(params))}

    def handle_event("paginate" = event, params, socket),
      do: {:noreply, assign(socket, things: Things.paginate(socket.assigns.things, params))}
  ```

  The `Things` context is the place where the initial query is fed to the paginator:any()

  ```
    def paginate(
          attrs,
          %PaginatorState{} = pg \\ %PaginatorState{
            filters: [title: ""],
            per_page_items: [5, 25, 0],
            order_by: {:asc, :title}
          }
        ) do
      list_things_query()
      |> maybe_apply_advanced_filtering(attrs)
      |> Pagination.Paginator.paginate(Pagination.Paginator.change(pg, attrs))
    end
  ```

  Check the `Pagination.PaginatorState` structure for more details about pagination parameters.
  If complex filtering is required, create and add `maybe_apply_advanced_filtering/2`
  and refine the query as needed.
  """
  alias Pagination.PaginatorState
  # alias Paginator.Repo
  import Ecto.Query, warn: false

  @doc """
  This function paginates and filters the given query and returns an updated `Pagination.PaginatorState`.

  `repo` is your application `Ecto.Repo`.

  Please note that you can add your own pagination extensions or complex filters by modifying
  the `query` before feeding it to `paginate/3`.

  ```
  list_things_query()
  |> apply_my_own_filters(pg_or_my_own_attributes)
  |> Pagination.Paginator.paginate(pg, Repo)
  ```
  """
  def paginate(%Ecto.Query{} = query, %PaginatorState{} = pg, repo, options) do
    # IO.inspect(_w?: {__MODULE__, :paginate}, page_nb: record_nb, paginator: pg)
    pg = ensure_set_per_page_nb(pg)

    filtered_query =
      from(q in query)
      |> maybe_apply_filters(pg.filters)

    # update page data (current and max)
    record_nb = from(q in filtered_query, select: count(q)) |> repo.one()
    page_max = get_max_page(record_nb, pg.per_page_nb)
    pg = %PaginatorState{pg | page_max: page_max, page: min(pg.page, page_max)}

    paginated_query =
      filtered_query
      |> maybe_paginate(pg.page, pg.per_page_nb)
      |> maybe_apply_order(pg.order_by)

    # update data
    data =
      from(q in paginated_query)
      |> maybe_preload(options)
      |> repo.all()

    %PaginatorState{pg | data: data}
  end

  defp maybe_preload(query, preload: preloads), do: from(q in query, preload: ^preloads)
  defp maybe_preload(query, _), do: query

  # compute page numbers, if per_page number is 0: show "All"
  defp get_max_page(_, 0), do: 1
  defp get_max_page(record_nb, per_page_nb), do: 1 + div(record_nb - 1, per_page_nb)

  # preset per_page_nb to first possible choice if not set
  defp ensure_set_per_page_nb(%PaginatorState{per_page_nb: ppnb} = pg) when is_nil(ppnb),
    do: %PaginatorState{pg | per_page_nb: List.first(pg.per_page_items, 10)}

  defp ensure_set_per_page_nb(pg), do: pg

  # handle the page number and the number of items per page
  defp maybe_paginate(%Ecto.Query{} = query, _, 0), do: query

  defp maybe_paginate(%Ecto.Query{} = query, page, per_page_nb) when is_integer(per_page_nb),
    do:
      from(q in query,
        limit: ^per_page_nb,
        offset: ^((page - 1) * per_page_nb)
      )

  # where something like "..." or number == ...
  defp maybe_apply_filters(%Ecto.Query{} = query, filters) when is_list(filters) do
    filters =
      filters
      |> Enum.filter(fn {_, v} -> v != "" end)
      |> Enum.map(fn {k, v} -> {k, "%#{v}%"} end)

    # from(q in query, where: ^filters)
    Enum.reduce(filters, query, fn {k, v}, acc ->
      where(acc, [q], ilike(field(q, ^k), ^v))
    end)
  end

  defp maybe_apply_filters(%Ecto.Query{} = query, _), do: query

  # order by
  defp maybe_apply_order(%Ecto.Query{} = query, nil), do: query

  defp maybe_apply_order(%Ecto.Query{} = query, {order, column}),
    do: from(q in query, order_by: [{^order, ^column}])

  # update paginator with attributes given
  # def update(%PaginatorState{} = pg, %{} = attrs) do
  #   Enum.reduce(attrs, %{}, fn {k, v}, acc ->
  #     k_atom = String.to_atom(k)
  #     # clear rubbish
  #     case Map.has_key?(pg, k_atom) do
  #       true -> Map.put(acc, k_atom, v)
  #       _ -> acc
  #     end
  #   end)
  #   |> IO.inspect()
  # end

  # === PAGINATOR CHANGES
  @spec change(Pagination.PaginatorState.t(), map) :: Pagination.PaginatorState.t()
  @doc """
  Updates the PaginatorState using given data to change order, page and filters.

  `attrs` is a map.
  """
  def change(%PaginatorState{} = pg, %{} = attrs) do
    # IO.inspect(_w?: {__MODULE__, :change}, attrs: attrs)

    pg
    |> maybe_change_order(attrs)
    |> maybe_change_per_page_nb(attrs)
    |> maybe_change_page(attrs)
    |> maybe_change_filters(attrs)
  end

  # ORDER
  defp maybe_change_order(pg, %{"order_by" => order_by}) when is_binary(order_by) do
    ob_field = String.to_atom(order_by)

    %PaginatorState{
      pg
      | order_by:
          case pg.order_by do
            {:asc, ^ob_field} -> {:desc, ob_field}
            {:desc, ^ob_field} -> {:asc, ob_field}
            _ -> {:asc, ob_field}
          end
    }
  end

  defp maybe_change_order(pg, _), do: pg

  # PER PAGE NB
  # don't forget to reset current page to 1
  defp maybe_change_per_page_nb(pg, %{"per_page_nb" => ppnb_s}) when is_binary(ppnb_s),
    do: %PaginatorState{pg | page: 1, per_page_nb: String.to_integer(ppnb_s)}

  defp maybe_change_per_page_nb(pg, _), do: pg

  # PAGE
  defp maybe_change_page(pg, %{"page" => page_s}) when is_binary(page_s),
    do: %PaginatorState{pg | page: String.to_integer(page_s)}

  defp maybe_change_page(pg, _), do: pg

  # FILTERS
  # its = %{"A" => "1", "B" => "2", "C" => "3"}
  defp maybe_change_filters(pg, %{"filters" => filters}) do
    IO.inspect(
      _w?: {__MODULE__, :maybe_change_filters},
      filters: filters,
      pg_accepted_filters: pg.filters
    )

    filters_new =
      filters
      # change %{"field" => value to} %{field: value}
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.to_list()

    # not need to filter on empty filters
    # |> Enum.filter(fn {_, v} -> v != "" end)

    %PaginatorState{pg | filters: filters_new}
  end

  defp maybe_change_filters(pg, _), do: pg
end
