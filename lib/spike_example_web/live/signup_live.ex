defmodule SpikeExampleWeb.SignupLive do
  use SpikeExampleWeb, :form_live_view
  import Spike.LiveView.{FormField, Errors}

  def mount(_params, _, socket) do
    {:ok,
     socket
     |> assign(%{
       form_data:
         SpikeExample.SignupForm.new(%{available_plans: find_plans()}, cast_private: true),
       errors: %{}
     })}
  end

  def render(assigns) do
    ~H"""
    <h2>Example signup form:</h2>

    <label for="company_name">Company name:</label>
    <.form_field key={:company_name} form_data={@form_data}>
      <input name="value" type="text" value={@form_data.company_name} phx-debounce={1000} />
    </.form_field>

    <.errors let={field_errors} key={:company_name} form_data={@form_data} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>

    <h4>Debug info:</h4>
    <pre>
      Form data:
      <%= inspect @form_data, pretty: true %>
    </pre>

    <pre>
      Errors:
      <%= inspect @errors, pretty: true %>
    </pre>
    """
  end

  defp find_plans() do
    [
      %{id: 1, name: "Starter", price: 0},
      %{id: 2, name: "Growth", price: 1},
      %{id: 3, name: "Enterprise", price: 9000}
    ]
  end
end
