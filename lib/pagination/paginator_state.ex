defmodule Pagination.PaginatorState do
  @moduledoc """
  The Paginator State structure
  it defines properties that changes with user input
  - `page` - current page displayed
  - `page_max` - current last page index based on query results and `per_page_nb`
  - `per_page_nb` - current selected number of records per page to display
     (0 is used to display all records)
  - `per_page_items` - list of possible selections
  - `filters` an array of tuples {field_name, "label to show"}
  as well as prooerties that
  are required to setup default values
  """
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
