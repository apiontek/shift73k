defmodule Shift73kWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(%Phoenix.HTML.Form{} = form, field, opts \\ []) do
    opts = error_common_opts(form, field, "invalid-feedback", opts)

    form.errors
    |> Keyword.get_values(field)
    |> Stream.with_index()
    |> Enum.map(fn err_with_index -> error_tag_span(err_with_index, opts) end)
  end

  defp error_tag_span({err, _} = err_with_index, opts) do
    opts = error_tag_opts(err_with_index, opts)
    content_tag(:span, translate_error(err), opts)
  end


  defp error_common_opts(form, field, append, opts) do
    Keyword.put(opts, :phx_feedback_for, input_id(form, field))
    |> Keyword.update(:class, append, fn c -> "#{append} #{c}" end)
  end

  defp error_tag_opts({_err, err_index}, opts) do
    input_id = Keyword.get(opts, :phx_feedback_for, "")
    Keyword.put(opts, :id, error_id(input_id, err_index))
  end

  defp error_id(input_id, err_index), do: "#{input_id}_feedback-#{err_index}"

  def error_ids(%Phoenix.HTML.Form{} = form, field) do
    input_id = input_id(form, field)
    form.errors
    |> Keyword.get_values(field)
    |> Stream.with_index()
    |> Stream.map(fn {_, index} -> error_id(input_id, index) end)
    |> Enum.join(" ")
  end

  def input_class(form, field, classes \\ "") do
    case form.source.action do
      nil ->
        classes

      _ ->
        case Keyword.has_key?(form.errors, field) do
          true -> "#{classes} is-invalid"
          _ -> "#{classes} is-valid"
        end
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(Shift73kWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Shift73kWeb.Gettext, "errors", msg, opts)
    end
  end
end
