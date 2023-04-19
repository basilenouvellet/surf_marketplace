defmodule SurfMarketplaceWeb.Helpers do
  @doc """
  ## Examples

      iex> url_to_path("http://localhost:4000/blog")
      "/blog"

      iex> url_to_path("http://localhost:4000/blog/")
      "/blog"

      iex> url_to_path("http://localhost:4000/blog/abc")
      "/blog/abc"

      iex> url_to_path("http://localhost:4000/")
      "/"

      iex> url_to_path("http://localhost:4000")
      "/"

      iex> url_to_path("https://myapp.com")
      "/"

      iex> url_to_path("https://myapp.com/blog/abc")
      "/blog/abc"
  """
  def url_to_path(url) do
    url
    |> URI.new!()
    |> Map.get(:path)
    |> case do
      nil -> "/"
      "/" -> "/"
      path -> path |> String.trim_trailing("/")
    end
  end
end
