defmodule LofiPlayWeb.ScreenView do
  use LofiPlayWeb, :view
  alias Phoenix.HTML
  alias Phoenix.HTML.Tag

  defp has_flag_tag(tags, name) do
    case tags do
      %{^name => {:flag, true}} -> true
      _ -> false
    end
  end

  defp flatten_classes(classes) do
    classes
    |> Enum.filter(&(Kernel.elem(&1, 1)))
    |> Enum.map(&(Kernel.elem(&1, 0)))
    |> Enum.join(" ")
  end

  @doc """
  #button
  
  <button>
  """
  defp preview_line_element(%Lofi.Element{texts: [""], tags: %{"button" => {:flag, true}}}, %Lofi.Element{children: children, tags: tags}) do
    class = flatten_classes [
      {"btn", true},
      {
        cond do
          has_flag_tag(tags, "primary") -> "btn-primary"
          true -> "btn-default"
        end,
        true
      }
    ]

    #Tag.content_tag(:button, Enum.join([""], ""), class: class)
    Tag.content_tag(:div, class: "btn-group") do
      children
      #|> Enum.map(&preview_line/1)
      |> Enum.map(fn (element) ->
        element = Map.update!(element, :tags, fn (child_tags) -> Map.merge(tags, child_tags) end)
        #|> &Map.update!(&1, :tags, &Map.merge(tags, &1))
        preview_line(element)
      end)
    end
  end

  @doc """
  #button
  
  <button>
  """
  defp preview_line_element(%Lofi.Element{texts: texts, tags: %{"button" => {:flag, true}}}, %Lofi.Element{tags: tags}) do
    class = flatten_classes [
      {"btn", true},
      {"active", has_flag_tag(tags, "active")},
      {
        cond do
          has_flag_tag(tags, "primary") -> "btn-primary"
          true -> "btn-default"
        end,
        true
      }
    ]

    Tag.content_tag(:button, Enum.join(texts, ""), class: class)
  end

  @doc """
  #field -> <input>
  """
  defp preview_line_element(%Lofi.Element{texts: texts, tags: %{"field" => {:flag, true}}}, %Lofi.Element{tags: tags}) do
    type = cond do
      has_flag_tag(tags, "password") ->
        "password"
      true ->
        "text"
    end

    Tag.content_tag(:label, [
      Enum.join(texts, ""),
      " ",
      Tag.tag(:input, type: type)
    ])
  end

  @doc """
  #primary -> <h1>
  """
  defp preview_line_element(%Lofi.Element{texts: texts, tags: %{"primary" => {:flag, true}}}, element) do
    Tag.content_tag(:h1, Enum.join(texts, ""))
  end

  defp preview_line_element(%Lofi.Element{texts: texts, tags: %{"secondary" => {:flag, true}}}, element) do
    Tag.content_tag(:h2, Enum.join(texts, ""))
  end

  defp preview_line_element(%Lofi.Element{texts: texts}, element) do
    Tag.content_tag(:p, Enum.join(texts, ""))
  end

  defp preview_line(element) do
    preview_line_element(element, element)
  end

  defp preview_section(lines) do
    html_lines = Enum.map(lines, &preview_line/1)

    Tag.content_tag(:div, html_lines)
  end

  def preview_body(body) do
    sections = Lofi.Parse.parse_sections(body)

    Enum.map(sections, &preview_section/1)
  end
end
