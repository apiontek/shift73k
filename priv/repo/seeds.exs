# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shift73k.Repo.insert!(%Shift73k.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Shift73k.Repo
alias Shift73k.Accounts
alias Shift73k.Accounts.User

############################################################################
## INSERTING MOCK USER DATA

{:ok, _admin} =
  Accounts.register_user(%{
    email: "admin@company.com",
    password: "123456789abC",
    password_confirmation: "123456789abC",
    role: Accounts.registration_role()
  })

{:ok, _user_1} =
  Accounts.register_user(%{
    email: "user1@company.com",
    password: "123456789abC",
    password_confirmation: "123456789abC",
    role: Accounts.registration_role()
  })

{:ok, _user_2} =
  Accounts.register_user(%{
    email: "user2@company.com",
    password: "123456789abC",
    password_confirmation: "123456789abC",
    role: Accounts.registration_role()
  })

# if Mix.env() == :dev do
this_path = Path.dirname(__ENV__.file)
users_json = Path.join(this_path, "MOCK_DATA_users.json")

count_to_take = 15

mock_users = users_json |> File.read!() |> Jason.decode!() |> Enum.take_random(count_to_take)

extra_mock_users = ~s([
  {"email":"adam@73k.us","password":"adamadamA1","role":"admin","inserted_at":"2018-12-14T01:01:01Z","confirmed_at":true},
  {"email":"karen@73k.us","password":"karenkarenA1","role":"manager","inserted_at":"2018-12-14T01:06:01Z","confirmed_at":true},
  {"email":"kat@73k.us","password":"katkatA1","role":"manager","inserted_at":"2018-12-14T01:06:01Z","confirmed_at":true}
])

mock_users =
  extra_mock_users
  |> Jason.decode!()
  |> Enum.concat(mock_users)
  |> Enum.map(fn e ->
    add_dt = NaiveDateTime.from_iso8601!(e["inserted_at"])

    %{
      email: e["email"],
      role: String.to_existing_atom(e["role"]),
      hashed_password: Bcrypt.hash_pwd_salt(e["password"]),
      week_start_at: :rand.uniform(2),
      inserted_at: add_dt,
      updated_at: add_dt,
      confirmed_at: (e["confirmed_at"] && NaiveDateTime.add(add_dt, 300, :second)) || nil
    }
  end)

Repo.insert_all(User, mock_users)
# end

#####
# shift tepmlates
alias Shift73k.Shifts.Templates.ShiftTemplate

shifts_json = Path.join(this_path, "MOCK_DATA_shift-templates.json")
mock_shifts = shifts_json |> File.read!() |> Jason.decode!()

time_from_mock = fn mock_time ->
  case String.length(mock_time) do
    4 -> Time.from_iso8601!("T0#{mock_time}:00")
    5 -> Time.from_iso8601!("T#{mock_time}:00")
  end
end

seconds_day = 86_400
seconds_days_14 = seconds_day * 14
seconds_half_day = Integer.floor_div(seconds_day, 2)

for user <- Accounts.list_users() do
  user_shifts =
    mock_shifts
    |> Enum.take_random(:rand.uniform(15) + 5)
    |> Enum.map(fn e ->
      seconds_to_add = :rand.uniform(seconds_days_14) + seconds_half_day
      add_dt = NaiveDateTime.add(user.inserted_at, seconds_to_add)
      time_start = time_from_mock.(e["time_start"])
      shift_len_min = e["length_minutes"] || 0
      shift_length = e["length_hours"] * 60 * 60 + shift_len_min * 60
      time_end = Time.add(time_start, shift_length) |> Time.truncate(:second)

      %{
        subject: e["subject"],
        description: e["description"],
        location: e["location"],
        time_zone: Timex.timezones() |> Enum.random(),
        time_start: time_start,
        time_end: time_end,
        user_id: user.id,
        inserted_at: add_dt,
        updated_at: add_dt
      }
    end)

  Repo.insert_all(ShiftTemplate, user_shifts)
end
