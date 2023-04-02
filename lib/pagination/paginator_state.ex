defmodule Pagination.PaginatorState do
  defstruct order_by: {:asc, :id},
            filters: [],
            page: 1,
            page_max: 1,
            per_page_nb: nil,
            per_page_items: [5, 10, 20, 0],
            data: []

  @type t :: %__MODULE__{
          # a tuple to provide a direction and a field
          order_by: nil | {:asc | :desc, any()},
          # a keyword list of filters defined by field: [title: "World", description: "ello"]
          filters: [],
          # the current page displayed
          page: non_neg_integer(),
          # the max number of pages to display
          page_max: non_neg_integer(),
          # the current items displayed per page,
          # if nil -> set to the head of `per_page_items` or 10 (default)
          per_page_nb: nil | non_neg_integer(),
          # the list of possible selections for number of items to display per page
          per_page_items: [non_neg_integer()],
          # the results
          data: []
        }
end
