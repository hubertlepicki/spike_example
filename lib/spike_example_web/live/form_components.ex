defmodule SpikeExampleWeb.FormComponents do
  use SpikeExampleWeb, :component

  import Spike.LiveView.{FormField, Errors}

  def errors_component(%{form_data: _, key: _, errors: _} = assigns) do
    ~H"""
    <.errors let={field_errors} key={@key} form_data={@form_data} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>
    """
  end

  def label_component(%{ref: _ref, text: _text, key: _key} = assigns) do
    ~H"""
    <label for={"#{@ref}_#{@key}"}><%= @text %></label>
    """
  end

  def input_component(%{type: "text", key: _, form_data: _, errors: _} = assigns) do
    ~H"""
    <div>
      <%= if @label do %>
        <.label_component text={@label} ref={@form_data.ref} key={@key} />
      <% end %>

      <.form_field key={@key} form_data={@form_data}>
        <input id={"#{@form_data.ref}_#{@key}"} name="value" type="text" value={@form_data |> Map.get(@key)} />
      </.form_field>

      <.errors_component form_data={@form_data} key={@key} errors={@errors} />
    </div>
    """
  end

  def input_component(%{type: "select", key: _, form_data: _, errors: _, options: _} = assigns) do
    ~H"""
    <div>
      <%= if @label do %>
        <.label_component text={@label} ref={@form_data.ref} key={@key} />
      <% end %>

      <.form_field key={@key} form_data={@form_data}>
        <select id={"#{@form_data.ref}_#{@key}"} name="value">
          <%= for {value, text} <- @options do %>
            <option value={value || ""} selected={@form_data |> Map.get(@key) == value}><%= text %></option>
          <% end %>
        </select>
      </.form_field>

      <.errors_component form_data={@form_data} key={@key} errors={@errors} />
    </div>
    """
  end
end
