defmodule Bones73kWeb.Pagination do
  def generate_page_list(_, total_pages) when total_pages < 5,
    do: 1..total_pages |> Enum.to_list()

  def generate_page_list(current, total_pages),
    do: first_half(1, current) ++ [current] ++ second_half(current, total_pages)

  defp first_half(first, current) do
    prev = current - 1

    cond do
      first == current -> []
      prev <= first -> [first]
      prev - first > 2 -> [first, -1, prev]
      true -> first..prev |> Enum.to_list()
    end
  end

  defp second_half(current, last) do
    next = current + 1

    cond do
      last == current -> []
      next >= last -> [last]
      last - next > 2 -> [next, -1, last]
      true -> next..last |> Enum.to_list()
    end
  end
end
