defmodule Shift73k.EctoEnums do
  import EctoEnum

  @weekdays [:mon, :tue, :wed, :thu, :fri, :sat, :sun] |> Enum.with_index(1)

  defenum(WeekdayEnum, @weekdays)
end
