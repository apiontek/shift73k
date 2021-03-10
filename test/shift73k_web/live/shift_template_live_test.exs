defmodule Shift73kWeb.ShiftTemplateLiveTest do
  use Shift73kWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shift73k.ShiftTemplates

  @create_attrs %{
    description: "some description",
    length_hours: 12,
    length_minutes: 42,
    location: "some location",
    start_time: ~T[14:00:00],
    subject: "some subject",
    timezone: "some timezone"
  }
  @update_attrs %{
    description: "some updated description",
    length_hours: 12,
    length_minutes: 43,
    location: "some updated location",
    start_time: ~T[15:01:01],
    subject: "some updated subject",
    timezone: "some updated timezone"
  }
  @invalid_attrs %{
    description: nil,
    length_hours: nil,
    length_minutes: nil,
    location: nil,
    start_time: nil,
    subject: nil,
    timezone: nil
  }

  defp fixture(:shift_template) do
    {:ok, shift_template} = ShiftTemplates.create_shift_template(@create_attrs)
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