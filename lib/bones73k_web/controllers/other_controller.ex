defmodule Bones73kWeb.OtherController do
  use Bones73kWeb, :controller

  def index(conn, _params) do
    conn
    |> put_flash(:success, "Log in was a success. Good for you.")
    |> put_flash(:error, "Lorem ipsum dolor sit amet consectetur adipisicing elit.")
    |> put_flash(
      :info,
      "Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatibus dolore sunt quia aperiam sint id reprehenderit? Dolore incidunt alias inventore accusantium nulla optio, ducimus eius aliquam hic, pariatur voluptate distinctio."
    )
    |> put_flash(:warning, "Oh no, there's nothing to worry about!")
    |> put_flash(:primary, "Something in the brand color.")
    |> render("index.html")
  end
end
