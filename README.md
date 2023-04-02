# Pagination

A simple paginator package allowing you to paginate, order and filter data.
Paginator helpers are provided to help generating sorting fields, page fields etc...


![alt text](assets/screenshot.png "Example")

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `paginator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:paginator, "~> 0.1"}
  ]
end
```

## Implementation Details

See `Pagination.Paginator` for more details.

## CSS

To customise Look and Feel, configure these classes:

```
.paginator {
  &.pager {}
  &.pager-page {
    &.first {}
    &.last {}
    &.current {}
    &.spacer {}
  }
  select {}
  &.search-form {
    input[type="text"],input[type="search"] {}
    button {}
  }
}
```

An example of `css` stylesheet using `scss` is provided here:

```css
$paginator-btn-bg: #0069d9;
$paginator-btn-col: #fff;
$paginator-current-bg: #0069d980;
$paginator-spacer-bg: #0001;
$paginator-spacer-col: #000;

.paginator {

  &.pager {
    display: flex; 
    float: right; 
    height: 3rem;
    form {
      display: inline;
    }
  }

  &.pager-page {
    min-width: 3rem; 
    height: 2.5rem; 
    margin: 0 1px 0 0;
    text-align: center; 
    align-self: center;
    color: $paginator-btn-col;
    background-color: $paginator-btn-bg;
    font-size: 1.4rem;
    line-height: 2.5rem;

    &.first {
      border-bottom-left-radius: 1rem; border-top-left-radius: 1rem;
    }
    &.last {
      border-bottom-right-radius: 1rem; border-top-right-radius: 1rem;
    }
    &.current {
      background-color: $paginator-current-bg;
    }
    &.spacer {
      background-color: $paginator-spacer-bg;
      color: $paginator-spacer-col;
    }
  }
  select {
    margin-left: 1rem;
    height: 3rem;
    margin-bottom: 0;
  }


  &.search-form {
    display: flex; 
    flex-direction: row;
    margin: 0 0;
    input[type="text"],input[type="search"] {
      border-radius: 5px;
      border-right: none;
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
    }

    button {
      border-radius: 5px;
      border-top-left-radius: 0;
      border-bottom-left-radius: 0;

    }
  }

}

```


