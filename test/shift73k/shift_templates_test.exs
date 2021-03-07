defmodule Shift73k.ShiftTemplatesTest do
  use Shift73k.DataCase

  alias Shift73k.ShiftTemplates

  describe "shift_templates" do
    alias Shift73k.ShiftTemplates.ShiftTemplate

    @valid_attrs %{description: "some description", label: "some label", length_hours: 42, length_minutes: 42, location: "some location", start_time: ~T[14:00:00], subject: "some subject", timezone: "some timezone"}
    @update_attrs %{description: "some updated description", label: "some updated label", length_hours: 43, length_minutes: 43, location: "some updated location", start_time: ~T[15:01:01], subject: "some updated subject", timezone: "some updated timezone"}
    @invalid_attrs %{description: nil, label: nil, length_hours: nil, length_minutes: nil, location: nil, start_time: nil, subject: nil, timezone: nil}

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
      assert shift_template.length_hours == 42
      assert shift_template.length_minutes == 42
      assert shift_template.location == "some location"
      assert shift_template.start_time == ~T[14:00:00]
      assert shift_template.subject == "some subject"
      assert shift_template.timezone == "some timezone"
    end

    test "create_shift_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShiftTemplates.create_shift_template(@invalid_attrs)
    end

    test "update_shift_template/2 with valid data updates the shift_template" do
      shift_template = shift_template_fixture()
      assert {:ok, %ShiftTemplate{} = shift_template} = ShiftTemplates.update_shift_template(shift_template, @update_attrs)
      assert shift_template.description == "some updated description"
      assert shift_template.length_hours == 43
      assert shift_template.length_minutes == 43
      assert shift_template.location == "some updated location"
      assert shift_template.start_time == ~T[15:01:01]
      assert shift_template.subject == "some updated subject"
      assert shift_template.timezone == "some updated timezone"
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
