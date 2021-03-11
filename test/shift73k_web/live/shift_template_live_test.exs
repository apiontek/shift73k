defmodule Shift73kWeb.ShiftTemplateLiveTest do
  use Shift73kWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shift73k.Shifts.Templates

  @create_attrs %{
    description: "some description",
    location: "some location",
    time_start: ~T[08:00:00],
    time_end: ~T[16:00:00],
    subject: "some subject",
    time_zone: "some time_zone"
  }
  @update_attrs %{
    description: "some updated description",
    location: "some updated location",
    time_start: ~T[15:00:00],
    time_end: ~T[19:30:00],
    subject: "some updated subject",
    time_zone: "some updated time_zone"
  }
  @invalid_attrs %{
    description: nil,
    location: nil,
    time_start: nil,
    time_end: nil,
    subject: nil,
    time_zone: nil
  }

  defp fixture(:shift_template) do
    {:ok, shift_template} = Templates.create_shift_template(@create_attrs)
    shift_template
  end

  defp create_shift_template(_) do
    shift_template = fixture(:shift_template)
    %{shift_template: shift_template}
  end

  describe "Index" do
    setup [:create_shift_template]

    test "lists all shift_templates", %{conn: conn, shift_template: shift_template} do
      {:ok, _index_live, html} = live(conn, Routes.shift_template_index_path(conn, :index))

      assert html =~ "Listing Shift templates"
      assert html =~ shift_template.description
    end

    test "saves new shift_template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.shift_template_index_path(conn, :index))

      assert index_live |> element("a", "New Shift template") |> render_click() =~
               "New Shift template"

      assert_patch(index_live, Routes.shift_template_index_path(conn, :new))

      assert index_live
             |> form("#shift_template-form", shift_template: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shift_template-form", shift_template: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shift_template_index_path(conn, :index))

      assert html =~ "Shift template created successfully"
      assert html =~ "some description"
    end

    test "updates shift_template in listing", %{conn: conn, shift_template: shift_template} do
      {:ok, index_live, _html} = live(conn, Routes.shift_template_index_path(conn, :index))

      assert index_live
             |> element("#shift_template-#{shift_template.id} a", "Edit")
             |> render_click() =~
               "Edit Shift template"

      assert_patch(index_live, Routes.shift_template_index_path(conn, :edit, shift_template))

      assert index_live
             |> form("#shift_template-form", shift_template: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shift_template-form", shift_template: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shift_template_index_path(conn, :index))

      assert html =~ "Shift template updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes shift_template in listing", %{conn: conn, shift_template: shift_template} do
      {:ok, index_live, _html} = live(conn, Routes.shift_template_index_path(conn, :index))

      assert index_live
             |> element("#shift_template-#{shift_template.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#shift_template-#{shift_template.id}")
    end
  end
end
