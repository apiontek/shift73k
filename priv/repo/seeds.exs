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

import Ecto.Query
alias Shift73k.Repo
alias Shift73k.Accounts
alias Shift73k.Accounts.User
alias Shift73k.Properties.Property

############################################################################
## INSERTING MOCK USER DATA

{:ok, admin} =
  Accounts.register_user(%{
    email: "admin@company.com",
    password: "123456789abc",
    password_confirmation: "123456789abc",
    role: Accounts.registration_role()
  })

{:ok, user_1} =
  Accounts.register_user(%{
    email: "user1@company.com",
    password: "123456789abc",
    password_confirmation: "123456789abc",
    role: Accounts.registration_role()
  })

{:ok, user_2} =
  Accounts.register_user(%{
    email: "user2@company.com",
    password: "123456789abc",
    password_confirmation: "123456789abc",
    role: Accounts.registration_role()
  })

# if Mix.env() == :dev do
this_path = Path.dirname(__ENV__.file)

users_json = Path.join(this_path, "MOCK_DATA_users.json")

count_to_take = 123

mock_users = users_json |> File.read!() |> Jason.decode!() |> Enum.take_random(count_to_take)

mock_users = ~s([
      {"email":"adam@73k.us","password":"adamadam","role":"admin","inserted_at":"2018-12-14T01:01:01Z","confirmed_at":true},
      {"email":"karen@73k.us","password":"karenkaren","role":"manager","inserted_at":"2018-12-14T01:06:01Z","confirmed_at":true},
      {"email":"kat@73k.us","password":"katkat","role":"manager","inserted_at":"2018-12-14T01:06:01Z","confirmed_at":true}
    ]) |> Jason.decode!() |> Enum.concat(mock_users)

mock_users =
  Enum.map(mock_users, fn e ->
    add_dt = NaiveDateTime.from_iso8601!(e["inserted_at"])

    %{
      email: e["email"],
      role: String.to_existing_atom(e["role"]),
      hashed_password: Bcrypt.hash_pwd_salt(e["password"]),
      inserted_at: add_dt,
      updated_at: add_dt,
      confirmed_at: (e["confirmed_at"] && NaiveDateTime.add(add_dt, 300, :second)) || nil
    }
  end)

Repo.insert_all(User, mock_users)
# end

############################################################################
## IF ENV IS DEV
## INSERTING MOCK PROPERTIES DATA

Enum.each(1..10, fn i ->
  %{
    name: "Property #{i} - User 1",
    price: :rand.uniform(5) * 100_000,
    description: "Property that belongs to user 1",
    user_id: user_1.id
  }
  |> Shift73k.Properties.create_property()

  %{
    name: "Property #{i} - User 2",
    price: :rand.uniform(5) * 100_000,
    description: "Property that belongs to user 2",
    user_id: user_2.id
  }
  |> Shift73k.Properties.create_property()

  %{
    name: "Property #{i} - Admin",
    price: :rand.uniform(5) * 100_000,
    description: "Property that belongs to admin",
    user_id: admin.id
  }
  |> Shift73k.Properties.create_property()
end)

# if Mix.env() == :dev do
# this_path = Path.dirname(__ENV__.file)

props_json = Path.join(this_path, "MOCK_DATA_properties.json")

count_to_take = 123

mock_props = props_json |> File.read!() |> Jason.decode!() |> Enum.take_random(count_to_take)

random_user_query = from(User, order_by: fragment("RANDOM()"), limit: 1)

mock_props =
  Enum.map(mock_props, fn e ->
    add_dt = NaiveDateTime.from_iso8601!(e["inserted_at"])
    rand_user = Repo.one(random_user_query)

    %{
      name: e["name"],
      price: e["price"],
      description: e["description"],
      user_id: rand_user.id,
      inserted_at: add_dt,
      updated_at: add_dt
    }
  end)

Repo.insert_all(Property, mock_props)
# end
