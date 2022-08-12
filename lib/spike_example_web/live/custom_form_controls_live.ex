defmodule SpikeExampleWeb.CustomFormControlsLive do
  use SpikeExampleWeb, :form_live_view
  import SpikeExampleWeb.FormComponents
  import SpikeExampleWeb.Debug

  defmodule Form do
    use Spike.Form do
      field(:size, :string, default: "M")
      field(:available_sizes, {:array, :string}, default: ["XS", "S", "M", "L", "XL", "XXL"])
    end
  end

  def mount(_, _, socket) do
    form = Form.new(%{})
    {:ok, socket |> assign(%{form: form, errors: Spike.errors(form)})}
  end

  def render(assigns) do
    ~H"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Simple form:</h2>

      <h3>HTML form controls</h3>

      <.input_component type="select" label="Choose your size:" field={:size} form={@form} errors={@errors} options={@form.available_sizes |> Enum.map(& {&1, &1})} />

      <.input_component type="radio" label="Choose your size:" field={:size} form={@form} errors={@errors} options={@form.available_sizes |> Enum.map(& {&1, &1})} />

      <.custom_select label="Choose your size:" field={:size} form={@form} errors={@errors} options={@form.available_sizes |> Enum.map(& {&1, &1})} />
    <hr/>
    <.sources />

    <hr/>
    <.debug_assigns form={@form} errors={@errors} />
    """
  end

  @doc """
  To create custom form controls you can use several techniques:
  - use Spike.LiveView.Components.form_field which wraps hidden field
  - emit spike-form-event:set-value event from your own Hook
  - emit spike-form-event:set-value using default Phoenix hooks (example below)
  """
  defp custom_select(%{label: _, field: _, form: _, options: _} = assigns) do
    ~H"""
      <div>
        <label>Choose your size:</label>
        <%= for {text, value} <- @options do %>
          <%= if value == Map.get(@form, @field) do %>
            <u><b>
              <a href="#" phx-click="spike-form-event:set-value" phx-value-ref={@form.ref} phx-value-field={@field} phx-value-value={value}><%= text %></a>
            </b></u>
          <% else %>
            <a href="#" phx-click="spike-form-event:set-value" phx-value-ref={@form.ref} phx-value-field={@field} phx-value-value={value}><%= text %></a>
          <% end %>
        <% end %>
      </div>
    """
  end

  def sources(assigns) do
    ~H"""
    See source of 
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example_web/live/custom_form_controls_live.ex" target="_blank">this example.</a>
    """
  end
end
