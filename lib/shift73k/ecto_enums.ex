defmodule Shift73k.EctoEnums do
  import EctoEnum

  @weekdays [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
            |> Enum.with_index(1)

  defenum(WeekdayEnum, @weekdays)
end
