defmodule Shift73k.ShiftTemplatesTest do
  use Shift73k.DataCase

  alias Shift73k.ShiftTemplates

  describe "shift_templates" do
    alias Shift73k.ShiftTemplates.ShiftTemplate

    @valid_attrs %{description: "some description", location: "some location", time_start: ~T[08:00:00], time_end: ~T[16:00:00], subject: "some subject", time_zone: "some time_zone"}
    @update_attrs %{description: "some updated description", location: "some updated location", time_start: ~T[13:00:00], time_end: ~T[19:30:00], subject: "some updated subject", time_zone: "some updated time_zone"}
    @invalid_attrs %{description: nil, location: nil, time_start: nil, time_end: nil, subject: nil, time_zone: nil}

    def shift_template_fixture(attrs \\ %{}) do
      {:ok, shift_template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ShiftTemplates.create_shift_template()

      shift_template
    end

    test "list_shift_templates/0 returns all shift_templates" do
      shift_template = shift_template_fixture()
      assert ShiftTemplates.list_shift_templates() == [shift_template]
    end

    test "get_shift_template!/1 returns the shift_template with given id" do
      shift_template = shift_template_fixture()
      assert ShiftTemplates.get_shift_template!(shift_template.id) == shift_template
    end

    test "create_shift_template/1 with valid data creates a shift_template" do
      assert {:ok, %ShiftTemplate{} = shift_template} = ShiftTemplates.create_shift_template(@valid_attrs)
      assert shift_template.description == "some description"
      assert shift_template.location == "some location"
      assert shift_template.time_start == ~T[07:00:00]
      assert shift_template.time_end == ~T[15:00:00]
      assert shift_template.subject == "some subject"
      assert shift_template.time_zone == "some time_zone"
    end

    test "create_shift_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShiftTemplates.create_shift_template(@invalid_attrs)
    end

    test "update_shift_template/2 with valid data updates the shift_template" do
      shift_template = shift_template_fixture()
      assert {:ok, %ShiftTemplate{} = shift_template} = ShiftTemplates.update_shift_template(shift_template, @update_attrs)
      assert shift_template.description == "some updated description"
      assert shift_template.location == "some updated location"
      assert shift_template.time_start == ~T[15:00:00]
      assert shift_template.time_end == ~T[19:30:00]
      assert shift_template.subject == "some updated subject"
      assert shift_template.time_zone == "some updated time_zone"
    end

    test "update_shift_template/2 with invalid data returns error changeset" do
      shift_template = shift_template_fixture()
      assert {:error, %Ecto.Changeset{}} = ShiftTemplates.update_shift_template(shift_template, @invalid_attrs)
      assert shift_template == ShiftTemplates.get_shift_template!(shift_template.id)
    end

    test "delete_shift_template/1 deletes the shift_template" do
      shift_template = shift_template_fixture()
      assert {:ok, %ShiftTemplate{}} = ShiftTemplates.delete_shift_template(shift_template)
      assert_raise Ecto.NoResultsError, fn -> ShiftTemplates.get_shift_template!(shift_template.id) end
    end

    test "change_shift_template/1 returns a shift_template changeset" do
      shift_template = shift_template_fixture()
      assert %Ecto.Changeset{} = ShiftTemplates.change_shift_template(shift_template)
    end
  end
end
