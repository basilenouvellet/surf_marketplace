defmodule SurfMarketplaceWeb.ErrorJSONTest do
  use SurfMarketplaceWeb.ConnCase, async: true

  test "renders 404" do
    assert SurfMarketplaceWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert SurfMarketplaceWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
