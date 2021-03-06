defmodule Shift73kWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field, opts \\ []) do
    opts = error_opts(form, field, opts)

    form.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn error -> content_tag(:span, translate_error(error), opts) end)
  end

  defp error_opts(form, field, opts) do
    append = "invalid-feedback"
    input_id = input_id(form, field)

    opts
    |> Keyword.put_new(:id, error_id(input_id))
    |> Keyword.put_new(:phx_feedback_for, input_id)
    |> Keyword.update(:class, append, fn c -> "#{append} #{c}" end)
  end

  def error_id(%Phoenix.HTML.Form{} = form, field), do: input_id(form, field) |> error_id()
  def error_id(input_id) when is_binary(input_id), do: "#{input_id}_feedback"

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
