defmodule Bones73k.Util.List do
  def prepend_if(list, condition, item), do: (!!condition && [item | list]) || list
  def append_if(list, condition, item), do: (!!condition && list ++ [item]) || list
end
