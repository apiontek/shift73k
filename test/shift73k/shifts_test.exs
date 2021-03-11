defmodule Shift73k.ShiftsTest do
  use Shift73k.DataCase

  alias Shift73k.Shifts

  describe "shifts" do
    alias Shift73k.Shifts.Shift

    @valid_attrs %{date: ~D[2010-04-17], description: "some description", location: "some location", subject: "some subject", time_end: ~T[14:00:00], time_start: ~T[14:00:00], time_zone: "some time_zone"}
    @update_attrs %{date: ~D[2011-05-18], description: "some updated description", location: "some updated location", subject: "some updated subject", time_end: ~T[15:01:01], time_start: ~T[15:01:01], time_zone: "some updated time_zone"}
    @invalid_attrs %{date: nil, description: nil, location: nil, subject: nil, time_end: nil, time_start: nil, time_zone: nil}

    def shift_fixture(attrs \\ %{}) do
      {:ok, shift} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Shifts.create_shift()

      shift
    end

    test "list_shifts/0 returns all shifts" do
      shift = shift_fixture()
      assert Shifts.list_shifts() == [shift]
    end

    test "get_shift!/1 returns the shift with given id" do
      shift = shift_fixture()
      assert Shifts.get_shift!(shift.id) == shift
    end

    test "create_shift/1 with valid data creates a shift" do
      assert {:ok, %Shift{} = shift} = Shifts.create_shift(@valid_attrs)
      assert shift.date == ~D[2010-04-17]
      assert shift.description == "some description"
      assert shift.location == "some location"
      assert shift.subject == "some subject"
      assert shift.time_end == ~T[14:00:00]
      assert shift.time_start == ~T[14:00:00]
      assert shift.time_zone == "some time_zone"
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shifts.create_shift(@invalid_attrs)
    end

    test "update_shift/2 with valid data updates the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{} = shift} = Shifts.update_shift(shift, @update_attrs)
      assert shift.date == ~D[2011-05-18]
      assert shift.description == "some updated description"
      assert shift.location == "some updated location"
      assert shift.subject == "some updated subject"
      assert shift.time_end == ~T[15:01:01]
      assert shift.time_start == ~T[15:01:01]
      assert shift.time_zone == "some updated time_zone"
    end

    test "update_shift/2 with invalid data returns error changeset" do
      shift = shift_fixture()
      assert {:error, %Ecto.Changeset{}} = Shifts.update_shift(shift, @invalid_attrs)
      assert shift == Shifts.get_shift!(shift.id)
    end

    test "delete_shift/1 deletes the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{}} = Shifts.delete_shift(shift)
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_shift!(shift.id) end
    end

    test "change_shift/1 returns a shift changeset" do
      shift = shift_fixture()
      assert %Ecto.Changeset{} = Shifts.change_shift(shift)
    end
  end
end
