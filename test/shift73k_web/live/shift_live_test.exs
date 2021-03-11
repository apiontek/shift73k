defmodule Shift73kWeb.ShiftLiveTest do
  use Shift73kWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shift73k.Shifts

  @create_attrs %{date: ~D[2010-04-17], description: "some description", location: "some location", subject: "some subject", time_end: ~T[14:00:00], time_start: ~T[14:00:00], time_zone: "some time_zone"}
  @update_attrs %{date: ~D[2011-05-18], description: "some updated description", location: "some updated location", subject: "some updated subject", time_end: ~T[15:01:01], time_start: ~T[15:01:01], time_zone: "some updated time_zone"}
  @invalid_attrs %{date: nil, description: nil, location: nil, subject: nil, time_end: nil, time_start: nil, time_zone: nil}

  defp fixture(:shift) do
    {:ok, shift} = Shifts.create_shift(@create_attrs)
    shift
  end

  defp create_shift(_) do
    shift = fixture(:shift)
    %{shift: shift}
  end

  describe "Index" do
    setup [:create_shift]

    test "lists all shifts", %{conn: conn, shift: shift} do
      {:ok, _index_live, html} = live(conn, Routes.shift_index_path(conn, :index))

      assert html =~ "Listing Shifts"
      assert html =~ shift.description
    end

    test "saves new shift", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.shift_index_path(conn, :index))

      assert index_live |> element("a", "New Shift") |> render_click() =~
               "New Shift"

      assert_patch(index_live, Routes.shift_index_path(conn, :new))

      assert index_live
             |> form("#shift-form", shift: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shift-form", shift: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shift_index_path(conn, :index))

      assert html =~ "Shift created successfully"
      assert html =~ "some description"
    end

    test "updates shift in listing", %{conn: conn, shift: shift} do
      {:ok, index_live, _html} = live(conn, Routes.shift_index_path(conn, :index))

      assert index_live |> element("#shift-#{shift.id} a", "Edit") |> render_click() =~
               "Edit Shift"

      assert_patch(index_live, Routes.shift_index_path(conn, :edit, shift))

      assert index_live
             |> form("#shift-form", shift: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shift-form", shift: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shift_index_path(conn, :index))

      assert html =~ "Shift updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes shift in listing", %{conn: conn, shift: shift} do
      {:ok, index_live, _html} = live(conn, Routes.shift_index_path(conn, :index))

      assert index_live |> element("#shift-#{shift.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#shift-#{shift.id}")
    end
  end

  describe "Show" do
    setup [:create_shift]

    test "displays shift", %{conn: conn, shift: shift} do
      {:ok, _show_live, html} = live(conn, Routes.shift_show_path(conn, :show, shift))

      assert html =~ "Show Shift"
      assert html =~ shift.description
    end

    test "updates shift within modal", %{conn: conn, shift: shift} do
      {:ok, show_live, _html} = live(conn, Routes.shift_show_path(conn, :show, shift))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Shift"

      assert_patch(show_live, Routes.shift_show_path(conn, :edit, shift))

      assert show_live
             |> form("#shift-form", shift: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#shift-form", shift: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shift_show_path(conn, :show, shift))

      assert html =~ "Shift updated successfully"
      assert html =~ "some updated description"
    end
  end
end
