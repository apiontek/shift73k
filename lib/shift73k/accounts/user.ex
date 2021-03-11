defmodule Shift73k.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  alias Shift73k.Shifts.Templates.ShiftTemplate

  @roles [
    user: "Basic user level",
    manager: "Can create users, update user emails & passwords",
    admin: "Can delete users and change user roles"
  ]

  defenum(RolesEnum, :role, Keyword.keys(@roles))

  @max_email 254
  @min_password 8
  @max_password 80

  @derive {Inspect, except: [:password]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)
    field(:confirmed_at, :naive_datetime)

    field(:role, RolesEnum, default: :user)

    has_many(:shift_templates, ShiftTemplate)
    belongs_to(:fave_shift_template, ShiftTemplate)

    timestamps()
  end

  def max_email, do: @max_email
  def min_password, do: @min_password
  def max_password, do: @max_password
  def roles, do: @roles

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :role])
    |> validate_role()
    |> validate_email()
    |> validate_password(opts)
  end

  # def update_changeset(user, attrs, opts \\ [])

  # def update_changeset(user, %{"password" => ""} = attrs, _),
  #   do: update_changeset_no_pw(user, attrs)

  # def update_changeset(user, %{password: ""} = attrs, _), do: update_changeset_no_pw(user, attrs)

  def update_changeset(user, attrs, opts) do
    user
    |> cast(attrs, [:email, :password, :role])
    |> validate_role()
    |> validate_email()
    |> validate_password_not_required(opts)
  end

  # def update_changeset_no_pw(user, attrs) do
  #   user
  #   |> cast(attrs, [:email, :role])
  #   |> validate_role()
  #   |> validate_email()
  # end

  defp role_validator(:role, role) do
    (RolesEnum.valid_value?(role) && []) || [role: "invalid user role"]
  end

  defp validate_role(changeset) do
    changeset
    |> validate_required([:role])
    |> validate_change(:role, &role_validator/2)
  end

  defp validate_email_format(changeset) do
    r_email = ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-z0-9-]+(\.[a-z0-9-]+)*$/i

    changeset
    |> validate_required([:email])
    |> validate_format(:email, r_email, message: "must be a valid email address")
    |> validate_length(:email, max: @max_email)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_email_format()
    |> unsafe_validate_unique(:email, Shift73k.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_password_not_required(opts)
  end

  defp validate_password_not_required(changeset, opts) do
    changeset
    |> validate_length(:password, min: @min_password, max: @max_password)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Shift73k.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
